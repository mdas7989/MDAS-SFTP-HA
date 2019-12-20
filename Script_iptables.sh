#!/bin/bash

###
# script to enable/disable firewall rule for SFTP port 
# This script take care of making SFTP server HA
###

iptablesview=`sudo iptables -S`


CheckStatus()
{
 		echo "Check if Firewall rule is enabled"
		echo "$iptablesview" 
}

DelRul()
{
		echo "Removing the firewall rule for port 2222 & Establishing SFTP service in this host."
		sudo iptables -D INPUT -p tcp --dport 2222 -m state --state NEW,ESTABLISHED -j DROP
		sudo /sbin/service iptables save
		echo "$iptablesview"
}

AddRule()
{
		echo "Enabling the firewall rule for port 2222 & Making SFTP service down in this host"
		sudo iptables -A INPUT -p tcp --dport 2222 -m state --state NEW,ESTABLISHED -j DROP
		sudo /sbin/service iptables save
		echo "$iptablesview"
}
