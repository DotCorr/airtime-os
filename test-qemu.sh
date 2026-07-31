#!/bin/sh
# Boot the built image in QEMU with display + network.
# -vga none matters: a second VGA device puts wlroots in multi-GPU mode, which
# can't import buffers from the software renderer. Serial console on stdio for
# debugging (root logs in without a password).
set -eu
cd "$(dirname "$0")"
IMG=dist/airtimeos-x86_64.img
[ -f "$IMG" ] || { echo "build first: ./build.sh docker (or download a release image into dist/)"; exit 1; }
exec qemu-system-x86_64 \
  -m 3072 -smp 6 \
  -drive file="$IMG",format=raw,if=virtio \
  -vga none -device virtio-gpu-pci -display default,show-cursor=on \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -usb -device usb-tablet \
  -serial mon:stdio
