xrandr --output HDMI-A-0 --mode 1920x1080 --rate 72  --primary --left-of eDP &
nm-applet &
/usr/libexec/polkit-mate-authentication-agent-1 &
slstatus &
~/.fehbg &
picom &
dunst &
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0 &
setxkbmap -layout gb,lt
setxkbmap -option 'grp:alt_shift_toggle'
exec dwm

