#!/bin/bash

function run {
 if ! pgrep $1 ;
  then
    $@&
  fi
}

setxkbmap -layout gb,lt 
setxkbmap -option 'grp:alt_shift_toggle' 
run "picom"
run "flameshot"
run "nm-applet"
run "slstatus"
run "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
~/.fehbg &
