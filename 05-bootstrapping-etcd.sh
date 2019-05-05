#!/bin/bash

for instance in controller-0 controller-1 controller-2; do
  PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
    -n ${instance}-pip --query "ipAddress" -otsv)

  scp -o StrictHostKeyChecking=no 05-script.sh kuberoot@${PUBLIC_IP_ADDRESS}:~/
  ssh kuberoot@${PUBLIC_IP_ADDRESS} 'bash 05-script.sh'
done
wait

PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
    -n controller-0-pip --query "ipAddress" -otsv)

ssh kuberoot@${PUBLIC_IP_ADDRESS} 'sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://${INTERNAL_IP}:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem'