#!/bin/bash
function keyboard {
	options="gb\nus\nlt"
	selected=$(echo -e $options | tofi "$@" )
	if [[ $selected = "gb" ]]; then 
		riverctl keyboard-layout gb
		setxkbmap gb
		pkill -RTMIN+10 waybar
	elif [[ $selected = "us" ]]; then
		riverctl keyboard-layout us
		setxkbmap us
		pkill -RTMIN+10 waybar
	elif [[ $selected = "lt" ]]; then
		riverctl keyboard-layout lt
		setxkbmap lt
		pkill -RTMIN+10 waybar
	fi
}
keyboard "$@"
