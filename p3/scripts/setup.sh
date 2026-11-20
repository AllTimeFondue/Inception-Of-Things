#!/bin/bash

set -euo pipefail

ARGOCD_VERSION="v3.5.0"

#========== Creation du cluster K3D ===============================================================#
k3d cluster delete tlebonIotP3
k3d cluster create tlebonIotP3 -p "8081:8887@loadbalancer"

# Creation des namespaces
kubectl create namespace dev
kubectl create namespace argocd

# Installation d'argoCD dans le cluster
kubectl -n argocd apply --server-side --force-conflicts -f \
    https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml

# Attendre que tout soit up
kubectl -n argocd wait \
    --for=condition=available deployment/argocd-server \
    --timeout 5m


#========== Setup de argoCD =======================================================================#

# On applique le manifeste de type Application pour qu'argoCD suive le repo et deploie l'app
kubectl config set-context --current --namespace argocd

kubectl apply -f "./confs/Application.yaml"

# Affichage du mot de passe initial pour se connecter
# Ici on doit garder que la premiere ligne car la commande affiche des informations supplementaires
ARGOCD_PASSWD="$(argocd admin initial-password | head -n 1)"
echo "Here is the admin initial password: ${ARGOCD_PASSWD}"

echo "To connect to argoCD, please run: \
        kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "You can then access argoCD in your browser via: https://localhost:8080/"
echo "If you want to access argoCD CLI, please run: \
        argocd login localhost:8080 --username admin --password <ADMIN_PASSWD> --insecure"
