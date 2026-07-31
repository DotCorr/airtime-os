#!/bin/sh
# Runs inside the image chroot at build time.
set -eu

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

# kiosk session autostarts from profile
cat > /home/kiosk/.profile << 'PROFILE'
[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/airtime-kiosk
PROFILE
chown kiosk:kiosk /home/kiosk/.profile

chmod +x /usr/local/bin/airtime-kiosk /usr/local/bin/airtime-settingsd /etc/local.d/airtime.start
