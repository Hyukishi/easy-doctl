#!/bin/bash
# Created by Jeffery Grantham 02/14/2019

doctl="$(command -v doctl)"
input="$1"
a0=""
a1=""
a2=""
a3=""
a4=""

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

float_id(){
n=0
for i in $(doctl compute floating-ip list --format IP)
do  ((n=n+1))
	if [[ "$i" == "IP" ]]; then
	((n=n-1))
	fi
echo "$i" >/dev/null 2>&1
float[$n]="$i"
done
}

# Menu
while [[ "$input" != "quit" ]];
do
	clear
	echo "What would you like to do?"
	echo "1: List floating IPs"
	echo "2: Create floating IP"
	echo "3: Delete floating IP"
	echo "4: Assign floating IP"
	echo "5: Unassign floating IP"
	echo "(Type quit to exit)"
	echo ""
	droplet_id
	float_id
	read -rp "Enter the corresponding number and press ENTER: " input
	clear

# Functions continued

list_float(){
	$doctl compute floating-ip list
	pause
	return
}

create_float(){
	$doctl compute droplet list --format ID,Name,Region | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Create floating IP for which droplet? " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
	$doctl compute droplet list --format ID,Name,Region | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Create floating IP for which droplet? " a1
	done
	for i in ${droplet[$a1]};
	do
	echo "${droplet[$a1]}"
	done
	$doctl compute floating-ip create --droplet-id "${droplet[$a1]}"
	pause
	return
}

delete_float(){
	$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Floating IP: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Floating IP: " a1
	done
	for i in ${float[$a1]};
	do
	echo "${float[$a1]}"
	done
	$doctl compute floating-ip delete "${float[$a1]}"
	pause
	return
}

assign_float(){
	$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Floating IP to assign: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Floating IP to assign: " a1
	done
	for i in ${float[$a1]};
	do
	echo "${float[$a1]}"
	done
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to be assigned: " a2
	while [[ "$a2" == "" ]] || [[ "$a2" == "help" ]];
	do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Droplet to be assigned: " a2
	done
	for i in ${droplet[$a2]};
	do
	echo "${droplet[$a2]}"
	done
	$doctl compute floating-ip-action assign "${float[$a1]}" "${droplet[$a2]}"
	pause
	return
}

unassign_float(){
	$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Floating IP to unassign: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute floating-ip list --format IP,DropletName,DropletID | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Floating IP to unassign: " a1
	done
	for i in ${float[$a1]};
	do
		echo "${float[$a1]}"
	done
	$doctl compute floating-ip-action unassign "${float[$a1]}"
}

# Calls to functions
case "$input" in
	1) list_float
		;;
	2) create_float
		;;
	3) delete_float
		;;
	4) assign_float
		;;
	5) unassign_float
		;;
esac

done
