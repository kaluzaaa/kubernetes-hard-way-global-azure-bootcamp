#!/bin/bash

echo "Creating resource group..."

az group create -n kubernetes -l westeurope

echo "Deploying infrastructure..."

SSH=$(cat ~/.ssh/id_rsa.pub)

az group deployment create -g kubernetes -n demo --template-file 01-infra.json --parameters sshKey="$SSH" --verbose
