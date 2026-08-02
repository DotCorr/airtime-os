#!/bin/sh
# Hardware buttons → flags the kiosk UI picks up (no direct action here:
# an ad screen must never power off or sleep by accident).
case "$1" in
  button/power*) echo pressed > /tmp/airtime-power-pressed ;;
esac
