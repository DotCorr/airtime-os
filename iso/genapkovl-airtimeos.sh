#!/bin/sh -e
# Builds the apkovl (boot-time rootfs overlay) for the AirtimeOS live ISO.
# Mirrors what provision.sh does for the disk image, but applied at boot.
HOSTNAME="$1"
[ -z "$HOSTNAME" ] && HOSTNAME=airtimeos

cleanup() { rm -rf "$tmp"; }
tmp="$(mktemp -d)"
trap cleanup EXIT

mkdir -p "$tmp"/etc
echo "$HOSTNAME" > "$tmp"/etc/hostname

# silent init: openrc output goes nowhere regardless of which console the
# kernel picked (no-serial machines fall back to the screen otherwise)
cat > "$tmp"/etc/inittab << 'INITTAB'
::sysinit:/bin/sh -c '/sbin/openrc sysinit >/dev/null 2>&1'
::sysinit:/bin/sh -c '/sbin/openrc boot >/dev/null 2>&1'
::wait:/bin/sh -c '/sbin/openrc default >/dev/null 2>&1'
tty1::respawn:/sbin/agetty --autologin kiosk --noclear tty1 linux
ttyS0::respawn:/sbin/getty -L 115200 ttyS0 vt100
::shutdown:/bin/sh -c '/sbin/openrc shutdown >/dev/null 2>&1'
::ctrlaltdel:/sbin/reboot
INITTAB

# live boot installs exactly what /etc/apk/world lists (from the ISO's own
# package repo) — without this the kiosk stack ships on the ISO but never installs
mkdir -p "$tmp"/etc/apk
{ echo alpine-base; cat /os/packages.txt; } > "$tmp"/etc/apk/world
printf '127.0.0.1\tlocalhost %s\n::1\t\tlocalhost %s\n' "$HOSTNAME" "$HOSTNAME" > "$tmp"/etc/hosts

# the whole overlay tree (kiosk scripts, settings site, NM config)
cp -a /os/overlay/. "$tmp"/
chmod +x "$tmp"/usr/local/bin/* "$tmp"/etc/local.d/airtime.start \
	"$tmp"/usr/local/share/airtime-settings/cgi-bin/* \
	"$tmp"/etc/init.d/airtime-banner "$tmp"/etc/init.d/airtime-settingsd "$tmp"/etc/init.d/airtime-data \
	"$tmp"/etc/periodic/daily/airtime-autoupdate

# silent boot: no motd/issue noise, parallel service startup
: > "$tmp"/etc/motd
: > "$tmp"/etc/issue
printf 'rc_parallel="YES"\n' > "$tmp"/etc/rc.conf

# live-boot provisioning: create the kiosk user + inittab entries at boot.
# tty1 agetty respawns until the user exists, then autologin proceeds.
mkdir -p "$tmp"/etc/local.d
cat > "$tmp"/etc/local.d/airtime-live.start << 'EOF'
#!/bin/sh
for g in video input seat; do addgroup "$g" 2>/dev/null || true; done
id kiosk >/dev/null 2>&1 || adduser -D -s /bin/sh kiosk
# debug parity with the disk image: passwordless root on the serial console
passwd -d root 2>/dev/null || true
for g in video input seat; do addgroup kiosk "$g" 2>/dev/null || true; done
grep -q 'airtime-kiosk' /home/kiosk/.profile 2>/dev/null || {
	printf '[ "$(tty)" = "/dev/tty1" ] && exec /usr/local/bin/airtime-kiosk\n' > /home/kiosk/.profile
	chown kiosk:kiosk /home/kiosk /home/kiosk/.profile
	chown kiosk:kiosk /home/kiosk/.config 2>/dev/null || true
}
grep -q 'autologin kiosk' /etc/inittab || {
	sed -i 's|^tty1.*|tty1::respawn:/sbin/agetty --autologin kiosk --noclear tty1 linux|' /etc/inittab
	echo 'ttyS0::respawn:/sbin/getty -L 115200 ttyS0 vt100' >> /etc/inittab
	kill -HUP 1
}
EOF
chmod +x "$tmp"/etc/local.d/airtime-live.start

rc_add() {
	mkdir -p "$tmp"/etc/runlevels/"$2"
	ln -sf /etc/init.d/"$1" "$tmp"/etc/runlevels/"$2"/"$1"
}
rc_add devfs sysinit
rc_add dmesg sysinit
rc_add mdev sysinit
rc_add udev sysinit
rc_add udev-trigger sysinit
rc_add udev-settle sysinit
rc_add hwdrivers sysinit
rc_add modloop sysinit

rc_add hwclock boot
rc_add modules boot
rc_add sysctl boot
rc_add hostname boot
rc_add bootmisc boot
rc_add syslog boot

rc_add airtime-banner boot
rc_add airtime-data boot
rc_add dbus default
rc_add networkmanager default
rc_add seatd default
rc_add local default
rc_add airtime-settingsd default
rc_add acpid default

rc_add mount-ro shutdown
rc_add killprocs shutdown
rc_add savecache shutdown

tar -c -C "$tmp" etc usr | gzip -9n > "$HOSTNAME.apkovl.tar.gz"
