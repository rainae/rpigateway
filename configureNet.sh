#!/bin/bash

ip link set dev wlan0 down
ip link set dev wlan1 down
ip link set dev wlan0 name wlan0_ap
ip link set dev wlan1 name wlan0_uplink

systemctl restart networking
systemctl start hostapd

ip a add 192.168.100.1/24 dev wlan0_ap
wpa_supplicant -B  -i wlan0_uplink -c /etc/wpa_supplicant/wpa_supplicant.conf
dhclient wlan0_uplink
systemctl restart dnsmasq

ip link set dev eth0 up
ip a add 192.168.101.1/24 dev eth0

iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o wlan0_uplink -j MASQUERADE

openvpn --config /home/pi/workspace/rpigateway/ksedge.ovpn --daemon

cd /home/pi/workspace/rpigateway

docker-compose up -d
