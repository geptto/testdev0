#!/bin/bash -e

#Set the device hostname
sudo mv /etc/hostname /etc/hostname.bak
cat <<EOF | sudo tee /etc/hostname > /dev/null
testdev0
EOF
sudo chmod 644 /etc/hostname

#Set persistent names to the wireless cards
cat <<EOF | sudo tee /etc/udev/rules.d/10-wifi.rules > /dev/null
SUBSYSTEM=="net", ATTRS{idVendor}=="148f", ATTRS{idProduct}=="5370", NAME="wifi0"
SUBSYSTEM=="net", ATTRS{idVendor}=="148f", ATTRS{idProduct}=="7601", NAME="wifi1"
EOF
sudo chmod 644 /etc/udev/rules.d/10-wifi.rules
