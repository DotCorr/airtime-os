#!/bin/sh
# Boot the AirtimeOS ISO the way real hardware does: UEFI + a GPU.
# Needs qemu and OVMF/edk2 firmware.
set -eu
cd "$(dirname "$0")"
ISO=dist/airtimeos-x86_64.iso
[ -f "$ISO" ] || { echo "no image at $ISO — download it from the GitHub release"; exit 1; }
FW=${OVMF:-/opt/homebrew/share/qemu/edk2-x86_64-code.fd}
[ -f "$FW" ] || { echo "set OVMF=/path/to/edk2-x86_64-code.fd"; exit 1; }
exec qemu-system-x86_64 \
  -m 4096 -smp 4 \
  -drive if=pflash,format=raw,readonly=on,file="$FW" \
  -drive file="$ISO",format=raw,if=virtio \
  -vga none -device virtio-gpu-pci -display default,show-cursor=on \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -usb -device usb-tablet
