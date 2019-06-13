#!/bin/bash
# Created by Jeffery Grantham 02/12/2019

doctl="$(command -v doctl)"
input="$1"
a1=""
a2=""
a3=""
a4=""

# Functions
pause(){
	read -rp "Press ENTER to continue"
	return
}

mapfile(){
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

firewall_id(){
n=0
for i in $(doctl compute firewall list --format ID)
do  ((n=n+1))
	if [[ "$i" == "ID" ]]; then
	((n=n-1))
	fi
echo "$i" >/dev/null 2>&1
firewall[$n]="$i"
done
}

# Menu
while [[ "$input" != "quit" ]];
do
	clear
	echo "What would you like to do?"
	echo "1: List firewalls"
	echo "2: List firewalls by droplet"
	echo "3: List rules by droplet"
	echo "4: Create firewall"
	echo "5: Delete firewall"
	echo "6: Add rule(s)"
	echo "7: Remove rule(s)"
	echo "8: Add droplet(s)"
	echo "9: Remove droplet(s)"
	echo "10: Update rule(s)"
	echo "11: Add tag(s) to firewall"
	echo "12: Remove tag(s) from firewall"
	echo "(Type quit to exit)"
	echo ""
	mapfile
	firewall_id
	read -rp "Enter the corresponding number and press ENTER: " input
	clear

# Functions continued
list_fw(){
	$doctl compute firewall list --format ID,Name
	pause
	clear
	return
}

list_fw_bydroplet(){
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet ID: " a1
	while [[ "$a1" == "help" ]] || [[ "$a1" == "" ]];
	do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Droplet ID: " a1
	done
		for i in ${droplet[$a1]};
	do
	echo "${droplet[$a1]}"
	done
	$doctl compute firewall list-by-droplet "${droplet[$a1]}" -o json | sed "s/{//g;s/}//g;s/\[//g;s/\]//g;s/,//g;s/\"//g;/^[[:space:]]*$/d"
	pause
	clear
	return
}

list_rules_bydroplet(){
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet ID: " a1
	while [[ "$a1" == "help" ]] || [[ "$a1" == "" ]];
	do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Droplet ID: " a1
	done
	for i in ${droplet[$a1]};
	do
		echo "${droplet[$a1]}"
	done
	$doctl compute firewall list-by-droplet "${droplet[$a1]}" --format Name,InboundRules -o json | sed "s/{//g;s/}//g;s/\[//g;s/\]//g;s/,//g;s/\"//g;/^[[:space:]]*$/d"
	$doctl compute firewall list-by-droplet "${droplet[$a1]}" --format Name,OutboundRules -o json | sed "s/{//g;s/}//g;s/\[//g;s/\]//g;s/,//g;s/\"//g;/^[[:space:]]*$/d"
	pause
	clear
	return
}

create_fw(){
	read -rp "Firewall name: " a1
	$doctl compute firewall create --name "$a1" --inbound-rules protocol:ICMP
	pause
	clear
	return
}

delete_fw(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall name: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	$doctl compute firewall delete "${firewall[$a1]}"
	pause
	clear
	return
}

add_rule(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	read -rp "Inbound rules (if none, leave empty): " a2
	read -rp "Outbound rules (if none, leave empty): " a3
	if [[ "$a2" == "" ]]; then
		$doctl compute firewall add-rules "${firewall[$a1]}" --outbound-rules "$a3"
	fi
	if [[ "$a3" == "" ]]; then
		$doctl compute firewall add-rules "${firewall[$a1]}" --inbound-rules "$a2"
	fi
	if [[ "$a2" != "" ]] && [[ "$a3" != "" ]]; then
	$doctl compute firewall add-rules "${firewall[$a1]}" --inbound-rules "$a2" --outbound-rules "$a3"
	fi
	pause
	clear
	return
}

remove_rule(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	read -rp "Inbound rules (if none, leave empty): " a2
	read -rp "Outbound rules (if none, leave empty): " a3
	if [[ "$a2" == "" ]]; then
		$doctl compute firewall remove-rules "${firewall[$a1]}" --outbound-rules "$a3"
	fi
	if [[ "$a3" == "" ]]; then
		$doctl compute firewall remove-rules "${firewall[$a1]}" --inbound-rules "$a2"
	fi
	if [[ "$a2" != "" ]] && [[ "$a3" != "" ]]; then
	$doctl compute firewall remove-rules "${firewall[$a1]}" --inbound-rules "$a2" --outbound-rules "$a3"
	fi
	pause
	clear
	return
}

add_droplet(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet ID(s): " a2
	while [[ "$a2" == "" ]] || [[ "$a2" == "help" ]];
	do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Droplet ID(s): " a2
	done
	for i in ${droplet[$a2]};
	do
		echo "${droplet[$a2]}"
	done
	$doctl compute firewall add-droplets "${firewall[$a1]}" --droplet-ids "${droplet[$a2]}"
	pause
	clear
	return
}

remove_droplet(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Droplet ID(s): " a2
	while [[ "$a2" == "" ]] || [[ "$a2" == "help" ]];
	do
		$doctl compute droplet list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Droplet ID(s): " a2
	done
	for i in ${droplet[$a2]};
	do
		echo "${droplet[$a2]}"
	done
	$doctl compute firewall remove-droplets "${firewall[$a1]}" --droplet-ids "${droplet[$a2]}"
	pause
	clear
	return
}

update_fw(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID: " a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	read -rp "Firewall name: " a2
	while [[ "$a2" == "" ]] || [[ "$a2" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name
		read -rp "Firewall name: " a2
	done
	read -rp "Inbound rules (if none, leave empty): " a3
	read -rp "Outbound rules (if none, leave empty): " a4
	if [[ "$a3" == "" ]]; then
	$doctl compute firewall update "${firewall[$a1]}" --name "$a2" --outbound-rules "$a4"
fi
	if [[ "$a4" == "" ]]; then
		$doctl compute firewall update "${firewall[$a1]}" --name "$a2" --inbound-rules "$a3"
	fi
	if [[ "$a3" != "" ]] && [[ "$a4" != "" ]]; then
		$doctl compute firewall update "${firewall[$a1]}" --name "$a2" --inbound-rules "$a3" --outbound-rules "$a4"
	fi
	pause
	clear
	return
}

add_tags(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID" a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	read -rp "Tag name(s): " a2
	$doctl compute firewall add-tags "${firewall[$a1]}" --tag-names "$a2"
	pause
	clear
	return
}

remove_tags(){
	$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
	read -rp "Firewall ID" a1
	while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
	do
		$doctl compute firewall list --format ID,Name | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Firewall ID: " a1
	done
	for i in ${firewall[$a1]};
	do
		echo "${firewall[$a1]}"
	done
	read -rp "Tag name(s): " a2
	$doctl compute firewall remove-tags "${firewall[$a1]}" --tag-names "$a2"
	pause
	clear
	return
}

# Call to functions
case "$input" in
	1) list_fw
		;;
	2) list_fw_bydroplet
		;;
	3) list_rules_bydroplet
		;;
	4) create_fw
		;;
	5) delete_fw
		;;
	6) add_rule
		;;
	7) remove_rule
		;;
	8) add_droplet
		;;
	9) remove_droplet
		;;
	10) update_fw
		;;
	11) add_tags
		;;
	12) remove_tags
		;;
esac

done
