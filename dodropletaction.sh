#!/bin/bash
# Created by Jeffery Grantham 02/18/2019

doctl="$(command -v doctl)"
input="$1"
a1=""
a2=""
a3=""
a4=""
a5=""
token="$(cat $HOME/.config/doctl/config.yaml | grep access-token: | sed 's/access-token: //')"

# Functions
pause(){
	read -rp "Press ENTER to continue"
	clear
	return
}

droplet_id(){
n=0
for i in $(doctl compute droplet list --format ID)
do  ((n=n+1))
	if [[ "$i" == "ID" ]]; then
	((n=n-1))
	fi
echo "$i" >/dev/null 2>&1
droplet[$n]="$i"
done
}

# Menu
while [[ "$input" != "quit" ]];
do
	clear
	echo "What would you like to do?"
	echo "1: Disable backups"
	echo "2: Reboot droplet"
	echo "3: Power-Cycle droplet (Hard power-off/restart)"
	echo "4: Shutdown droplet"
	echo "5: Power-off droplet"
	echo "6: Power-on droplet"
	echo "7: Power-reset droplet"
	echo "8: Enable IPv6 for droplet"
	echo "9: Enable private networking on droplet"
	echo "10: Upgrade droplet"
	echo "11: Restore droplet from snapshot image"
	echo "12: Resize droplet RAM"
	echo "13: Resize droplet disk"
	echo "14: Create droplet snapshot"
	echo "(Type quit to exit)"
	echo ""
	droplet_id
	read -rp "Enter the corresponding number and press ENTER: " input
	clear

# Functions continued
disable_backups(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Disable backups on droplet: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action disable-backups "${droplet[$a1]}"
	pause
	return
}

reboot_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to reboot: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action reboot "${droplet[$a1]}"
	pause
	return
}

power_cycle(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to Power-Cycle: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action power-cycle "${droplet[$a1]}"
	pause
	return
}

shutdown_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to shutdown: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action shutdown "${droplet[$a1]}"
	pause
	return
}

poweroff_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to power-off: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action power-off "${droplet[$a1]}"
	pause
	return
}

poweron_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to power-on: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action power-on "${droplet[$a1]}"
	pause
	return
}

powerreset_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to power-reset: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action power-reset "${droplet[$a1]}"
	pause
	return
}

ipv6_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to enable IPv6 on: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action enable-ipv6 "${droplet[$a1]}"
	pause
	return
}

private_networking(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to enable private-networking on: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action enable-private-networking "${droplet[$a1]}"
	pause
	return
}

upgrade_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to upgrade: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet-action upgrade "${droplet[$a1]}"
	pause
	return
}

resize_ram(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to add/remove RAM: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	while true;do
		read -rp "Total amount of RAM: " a2
		[[ ${a2:-help} != help ]] && break
	done
	$doctl compute droplet-action resize "${droplet[$a1]}" --size "$a2"
	pause
	return
}

resize_disk(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to resize disk on: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	while true;do
		read -rp "Total disk size: " a2
		[[ ${a2:-help} != help ]] && break
	done
	$doctl compute droplet-action resize "${droplet[$a1]}" --resize-disk "$a2"
	pause
	return
}

rename_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to rename: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	while true;do
		read -rp "New name for the droplet: " a2
		[[ ${a2:-help} != help ]] && break
	done
	$doctl compute droplet-action rename "${droplet[$a1]}" --droplet-name "$a2"
	pause
	return
}

create_snapshot(){
while true;do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to snapshot: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	while true;do
		read -rp "Name for the snapshot: " a2
		[[ ${a2:-help} != help ]] && break
	done
	$doctl compute droplet-action snapshot "${droplet[$a1]}" --snapshot-name "$a2"
	pause
	return
}

# Call to functions
case "$input" in
	1) disable_backups
		;;
	2) reboot_droplet
		;;
	3) power_cycle
		;;
	4) shutdown_droplet
		;;
	5) poweroff_droplet
		;;
	6) poweron_droplet
		;;
	7) powerreset_droplet
		;;
	8) ipv6_droplet
		;;
	9) private_networking
		;;
	10) upgrade_droplet
		;;
	11) resize_ram
		;;
	12) resize_disk
		;;
	13) rename_droplet
		;;
	14) create_snapshot
		;;
esac

done
