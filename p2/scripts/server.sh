#!/usr/bin/env bash

set -euo pipefail

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

if [[ ! -s /vagrant/confs/app1.yaml || ! -s /vagrant/confs/app2.yaml \
    || ! -s /vagrant/confs/app3.yaml || ! -s /vagrant/confs/ingress.yaml ]]; then
    echo "Error: Configuration files absent" >&2
    exit 1
fi

sudo kubectl apply -f /vagrant/confs/app1.yaml
sudo kubectl apply -f /vagrant/confs/app2.yaml
sudo kubectl apply -f /vagrant/confs/app3.yaml
sudo kubectl apply -f /vagrant/confs/ingress.yaml

exit 0