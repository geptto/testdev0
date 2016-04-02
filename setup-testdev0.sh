#!/bin/bash -e

sudo mv /etc/hostname /etc/hostname.bak
cat <<EOF | sudo tee /etc/hostname > /dev/null
testdev0
EOF
sudo chmod 600 /etc/hostname
