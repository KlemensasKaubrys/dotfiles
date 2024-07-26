
#!/bin/bash

function bluetooth {
	options="Cancel\nJBL_Tune_500BT\nGalaxy_Buds_FE"
	selected=$(echo -e $options | dmenu -bw 2)
	if [[ $selected = "JBL_Tune_500BT" ]]; then 
		bluetoothctl connect F4:BC:DA:54:2A:C7
	elif [[ $selected = "Galaxy_Buds_FE" ]]; then
		bluetoothctl connect 54:10:4F:31:B4:84
	elif [[ $selected = "Cancel" ]]; then
		return
	fi
}


bluetooth
