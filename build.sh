#!/bin/sh
# AirtimeOS image builder — Alpine-based kiosk.
# Usage: ./build.sh docker   (macOS/anywhere with Docker)
#        ./build.sh native   (Linux with root)
set -eu

MODE="${1:-docker}"
ALPINE_VERSION=3.20
IMG=dist/airtimeos-x86_64.img
cd "$(dirname "$0")"
mkdir -p dist

if [ "$MODE" = "docker" ]; then
  # Run the native path inside a privileged Alpine container (needs loop devices).
  exec docker run --rm --privileged -v "$PWD:/os" -w /os alpine:$ALPINE_VERSION \
    sh -c "apk add --no-cache alpine-make-vm-image e2fsprogs && ./build.sh native"
fi

command -v alpine-make-vm-image >/dev/null 2>&1 || {
  echo "installing alpine-make-vm-image…"
  apk add --no-cache alpine-make-vm-image e2fsprogs 2>/dev/null || {
    wget -qO /usr/local/bin/alpine-make-vm-image \
      https://raw.githubusercontent.com/alpinelinux/alpine-make-vm-image/master/alpine-make-vm-image
    chmod +x /usr/local/bin/alpine-make-vm-image
  }
}

alpine-make-vm-image \
  --image-format raw \
  --image-size 2G \
  --kernel-flavor lts \
  --branch v$ALPINE_VERSION \
  --packages "$(cat packages.txt)" \
  --fs-skel-dir overlay \
  --fs-skel-chown root:root \
  --script-chroot \
  "$IMG" -- ./provision.sh

echo "built: $IMG"
