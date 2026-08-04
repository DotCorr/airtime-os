# AirtimeOS

The operating system for Airtime screens. Boot it on any computer with a
display output and that machine becomes a rentable ad screen: it shows a QR
code, the owner scans it with a phone, and it starts playing ads.

Built on Debian — full hardware firmware, a branded boot splash, and nothing
else. There is no desktop environment: the machine boots straight into the
Airtime interface and there is nothing behind it to escape into.

## Use it

1. Download `airtimeos-x86_64.iso` from
   [Releases](https://github.com/DotCorr/airtime-os/releases).
2. Flash it to a USB stick with [balenaEtcher](https://etcher.balena.io).
3. Plug the machine into a screen and boot from the stick.
4. Scan the QR code with your phone. Done — it's earning.

Wi-Fi setup, display scaling, updates, and installing to the internal disk all
live in the on-screen settings panel (the gear in the taskbar). Running from
the stick keeps its pairing and Wi-Fi across reboots; installing to disk frees
the stick and survives on its own.

## What's inside

| | |
|---|---|
| Base | Debian bookworm (live-build) |
| Session | cage (Wayland) running Chromium in kiosk mode |
| Interface | the Airtime web app — there is no other UI |
| Boot | Plymouth splash, no menus, no logs on screen |
| Hardware | firmware for Intel/AMD graphics and Intel/Broadcom/Realtek/Atheros/MediaTek wireless |

## Build it

CI builds the image on every release tag (`.github/workflows/build-debian.yml`).
To build locally you need Docker:

```sh
./debian/build.sh          # produces dist/airtimeos-x86_64.iso
./test-qemu.sh             # boot it in QEMU (UEFI, like real hardware)
```

## Repository

```
debian/     live-build configuration: packages, hooks, Plymouth theme
overlay/    the Airtime layer: kiosk session, settings server, policies
```

The platform itself (the marketplace, the app you see on screen) is a separate
private repository; this repo is only the OS that hosts it.
