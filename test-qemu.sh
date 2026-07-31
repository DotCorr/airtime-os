#!/bin/sh
# Boot the built image in QEMU with display + network.
set -eu
cd "$(dirname "$0")"
IMG=dist/airtimeos-x86_64.img
[ -f "$IMG" ] || { echo "build first: ./build.sh docker"; exit 1; }
exec qemu-system-x86_64 \
  -m 2048 -smp 2 \
  -drive file="$IMG",format=raw,if=virtio \
  -device virtio-gpu-pci -display default,show-cursor=on \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -usb -device usb-tablet
