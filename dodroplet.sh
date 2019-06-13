#!/bin/bash
# Created by Jeffery Grantham 02/14/2019

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

curl_regions(){
l=0
for i in $(curl -sX GET -H "Content-Type: html/text" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/regions?page=1" "https://api.digitalocean.com/v2/regions?page=2" "https://api.digitalocean.com/v2/regions?page=3" "https://api.digitalocean.com/v2/regions?page=4" "https://api.digitalocean.com/v2/regions?page=5" | tr "," "\n" | grep slug | sed "s/slug//;s/[[:punct:]]//g;s/null//;/^[[:space:]]*$/d")
do ((l=l+1))
echo "$i" >/dev/null 2>&1
region[$l]="$i"
done
}

curl_images(){
t=0
for i in $(curl -sX GET -H "Content-Type: html/text" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/images?page=1" "https://api.digitalocean.com/v2/images?page=2" "https://api.digitalocean.com/v2/images?page=3" "https://api.digitalocean.com/v2/images?page=4" "https://api.digitalocean.com/v2/images?page=5" | tr "," "\n" | grep slug | sed 's/slug//;s/null//;s/\"\"\://g;/^[[:space:]]*$/d;s/\"//g' | awk 'BEGIN{i=1} /.*/{printf "%d. % s\n",i,$0; i++}')
do  ((t=t+1))
echo "$i" >/dev/null 2>&1
image[$t]=$i
done
}

ssh_key(){
s=0
for i in $(doctl compute ssh-key list --format ID)
do ((s=s+1))
	if [[ "$i" == "ID" ]]; then
		((s=s-1))
	fi
	echo "$i" >/dev/null 2>&1
	sshkey[$s]=$i
done
}

# Menu
while [[ "$input" != "quit" ]];
do
	clear
	echo "What would you like to do?"
	echo "1: List droplets"
	echo "2: Get droplet details"
	echo "3: Create droplet"
	echo "4: Delete droplet"
	echo "5: Show neighbors to droplet"
	echo "6: Show snapshots available for a droplet"
	echo "7: Show backups available for a droplet"
	echo "8: Tag a droplet"
	echo "9: Untag a droplet"
	echo "10: Create tag"
	echo "11: Delete tag"
	echo "12: History of actions on a droplet"
	echo "(Type quit to exit)"
	echo ""
	droplet_id
	curl_regions
	curl_images
	ssh_key
	read -rp "Enter the corresponding number and press ENTER: " input
	clear

# Functions continued
list_droplets(){
	$doctl compute droplet list --format ID,Name
	pause
	return
}

droplet_details(){
while true; do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "See details for which droplet: " a1
	[[ ${a1:-help} != help ]] && break
done
	$doctl compute droplet get "${droplet[$a1]}"
	pause
	return
}

create_droplet(){
while true; do
	read -rp "Choose a name for your droplet: " a1
	[[ ${a1:-help} != help ]] && break
done
while true; do
	read -rp "Choose the amount of RAM (digit per gb) (e.g. 4gb): " a2
	[[ ${a1:-help} != help ]] && break
done
while true; do
	curl -sX GET -H "Content-Type: html/text" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/images?page=1" "https://api.digitalocean.com/v2/images?page=2" "https://api.digitalocean.com/v2/images?page=3" "https://api.digitalocean.com/v2/images?page=4" "https://api.digitalocean.com/v2/images?page=5" | tr "," "\n" | grep slug | sed 's/slug//;s/null//;s/\"\"\://g;/^[[:space:]]*$/d;s/\"//g' | awk 'BEGIN{i=1} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Choose the image to install on your droplet: " a3
	[[ ${a1:-help} != help ]] && break
done
	for i in $(${image[$a3]})
	do
		echo "${image[$a3]}"
	done
while true; do
	curl -sX GET -H "Content-Type: html/text" -H "Authorization: Bearer $token" "https://api.digitalocean.com/v2/regions?page=1" "https://api.digitalocean.com/v2/regions?page=2" "https://api.digitalocean.com/v2/regions?page=3" "https://api.digitalocean.com/v2/regions?page=4" "https://api.digitalocean.com/v2/regions?page=5" | tr "," "\n" | grep slug | sed "s/slug//;s/[[:punct:]]//g;s/null//;/^[[:space:]]*$/d" | awk 'BEGIN{i=1} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Choose the region for your droplet: " a4
	[[ ${a1:-help} != help ]] && break
done
	for i in $(${region[$a4]})
	do
		echo "${region[$a4]}"
	done
while true; do
	$doctl compute ssh-key list | awk 'BEGIN{i=1} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Choose ssh key to be added to the droplet: " a5
	[[ ${a1:-help} != help ]] && break
done
	for i in $(${sshkey[$a5]})
	do
	echo "${sshkey[$a5]}"
	done
	$doctl compute droplet create "$a1" --size "$a2" --image "${image[$a3]}" --region "${region[$a4]}"
	pause
	return
}

delete_droplet(){
while true; do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Delete which droplet: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet delete "${droplet[$a1]}"
	pause
	return
}

show_neighbors(){
while true; do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "See neighbors for which droplet: " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet neighbors "${droplet[$a1]}"
	pause
	return
}

show_snapshots(){
while true; do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Show snapshots for which droplet? " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet snapshots "${droplet[$a1]}"
	pause
	return
}

show_backups(){
while true; do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Show backups for which droplet? " a1
	[[ ${a1:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet backups "${droplet[$a1]}"
	pause
	return
}

tag_droplet(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to tag: " a1
	[[ ${a1:-help} != help ]] && break
done
while true;do
	$doctl compute tag list | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Tag name: " a2
	[[ ${a2:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet tag "${droplet[$a1]}" --tag-name "$a2"
	pause
	return
}

untag_droplet(){
	while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet to untag: " a1
	[[ ${a1:-help} != help ]] && break
done
while true;do
	$doctl compute tag list | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Tag name: " a2
	[[ ${a2:-help} != help ]] && break
done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute droplet untag "${droplet[$a1]}" --tag-name "$a2"
	pause
	return
}

create_tag(){
while true;do
	$doctl compute tag list | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Provide a name: " a1
	[[ ${a1:-help} != help ]] && break
done
	$doctl compute tag create "$a1"
	pause
	return
}

delete_tag(){
while true;do
	$doctl compute tag list | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Name of tag: " a1
	[[ ${a1:-help} != help ]] && break
done
	$doctl compute tag delete "$a1"
	pause
	return
}

get_droplet_actions(){
while true;do
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Which droplet would you like to see a history of actions for? " a1
	[[ ${a1:-help} != help ]] && break
done
	pause
	return
}

# Calls to functions
case "$input" in
	1) list_droplets
		;;
	2) droplet_details
		;;
	3) create_droplet
		;;
	4) delete_droplet
		;;
	5) show_neighbors
		;;
	6) show_snapshots
		;;
	7) show_backups
		;;
	8) tag_droplet
		;;
	9) untag_droplet
		;;
	10) create_tag
		;;
	11) delete_tag
		;;
	12) get_droplet_actions
		;;
esac

done
