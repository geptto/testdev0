#!/bin/bash -e

#Revert the hostname setup
sudo rm /etc/hostname
sudo mv /etc/hostname.bak /etc/hostname

#Revert persistent names to the wireless cards
sudo rm /etc/udev/rules.d/10-wifi.rules
