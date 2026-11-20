#!/usr/bin/env bash

set -euo pipefail

SERVIP="192.168.56.110"
WORKIP="192.168.56.111"
URL="https://${SERVIP}:6443"
TOKEN_PATH="/var/www/sync_folder/token"

sudo apt-get update
sudo apt-get install -y curl

for i in {1..300}; do
    if [[ -s "${TOKEN_PATH}" ]] && curl -kfsS --connect-timeout 2 "${URL}/ping" > /dev/null; then
        break;
    fi
    echo "Waiting for K3S server: ${i}s" >&2
    sleep 1
done

if [[ ! -s "${TOKEN_PATH}" ]] || ! curl -kfsS --connect-timeout 2 "${URL}/ping" > /dev/null; then
    echo "Error: Token not found / API not ready" >&2
    exit 1
fi

echo "K3S server API is reachable, beginning agent installation"

TOKEN=$(sudo cat "${TOKEN_PATH}")
rm -rf "${TOKEN_PATH}"

curl -sfL https://get.k3s.io | \
    INSTALL_K3S_EXEC="agent --node-ip ${WORKIP} --flannel-iface eth1" \
    K3S_URL="${URL}" \
    K3S_TOKEN="${TOKEN}" \
    sh -

exit 0