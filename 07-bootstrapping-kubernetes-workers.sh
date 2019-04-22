#!/bin/bash

CONTROLLER="controller-0"
PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
  -n ${CONTROLLER}-pip --query "ipAddress" -otsv)


  scp -o StrictHostKeyChecking=no 07-script.sh kuberoot@${PUBLIC_IP_ADDRESS}:~/

ssh kuberoot@${PUBLIC_IP_ADDRESS} 'bash 07-script.sh'
