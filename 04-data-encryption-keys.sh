#!/bin/bash

cd certs

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

for instance in controller-0 controller-1 controller-2; do
  PUBLIC_IP_ADDRESS=$(az network public-ip show -g kubernetes \
    -n ${instance}-pip --query "ipAddress" -otsv)

  scp encryption-config.yaml kuberoot@${PUBLIC_IP_ADDRESS}:~/ &
done
wait

cd ..
