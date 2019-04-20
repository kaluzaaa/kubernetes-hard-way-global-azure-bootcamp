#!/bin/bash

RG=gab
L=eastus
OS="Canonical:UbuntuServer:18.04-LTS:18.04.201904020"

# ResourceGroup

az group create -g ${RG} -l ${L}

# Network

az network vnet create -g ${RG} \
    -n kubernetes-vnet \
    --address-prefix 10.240.0.0/16 \
    --subnet-name k8s-master \
    --subnet-prefixes 10.240.0.0/24 

az network vnet subnet create -g ${RG} \
    --vnet-name kubernetes-vnet \
    -n k8s-workers \
    --address-prefixes 10.240.1.0/24

# Master 

az network public-ip create -g ${RG} \
    --n master-ip \
    --allocation-method Static

az network nic create -g ${RG} \
    --name master-nic \
    --public-ip-address master-ip \
    --private-ip-address 10.240.0.4 \
    --vnet-name kubernetes-vnet \
    --subnet k8s-master

for i in {1..10}; do
    az network nic ip-config create -g ${RG} \
        --nic-name master-nic \
        --name ipconfig$((i+1)) \
        --vnet-name kubernetes-vnet \
        --subnet k8s-master
done

az vm create -g ${RG} \
    -n master \
    --image ${OS} \
    --nics master-nic \
    --nsg '' \
    --admin-username 'kuberoot'
