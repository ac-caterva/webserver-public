#!/bin/bash -x
#
# - Ethernet Adapter eth0 mit Adresse 192.168.0.50 konfigurieren
# - Route zur Caterva einrichten

sudo ifconfig eth0 down
sudo ifconfig eth0 192.168.0.50 netmask 255.255.255.0 up
sudo ifconfig eth0
#AC# sudo route add 192.168.0.222 eth0
sudo route add -net 192.168.0.0 netmask 255.255.255.0 dev eth0
sudo netstat -r
