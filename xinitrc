xrandr --output HDMI-A-0 --mode 1920x1080 --rate 71.91  --primary --left-of eDP &
/usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0 &
exec dwm

