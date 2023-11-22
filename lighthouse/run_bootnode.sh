#!/usr/bin/env bash

#
# Generates a bootnode enr and saves it in $TESTNET/boot_enr.yaml
# Starts a bootnode from the generated enr.
#

set -Eeuo pipefail


echo "Generating bootnode enr"

EXTERNAL_IP=$(curl ipinfo.io/ip)
BOOTNODE_PORT=4242
if [ -d  /data/bootnode ]; then
    echo "genesis generator already run"
else

exec lcli \
	generate-bootnode-enr \
	--ip $EXTERNAL_IP \
	--udp-port $BOOTNODE_PORT \
	--tcp-port $BOOTNODE_PORT \
	--genesis-fork-version 0x10000007 \
	--output-dir /data/bootnode

fi


bootnode_enr=`cat /data/bootnode/enr.dat`
echo "- $bootnode_enr" > /config/boot_enr.yaml
# overwrite the static bootnode file too
echo "- $bootnode_enr" > /config/boot_enr.txt

echo "Generated bootnode enr - $bootnode_enr"

DEBUG_LEVEL=${1:-info}

echo "Starting bootnode"

exec lighthouse boot_node \
    --testnet-dir /config \
    --port $BOOTNODE_PORT \
    --listen-address 0.0.0.0 \
    --disable-packet-filter \
    --network-dir /data/bootnode \
