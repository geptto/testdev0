#!/bin/bash -e

#Revert the hostname setup
sudo mv /etc/hostname.old /etc/hostname
sudo mv /etc/hosts.old /etc/hosts

#Revert persistent names to the wireless cards
sudo rm /etc/udev/rules.d/10-wifi.rules
sudo mv /etc/wpa_supplicant/wpa_supplicant.conf.old /etc/wpa_supplicant/wpa_supplicant.conf
sudo mv /etc/network/interfaces.old /etc/network/interfaces
sudo mv /etc/dhcp/dhcpd.conf.old /etc/dhcp/dhcpd.conf
sudo mv /etc/default/isc-dhcp-server.old /etc/default/isc-dhcp-server
sudo mv /etc/hostapd/hostapd.conf.old /etc/hostapd/hostapd.conf
sudo mv /etc/default/hostapd.old /etc/default/hostapd
sudo mv /etc/sysctl.conf.old /etc/sysctl.conf
sudo mv /etc/iptables.ipv4.nat.old /etc/iptables.ipv4.nat

sudo apt-get purge isc-dhcp-server hostapd || true
sudo apt-get autoremove || true
