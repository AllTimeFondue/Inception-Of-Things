#!/bin/sh

pkill -f 'kubectl port-forward svc/argocd-server'
pgrep -af 'kubectl port-forward'

k3d cluster delete tlebonIotP3
k3d cluster list
kubectl config get-contexts
