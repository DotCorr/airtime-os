#!/bin/sh
# Runs inside the image chroot at build time.
set -eu

# identity — otherwise every console line reads "localhost"
echo airtimeos > /etc/hostname
printf '127.0.0.1\tlocalhost airtimeos\n::1\t\tlocalhost airtimeos\n' > /etc/hosts

# silent, instant boot: no bootloader wait, kernel+service chatter goes to the
# serial port (debug channel) instead of the screen; no console cursor or banners
sed -i -e 's/^TIMEOUT .*/TIMEOUT 1/' \
       -e '/^ *APPEND /s/$/ quiet loglevel=1 vt.global_cursor_default=0 console=ttyS0,115200/' \
  /boot/extlinux.conf 2>/dev/null || true
: > /etc/motd
: > /etc/issue
sed -i 's/^#\?rc_parallel=.*/rc_parallel="YES"/' /etc/rc.conf

# services
rc-update add dbus default
rc-update add networkmanager default
rc-update add seatd default
rc-update add udev sysinit
rc-update add local default

# kiosk user — create groups first, then the user, then memberships;
# every step tolerant of "already exists" but never of a missing user.
for g in video input seat; do addgroup "$g" 2>/dev/null || true; done
adduser -D -s /bin/sh kiosk
for g in video input seat; do addgroup kiosk "$g" || true; done

# autologin on tty1 → kiosk session
sed -i 's|^tty1.*|tty1::respawn:/sbin/agetty --autologin kiosk --noclear tty1 linux|' /etc/inittab

# serial console (debugging in VMs / headless boards; no-op when absent)
grep -q '^ttyS0' /etc/inittab || echo 'ttyS0::respawn:/sbin/getty -L 115200 ttyS0 vt100' >> /etc/inittab

# udev coldplug so devices present before udev started still get events
rc-update add udev-trigger sysinit
rc-update add udev-settle sysinit

# branded boot screen while services come up (chmod before rc-update — it
# refuses to register a non-executable service)
chmod +x /etc/init.d/airtime-banner
rc-update add airtime-banner boot

# NM connection profiles must be root-only or NM ignores them
chmod 600 /etc/NetworkManager/system-connections/wired.nmconnection

# kiosk session autostarts from profile
cat > /home/kiosk/.profile << 'PROFILE'
[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/airtime-kiosk
PROFILE
chown kiosk:kiosk /home/kiosk/.profile

chmod +x /usr/local/bin/airtime-kiosk /usr/local/bin/airtime-settingsd /etc/local.d/airtime.start \
  /usr/local/share/airtime-settings/cgi-bin/networks /usr/local/share/airtime-settings/cgi-bin/connect \
  /etc/init.d/airtime-banner
