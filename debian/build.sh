#!/bin/sh
# Build the Debian-based AirtimeOS live ISO (full hardware support).
# Runs live-build inside a privileged Debian container.
set -eu
cd "$(dirname "$0")"
exec docker run --privileged --rm -v "$PWD/..:/os" -w /os/debian debian:bookworm bash -c '
  set -eux
  apt-get update
  apt-get install -y --no-install-recommends live-build ca-certificates
  # shared overlay (kiosk scripts + settings site) from the common tree
  mkdir -p config/includes.chroot/usr/local/bin config/includes.chroot/usr/local/share
  cp -a /os/overlay/usr/local/bin/airtime-kiosk config/includes.chroot/usr/local/bin/
  cp -a /os/overlay/usr/local/bin/airtime-settingsd config/includes.chroot/usr/local/bin/
  cp -a /os/overlay/usr/local/share/airtime-settings config/includes.chroot/usr/local/share/
  chmod +x config/includes.chroot/usr/local/bin/* config/includes.chroot/usr/local/share/airtime-settings/cgi-bin/*
  lb clean --purge || true
  lb config \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --binary-images iso-hybrid \
    --debian-installer none \
    --memtest none \
    --apt-recommends false \
    --iso-application AirtimeOS \
    --iso-publisher Dotcorr \
    --iso-volume AIRTIMEOS \
    --bootappend-live "boot=live components quiet splash persistence noeject"
  lb build
  mkdir -p /os/dist
  mv live-image-amd64.hybrid.iso /os/dist/airtimeos-debian-x86_64.iso
'
