#!/bin/bash -e

sudo apt-get install isc-dhcp-server hostapd || true

#Set the device hostname
sudo mv /etc/hostname /etc/hostname.old
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

sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.old
cat <<EOF | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="your network ssid"
        psk="your network password"
}
EOF
sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

sudo mv /etc/network/interfaces /etc/network/interfaces.old
cat <<EOF | sudo tee /etc/network/interfaces > /dev/null
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

allow-hotplug wifi0
iface wifi0 inet static
address 192.168.42.1
netmask 255.255.255.0

auto wifi1
allow-hotplug wifi1
iface wifi1 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

pre-up iptables-restore < /etc/iptables.ipv4.nat
EOF

sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.old
sudo sed -i: 's/^option domain-name/#option domain-name/g' /etc/dhcp/dhcpd.conf
sudo sed -i: 's/^#authoritative;/authoritative;/g' /etc/dhcp/dhcpd.conf
cat <<EOF | sudo tee -a /etc/dhcp/dhcpd.conf > /dev/null
subnet 192.168.42.0 netmask 255.255.255.0 {
range 192.168.42.10 192.168.42.50;
option broadcast-address 192.168.42.255;
option routers 192.168.42.1;
default-lease-time 600;
max-lease-time 7200;
option domain-name "local";
option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOF

sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.old
sudo sed -i: 's/^INTERFACES=""/INTERFACES="wifi0"/g' /etc/default/isc-dhcp-server

sudo cp /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.old
cat <<EOF | sudo tee /etc/hostapd/hostapd.conf > /dev/null
interface=wifi0
driver=nl80211
ssid=testdev0
#hw_mode=g
channel=4
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=1
wpa_passphrase=somepassword
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=TKIP CCMP
wpa_ptk_rekey=600
ieee80211n=0
eap_server=0
EOF
sudo chmod 600 /etc/hostapd/hostapd.conf

sudo cp /etc/default/hostapd /etc/default/hostapd.old
sudo sed -i: 's|^#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd

sudo cp /etc/sysctl.conf /etc/sysctl.conf.old
sudo sed -i: 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

sudo cp /etc/iptables.ipv4.nat /etc/iptables.ipv4.nat.old
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o wifi1 -j MASQUERADE
sudo iptables -A FORWARD -i wifi1 -o wifi0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wifi0 -o wifi1 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo testdev0 install script complete!
