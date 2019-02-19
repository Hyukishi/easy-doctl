#!/bin/bash
# Created by Jeffery Grantham 02/11/2019
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
}

record_array(){
n=0
for i in $(doctl compute domain records list "$a1" --format ID)
do  ((n=n+1))
	if [[ "$i" == "ID" ]]; then
	((n=n-1))
	fi
echo "$i" >/dev/null 2>&1
record[$n]=$i
done
}

while [ "$input" != "quit" ]; do
	clear
	echo "What would you like to do?"
		echo "1: Create domain"
		echo "2: Delete domain"
		echo "3: Create record"
		echo "4: Delete record"
		echo "5: Print current DNS records"
		echo "6: Print current domains"
		echo "(Type \"quit\" to exit)"
		echo ""
	read -rp "Enter the corresponding number and press ENTER: " input
		clear

	create_domain(){
		read -rp "Domain name: " a1
		read -rp "Domain IP: " a2
		echo ""
		$doctl compute domain create "$a1" --ip-address "$a2"
		pause
		clear
		return
}
			if [[ "$input" == "1" ]]; then
			create_domain
		fi
	delete_domain(){
		read -rp "Domain Name: " a1
		echo ""
		$doctl compute domain delete "$a1"
		pause
		clear
		return
}
			if [[ "$input" == "2" ]]; then
			delete_domain
		fi

	create_record(){
		read -rp "Domain for record to be created under: " a0
		read -rp "Record type (A, CNAME): " a1
		a1="$(echo "$a1" | tr '[:lower:]' '[:upper:]')"
		read -rp "Record name (e.g. www): " a2
		if [[ "$a1" == "A" ]]; then
			read -rp "DigitalOcean Droplet IP: " a4
			$doctl compute domain records create --record-type "$a1" --record-name "$a2" --record-data "$a0" "$a4"
			pause
			clear
			return
		fi
		read -rp "FQDN of the domain: " a3
		echo ""
		$doctl compute domain records create "$a0" --record-type "$a1" --record-name "$a2" --record-data "$a3."
		pause
		clear
		return
}
		if [[ "$input" == "3" ]]; then
	create_record
	fi

	delete_record(){
		read -rp "Domain the record belongs to: " a1
		while [[ "$a1" == "" ]] || [[ "$a1" == "help" ]];
		do
			$doctl compute domain list
			echo ""
			read -rp "Domain the record belongs to: " a1
		done
			record_array
			$doctl compute domain records list "$a1" | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
		read -rp "Record ID: " a2
		while [[ "$a2" == "" ]] || [[ "$a2" == "help" ]];
		do
			$doctl compute domain records list "$a1" | awk 'BEGIN{i=0} /.*/{printf "%d. % s\n",i,$0; i++}'
			echo ""
			read -rp "Record ID: " a2
		done
		for i in ${record[$a2]};
		do
		echo "${record[$a2]}"
	done
		$doctl compute domain records delete "$a1" "${record[$a2]}"
		pause
		clear
		return
}
	if [[ "$input" == "4" ]]; then
	delete_record
	fi

	print_dnsrecords(){
	read -rp "Enter the domain for the records you want to print: " a1
	read -rp "Print to screen or dump to file: " a2
		if [[ "$a2" == "print"* ]] || [[ "$a2" == "screen" ]]; then
			$doctl compute domain records list "$a1"
			pause
			clear
			return
		fi
		if [[ "$a2" == "dump"* ]]; then
			$doctl compute domain records list "$a1" > "$HOME/Desktop/do-dns-records.txt"
			echo "The DNS records have been dumped to $HOME/Desktop/do-dns-records.txt"
			pause
			clear
			return
		fi
	}
	if [[ "$input" == "5" ]]; then
		print_dnsrecords
	fi

	print_domains(){
	read -rp "Print to screen or dump to file: " a1
		if [[ "$a1" == "print"* ]] || [[ "$a1" == "screen" ]]; then
			$doctl compute domain list
			pause
			clear
			return
		fi
		if [[ "$a1" == "dump"* ]]; then
			$doctl compute domain list  > $HOME/Desktop/do-dns-domains.txt
			echo "The DNS records have been dumped to $HOME/Desktop/do-dns-domains.txt"
			pause
			clear
			return
		fi
	}
	if [[ "$input" == "6" ]]; then
		print_domains
	fi

done

