#!/bin/bash

for instance in worker-0 worker-1 worker-2 ; do
  PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
    -n ${instance}-pip --query "ipAddress" -otsv)

  scp -o StrictHostKeyChecking=no certs/ca.pem 08-script.sh kuberoot@${PUBLIC_IP_ADDRESS}:~/

  ssh kuberoot@${PUBLIC_IP_ADDRESS} 'bash 08-script.sh' &
done
wait


CONTROLLER="controller-0"
PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
  -n ${CONTROLLER}-pip --query "ipAddress" -otsv)

sleep 10

ssh kuberoot@${PUBLIC_IP_ADDRESS} 'kubectl get nodes'
