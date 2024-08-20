#!/bin/sh

screenshot_dir="/home/$(whoami)/Screenshots/temp"
mkdir -p "$screenshot_dir"
username=$(whoami)

for o in HDMI-A-1 eDP-1
do
    grim -o "$o" "$screenshot_dir/$o.png"
done
gthumb "$screenshot_dir/eDP-1.png"
