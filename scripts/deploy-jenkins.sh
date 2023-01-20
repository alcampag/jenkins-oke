#!/bin/bash

export KUBECONFIG=./kubeconfig

kubectl create secret docker-registry ocirsecret --docker-server=$REGISTRY_HOSTNAME --docker-username=$DOCKER_USERNAME --docker-password=$DOCKER_PASSWORD --docker-email=arch@oracle.com -n jenkins -o yaml --dry-run=client >> ocirsecret.yaml
kubectl create namespace jenkins -o yaml --dry-run=client >> namespace.yaml

kubectl apply -f namespace.yaml
kubectl apply -f ocirsecret.yaml
kubectl apply -f jenkins-oke.yaml