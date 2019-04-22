#!/bin/bash

for instance in controller-0 controller-1 controller-2; do
  PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
    -n ${instance}-pip --query "ipAddress" -otsv)

  scp -o StrictHostKeyChecking=no 06-script.sh kuberoot@${PUBLIC_IP_ADDRESS}:~/
  ssh kuberoot@${PUBLIC_IP_ADDRESS} 'bash 06-script.sh' &
done
wait

sleep 30

CONTROLLER="controller-0"
PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
  -n ${CONTROLLER}-pip --query "ipAddress" -otsv)

ssh kuberoot@${PUBLIC_IP_ADDRESS} 'kubectl get componentstatuses'
