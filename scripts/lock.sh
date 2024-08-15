#!/bin/sh
export MAGICK_THREAD_LIMIT=4
for o in HDMI-A-1 eDP-1
do
	grim -o "$o" "/tmp/$o.png"
        magick "/tmp/$o.png" -resize 50% -filter Box -blur 0x7 -resize 200% -quality 75 "/tmp/$o.png"
done
exec gtklock -s ~/.config/gtklock/style.css "$@"
