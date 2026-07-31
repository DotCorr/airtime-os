#!/bin/sh
# Runs inside the image chroot at build time.
set -eu

# services
rc-update add dbus default
rc-update add networkmanager default
rc-update add seatd default
rc-update add udev sysinit
rc-update add local default

# kiosk user
adduser -D -G video kiosk || true
addgroup kiosk input || true
addgroup kiosk seat || true

# autologin on tty1 → kiosk session
sed -i 's|^tty1.*|tty1::respawn:/sbin/agetty --autologin kiosk --noclear tty1 linux|' /etc/inittab

# kiosk session autostarts from profile
cat > /home/kiosk/.profile << 'PROFILE'
[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/airtime-kiosk
PROFILE
chown kiosk:kiosk /home/kiosk/.profile

chmod +x /usr/local/bin/airtime-kiosk /usr/local/bin/airtime-settingsd /etc/local.d/airtime.start
