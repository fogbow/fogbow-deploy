#!/bin/sh
set -e
apt install strongswan -y
apt install opensc -y
apt install libgmp10 -y
apt install libgmp-dev -y
apt install libssl-dev -y
echo ": PSK 'vpn_password'" > /etc/ipsec.secrets
ipsec rereadsecrets
