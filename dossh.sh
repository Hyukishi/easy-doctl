#!/bin/bash
# Created by Jeffery Grantham 02/12/2019

doctl="$(command -v doctl)"
input="$1"
a1=""
a2=""
a3=""
a4=""
a5=""

# Array Function
droplet_id(){
n=0
for i in $(doctl compute droplet list --format ID)
do  ((n=n+1))
	if [[ "$i" == "ID" ]]; then
	((n=n-1))
	fi
echo "$i" >/dev/null 2>&1
droplet[$n]=$i
done
}

while [[ "$input" != "quit" ]];
do
	clear
	echo "What would you like to do?"
	echo "1: SSH via PublicIPv4"
	echo "2: SSH via PrivateIPv4 (only for droplet to droplet connections)"
	echo "(Type quit to exit)"
	echo ""
	droplet_id
	read -rp "Enter the corresponding number and press ENTER: " input
	clear

# Functions
pause(){
	clear
	read -rp "Press ENTER to continue"
	clear
	return
}

ssh_public_ipv4 () {
    while true; do
        $doctl compute droplet list --format ID,Name,PublicIPv4 | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
        read -rp "Droplet name or ID number: " a1
        [[ ${a1:-help} != help ]] && break
    done

    ssh_args=()

    read -rp "User (leave blank for root): " a2
    [[ -n "$a2" ]] && ssh_args+=(--ssh-user "$a2")

    read -rp "Port (leave blank for 22): " a3
    [[ -n "$a3" ]] && ssh_args+=(--ssh-port "$a3")

    read -rp "Path to SSH key (leave blank for default): " a4
    [[ -n "$a4" ]] && ssh_args+=(--ssh-key-path "$a4")

    read -rp "Do you want to enable agent fowarding? (y/n) " a5
    [[ "$a5" == "y" ]] && ssh_args+=(--ssh-agent-forwarding)

    $doctl compute ssh "${droplet[$a1]}" "${ssh_args[@]}"

	pause
	return
}

ssh_private_ipv4(){
while true; do
        $doctl compute droplet list --format ID,Name,PublicIPv4 | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
        read -rp "Droplet name or ID number: " a1
        [[ ${a1:-help} != help ]] && break
    done
ssh_args=()

    read -rp "User (leave blank for root): " a2
    [[ -n "$a2" ]] && ssh_args+=(--ssh-user "$a2")

    read -rp "Port (leave blank for 22): " a3
    [[ -n "$a3" ]] && ssh_args+=(--ssh-port "$a3")

    read -rp "Path to SSH key (leave blank for default): " a4
    [[ -n "$a4" ]] && ssh_args+=(--ssh-key-path "$a4")

    read -rp "Do you want to enable agent fowarding? (y/n) " a5
    [[ "$a5" == "y" ]] && ssh_args+=(--ssh-agent-forwarding)

    $doctl compute ssh "${droplet[$a1]}" --ssh-private-ip "${ssh_args[@]}"

	pause
	return
}

# Calls to functions
case "$input" in
	1) ssh_public_ipv4
		;;
	2) ssh_private_ipv4
		;;
esac

done
