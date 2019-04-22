#!/bin/bash

cd certs

KUBERNETES_PUBLIC_ADDRESS=$(az network public-ip show -g kubernetes \
  -n kubernetes-pip --query ipAddress -otsv)

  kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem

  kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

  kubectl config use-context kubernetes-the-hard-way

kubectl get componentstatuses

kubectl get nodes

cd ..
