#!/bin/bash

function powermenu {
	options="Cancel\nShutdown\nRestart\nSuspend\nHibernate"
	selected=$(echo -e $options | dmenu -bw 2)
	if [[ $selected = "Shutdown" ]]; then 
		poweroff
	elif [[ $selected = "Restart" ]]; then
		reboot
	elif [[ $selected = "Suspend" ]]; then
		systemctl suspend
	elif [[ $selected = "Hibernate" ]]; then
		systemctl hibernate
	elif [[ $selected = "Cancel" ]]; then
		return
	fi
}


powermenu
