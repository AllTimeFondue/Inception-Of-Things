#!/usr/bin/env bash

set -euo pipefail

# -e arrete le script si erreur
# -u detecte les variables non definies
# -o pipefail renvoie le code d'erreur de la commande la plus a droite
# dans une pipeline

SERVIP="192.168.56.110"

sudo apt-get update
sudo apt-get install -y curl

sudo curl -sfL https://get.k3s.io | \
    K3S_KUBECONFIG_MODE="644" \
    INSTALL_K3S_EXEC="server --node-ip ${SERVIP} --flannel-iface eth1" \
    sh -

for _ in {1..120}; do
    if curl -kfsS --connect-timeout 2 "https://${SERVIP}:6443/ping" > /dev/null; then
        break;
    fi
    echo "Waiting for K3S API ..." >&2
    sleep 1
done;

if ! curl -kfsS --connect-timeout 2 "https://${SERVIP}:6443/ping" > /dev/null; then
    echo "Error: Failed to reach K3S API" >&2
    exit 1
fi

echo "K3S API is reachable"

sudo cp -f /var/lib/rancher/k3s/server/node-token /var/www/sync_folder/token.tmp
sudo mv -f /var/www/sync_folder/token.tmp /var/www/sync_folder/token

exit 0