#!/bin/bash

set -euo pipefail

sudo apt update
sudo apt install -y ca-certificates curl
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc \
    docker-buildx podman-docker containerd runc

# Versions
DOCKER_VERSION="5:29.9.2-1~ubuntu.26.04~resolute"
K3D_VERSION="v5.9.0" #K3S v1.35
KUBECTL_VERSION="v1.35.5"
ARGOCD_VERSION="v3.5.0"

#========== Installation de docker ================================================================#

# Ajout des clefs GPG officielles de docker
sudo apt update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Ajout du repo docker a apt
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Installation de docker
sudo apt update
sudo apt install -y docker-ce=${DOCKER_VERSION} docker-ce-cli=${DOCKER_VERSION} \
    containerd.io docker-buildx-plugin docker-compose-plugin

# Test d'installation Docker
max_attempts=6
attempt=1

while ! sudo systemctl is-active --quiet docker; do
    if (( attempt > max_attempts )); then
        echo "Failed to start docker service." >&2
        exit 1
    fi
    echo "Docker service is not active. Starting it ..."
    if ! sudo systemctl start docker; then
        echo "Docker failed to start; retrying..." >&2
    fi
    sleep 5
    attempt=$((attempt + 1))
done

echo "Docker engine installed and Docker service is active."

# Creation du groupe docker et ajout du user si absents
if ! getent group docker > /dev/null; then
    echo "Docker group doesn't exist" >&2
    echo "Creating docker group"
    sudo groupadd docker
fi
if ! groups "${USER}" | grep docker; then
    echo "User is not in docker group" >&2
    echo "Adding user to docker group"
    sudo usermod -aG docker "${USER}"
    ## ATTENTION ICI, peut etre besoin de de deco/reco pour appliquer les modifs
fi


#========== Installation de K3D ===================================================================#

# Installation de k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=${K3D_VERSION} bash

# Test d'installation k3d
if ! command -v k3d > /dev/null; then
    echo "K3d installation failed" >&2
    exit 1
fi


#========== Installation de Kubectl ===============================================================#

# Installation de kubectl
curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -rf kubectl

# Test d'installation kubectl
if ! command -v kubectl > /dev/null; then
    echo "Kubectl installation failed" >&2
    exit 1
fi


#========== Installation de argoCD CLI ============================================================#

# Installation
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/"${ARGOCD_VERSION}"/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Test d'installation
if ! command -v argocd > /dev/null; then
    echo "ArgoCD CLI installation failed" >&2
    exit 1
fi
