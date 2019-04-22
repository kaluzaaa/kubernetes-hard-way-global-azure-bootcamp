#!/bin/bash

kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

sleep 20

kubectl get pods -l k8s-app=kube-dns -n kube-system

kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600

kubectl get pods -l run=busybox

sleep 20

POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

kubectl exec -ti $POD_NAME -- nslookup kubernetes
