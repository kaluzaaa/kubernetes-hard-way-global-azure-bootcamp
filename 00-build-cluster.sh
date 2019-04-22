#!/bin/bash
start=`date +%s`

bash 01-azure-infrastructure.sh
bash 02-certificate-authority.sh
bash 03-kubernetes-configuration-files.sh
bash 04-data-encryption-keys.sh
bash 05-bootstrapping-etcd.sh
bash 06-bootstrapping-kubernetes-controllers.sh
bash 07-kubelet-node-authorization.sh
bash 08-bootstrapping-kubernetes-workers.sh
bash 09-configuring-kubectl.sh
bash 10-pod-network-routes.sh
bash 11-smoke-test.sh

echo "Duration: $((($(date +%s)-$start)/60)) minutes"
