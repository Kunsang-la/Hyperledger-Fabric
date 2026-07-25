#!/bin/bash

# =====================================================
# Hyperledger Fabric Node Configuration Script
# =====================================================
HOSTNAME=$1
STATIC_IP=$2

if [ -z "$HOSTNAME" ] || [ -z "$STATIC_IP" ]; then
    echo "Usage:"
    echo "./setup-node.sh <hostname> <ip>"
    exit 1
fi

echo "===================================="
echo "Configuring node..."
echo "Hostname : $HOSTNAME"
echo "IP       : $STATIC_IP"
echo "===================================="

# Change hostname
sudo hostnamectl set-hostname "$HOSTNAME"

# Update hostname file
echo "$HOSTNAME" | sudo tee /etc/hostname >/dev/null

# Rewrite /etc/hosts
sudo tee /etc/hosts >/dev/null <<EOF
127.0.0.1 localhost
127.0.1.1 $HOSTNAME

192.168.56.101 orderer
192.168.56.102 org1-peer0
192.168.56.103 org1-peer1
192.168.56.104 org2-peer0
192.168.56.105 org2-peer1
192.168.56.106 org3-peer0
192.168.56.107 org3-peer1

::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# Configure Host-Only Adapter
sudo nmcli connection modify "Wired connection 2" \
ipv4.addresses ${STATIC_IP}/24 \
ipv4.method manual

sudo nmcli connection down "Wired connection 2"
sudo nmcli connection up "Wired connection 2"

echo
echo "===================================="
echo "Configuration Complete"
echo "Hostname : $(hostname)"
echo "IP Address:"
ip -4 addr show eth1 | grep inet
echo "===================================="
echo
echo "Please reboot:"
echo "sudo reboot"
