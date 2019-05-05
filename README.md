# Kubernetes The Hard Way on Azure

This tutorial is designed for [Microsoft Azure](https://azure.microsoft.com) and [Azure CLI 2.0](https://github.com/azure/azure-cli).
It is a fork of the great [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) from [Kesley Hightower](https://twitter.com/kelseyhightower) that describes same steps using [Google Cloud Platform](https://cloud.google.com).

Azure part is based on the work done by [Jonathan Carter - @lostintangent](https://twitter.com/LostInTangent) in this [fork](https://github.com/lostintangent/kubernetes-the-hard-way) and [Ivan Fioravanti - @ivanfioravanti](https://twitter.com/ivanfioravanti) in this [fork](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/).

This tutorial walks you through setting up Kubernetes the hard way. This guide is not for people looking for a fully automated command to bring up a Kubernetes cluster. If that's you then check out [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/services/kubernetes-service/), or the [Getting Started Guides](http://kubernetes.io/docs/getting-started-guides).

Kubernetes The Hard Way is optimized for learning, which means taking the long route to ensure you understand each task required to bootstrap a Kubernetes cluster.

> The results of this tutorial should not be viewed as production ready, and may receive limited support from the community, but don't let that stop you from learning!

## Target Audience

The target audience for this tutorial is someone planning to support a production Kubernetes cluster and wants to understand how everything fits together.

## Cluster Details

Kubernetes The Hard Way guides you through bootstrapping a highly available Kubernetes cluster with end-to-end encryption between components and RBAC authentication.

* [Kubernetes](https://github.com/kubernetes/kubernetes) 1.14.1

## Prerequisites

* [Prerequisites](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/01-prerequisites.md)
* [Installing the Client Tools](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/02-client-tools.md)


## 01-azure-infrastructure.sh

This script creates the necessary infrastructure using ARM Template. 
The main difference between [Provisioning Compute Resources](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/03-compute-resources.md) is a setup system identity for Kubernetes master nodes. System Identity will be used to integrate the Kubernetes cloud provider with the Azure Resource Manager.

```json
{
    "copy": {
        "name": "controller-assignments-copy",
        "count": "[variables('controllerCount')]"
    },
    "apiVersion": "2017-09-01",
    "type": "Microsoft.Authorization/roleAssignments",
    "name": "[guid(resourceId('Microsoft.Compute/virtualMachines/', concat('controller-',copyIndex())))]",
    "properties": {
        "roleDefinitionId": "[variables(parameters('builtInRoleType'))]",
        "principalId": "[reference(resourceId('Microsoft.Compute/virtualMachines/', concat('controller-',copyIndex())), '2017-12-01', 'Full').identity.principalId]",
        "scope": "[resourceGroup().id]"
    },
    "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', concat('controller-',copyIndex()))]"
    ]
}
```

## 02-certificate-authority.sh

* [Provisioning the CA and Generating TLS Certificates](docs/04-certificate-authority.md)

## 03-kubernetes-configuration-files.sh

* [Generating Kubernetes Configuration Files for Authentication](docs/05-kubernetes-configuration-files.md)

## 04-data-encryption-keys.sh

* [Generating the Data Encryption Config and Key](docs/06-data-encryption-keys.md)

## 05-bootstrapping-etcd.sh

* [Bootstrapping the etcd Cluster](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/07-bootstrapping-etcd.md)

## 06-bootstrapping-kubernetes-controllers.sh

* [Bootstrapping the Kubernetes Control Plane](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/08-bootstrapping-kubernetes-controllers.md)

In addition, the Cloud Provider configuration for Azure appears here.

Necessary data are obtained from [Azure Instance Metadata service](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service).


```bash
response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s)
tenantId=$(echo $response | python -c 'import sys, json, base64; print (base64.b64decode(json.load(sys.stdin)["access_token"].split(".")[1]))' | python -c 'import sys, json, base64; print (json.load(sys.stdin)["tid"])')
subscriptionId=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2017-08-01&format=text")
location=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text")
```

Cloud Provider configuration through `/etc/kubernetes/azure.json` file. [Cloud provider config documentation](https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/cloud-provider-config.md).

```json
{
    "cloud": "AzurePublicCloud",
    "tenantId": "${tenantId}",
    "subscriptionId": "${subscriptionId}",
    "aadClientId": "msi",
    "aadClientSecret": "msi",
    "resourceGroup": "kubernetes",
    "location": "${location}",
    "vmType": "standard",
    "subnetName": "kubernetes-subnet",
    "securityGroupName": "kubernetes-nsg",
    "vnetName": "kubernetes-vnet",
    "primaryAvailabilitySetName": "worker-as",
    "cloudProviderBackoff": true,
    "cloudProviderBackoffRetries": 6,
    "cloudProviderBackoffExponent": 1.5,
    "cloudProviderBackoffDuration": 5,
    "cloudProviderBackoffJitter": 1,
    "cloudProviderRatelimit": true,
    "cloudProviderRateLimitQPS": 3,
    "cloudProviderRateLimitBucket": 10,
    "useManagedIdentityExtension": true,
    "userAssignedIdentityID": "",
    "useInstanceMetadata": true,
    "loadBalancerSku": "Basic",
    "excludeMasterFromStandardLB": false,
    "providerVaultName": "",
    "maximumLoadBalancerRuleCount": 250,
    "providerKeyName": "k8s",
    "providerKeyVersion": ""
}
```

## 07-kubelet-node-authorization.sh

* [RBAC for Kubelet Authorization](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/08-bootstrapping-kubernetes-controllers.md#rbac-for-kubelet-authorization)

## 08-bootstrapping-kubernetes-workers.sh

* [Bootstrapping the Kubernetes Worker Nodes](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/09-bootstrapping-kubernetes-workers.md)

## 09-configuring-kubectl.sh

* [Configuring kubectl for Remote Access](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/10-configuring-kubectl.md)

## 10-pod-network-routes.sh

* [Provisioning Pod Network Routes](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/11-pod-network-routes.md)

## 11-dns.sh

* [Deploying the DNS Cluster Add-on](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/12-dns-addon.md)

## 12-smoke-test.sh

* [Smoke Test](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/13-smoke-test.md)

Additionally, the smoke test shows service exposure via load balancer using the [Azure Voting App](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough).
