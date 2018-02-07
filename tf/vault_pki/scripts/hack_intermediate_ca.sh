#!/bin/bash

VAULT_URL="http://vault.service.consul:8200/v1/pki/intermediate/generate/internal"

curl -sX PUT \
	-H "X-Vault-Token: ${VAULT_TOKEN}" \
	-d '{"common_name":"Sub-CA for HashiStack PKI","exclude_cn_from_sans":true,"key_bits":"384","key_type":"ec"}' \
    ${VAULT_URL} | jq -Mcr '.data'
