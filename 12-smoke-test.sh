#!/bin/bash

POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

kubectl exec -ti $POD_NAME -- nslookup kubernetes

kubectl apply -f demo/azure-vote-all-in-one-redis.yaml

external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for azure-vote-front ip..."
  external_ip=$(kubectl get svc azure-vote-front --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done

curl $external_ip > /dev/null
echo 'End point ready:' && echo $external_ip
