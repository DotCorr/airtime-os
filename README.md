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
| Base | Debian 13 "trixie" (live-build) |
| Session | LightDM autologin into Chromium in kiosk mode on X |
| Interface | the Airtime web app — there is no other UI |
| Boot | Plymouth splash, no menus, no logs on screen |
| Graphics | Intel, AMD and Nvidia firmware, all of it in the initramfs |
| Wireless | Intel, Realtek, Atheros, MediaTek, and all three Broadcom drivers |

The session is started by a display manager rather than by hand. That is worth
saying out loud because the alternative was tried: LightDM already handles VT
allocation, X startup, permissions, seat management and waiting for Plymouth to
release the display, and doing any of that yourself works on the machine in
front of you and fails on the next one.

## Wi-Fi

Linux ships three separate drivers for Broadcom silicon and no single one of
them covers every chip, so the image carries all three — `brcmfmac`, `b43` and
the out-of-tree `wl` — and picks one at boot from the machine's own PCI ID,
falling back through the others if that lookup does not recognise the chip.

Two cases genuinely cannot work, and the settings panel says so plainly instead
of blaming the password: Macs with a T2 chip (BCM4364/4377), whose firmware is
Apple-licensed and cannot legally be included in Linux, and adapters newer than
the shipped kernel. Ethernet or any USB Wi-Fi adapter works immediately on both.

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
