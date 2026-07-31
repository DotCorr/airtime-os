# AirtimeOS

A minimal embedded Linux that turns **any computer with an HDMI port** into a
dedicated Airtime screen. Boots straight into a fullscreen kiosk showing
`airtime.dotcorr.com/tv` — the owner scans the QR from their phone and the
box becomes a revenue-generating ad screen. No smart TV required.

## Architecture

- **Base**: Alpine Linux (musl, tiny, apk) — image ~350 MB
- **Session**: [Cage](https://github.com/cage-kiosk/cage) (Wayland kiosk
  compositor — one fullscreen app, nothing else, ever)
- **Runtime**: Chromium in kiosk mode. A browser *is* the performant native
  runtime here — hardware-accelerated video decode, WebGL, WebSocket — no
  Electron/Tauri wrapper needed because the OS itself is the wrapper.
- **Connectivity**: NetworkManager + a first-boot settings screen (served
  locally by the box) for Wi-Fi setup, with **wvkbd** on-screen keyboard for
  touch displays
- **Watchdog**: the kiosk restarts Chromium if it ever dies; systemd-style
  supervision via OpenRC `respawn`
- **Updates**: the app is the website — every deploy updates every box
  instantly; the OS only ships base-system updates

## Boot flow

1. Power on → auto-login → Cage starts
2. If no network: local settings page (`http://localhost:8800`) opens in the
   kiosk instead — pick Wi-Fi, type password (virtual keyboard on touch),
   connect
3. Once online: kiosk navigates to `https://airtime.dotcorr.com/tv`
4. TV shows the QR → owner claims it from their phone → box flips into the
   ad player automatically and survives reboots (the pairing lives server-side;
   the player URL is persisted in `/etc/airtime/screen.conf` after claim)

## Build (needs Linux or Docker; ~15 min, ~2 GB downloads)

```sh
# on macOS with Docker Desktop running:
./build.sh docker

# on a Linux box with root:
sudo ./build.sh native
```

Produces `dist/airtimeos-x86_64.img` — a raw disk image.

## Test in QEMU

```sh
./test-qemu.sh              # boots the built image with virtio-gpu + network
```

## Flash to a real device

```sh
# find the disk with `diskutil list` (macOS) or `lsblk` (Linux) — BE CAREFUL
sudo dd if=dist/airtimeos-x86_64.img of=/dev/diskN bs=4m status=progress
```

Then plug the box into any TV/monitor via HDMI. Done.

## Hardware targets

Any x86_64 mini-PC (N100-class boxes are ideal: fanless, ~4W, <€150).
ARM builds (Raspberry Pi / CM4) are a follow-up — same overlay, different
base image.
