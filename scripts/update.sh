#!/bin/bash
if [ "$(id -u)" != 0 ]; then
  echo "Please run this script as root or using sudo!"
  exit 1
fi
xbps-install -Su
flatpak update
sed -i 's|exec /usr/bin/flatpak run|exec /usr/bin/flatpak run --socket=wayland|g' /var/lib/flatpak/exports/bin/*
