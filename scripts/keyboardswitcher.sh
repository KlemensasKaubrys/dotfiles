#!/bin/bash
function keyboard {
	options="gb\nus\nlt"
	selected=$(echo -e $options | tofi "$@" )
	if [[ $selected = "gb" ]]; then 
   		setxkbmap gb 
		riverctl keyboard-layout gb
	elif [[ $selected = "us" ]]; then
   		setxkbmap us
		riverctl keyboard-layout us
	elif [[ $selected = "lt" ]]; then
   		setxkbmap lt
		riverctl keyboard-layout lt
	fi
}
keyboard "$@"
