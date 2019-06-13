#!/bin/bash
# Created by Jeffery Grantham 02/12/2019

doctl="$(command -v doctl)"
input="$1"
a1=""

while [[ "$input" != "quit" ]];
do
		clear
		echo "What would you like to do?"
		echo "1: Add DigitalOcean Token"
		echo "2: Manage DigitalOcean Generic DNS"
		echo "3: Manage Firewalls"
		echo "4: SSH to DO Droplet"
		echo "5: Manage Floating IPs"
		echo "6: Manage Droplet"
		echo "7: Perform droplet actions"
		echo "8: Make all snapshots available to all US regions"
		echo ""
		read -rp "Enter the corresponding number and press ENTER: " input
		clear

# Functions
pause(){
	read -rp "Press any key to continue..."
	return
	clear
}

doauth(){
	$doctl auth init
	pause
	return
}

dodns(){
	$(command -v dodns.sh)
return
}

dofirewall(){
	$(command -v dofirewall.sh)
return
}

dossh(){
	$(command -v dossh.sh)
return
}

dofloat(){
	$(command -v dofloat.sh)
return
}

dodroplet(){
	$(command -v dodroplet.sh)
return
}

dodropletaction(){
	$(command -v dodropletaction.sh)
return
}

dosnapavailability(){
	$(command -v dosnapavailability.sh)
}

# Calls to functions
case "$input" in
	1) doauth
		;;
	2) dodns
		;;
	3) dofirewall
		;;
	4) dossh
		;;
	5) dofloat
		;;
	6) dodroplet
		;;
	7) dodropletaction
		;;
	8) dosnapavailability
		;;
esac

done
