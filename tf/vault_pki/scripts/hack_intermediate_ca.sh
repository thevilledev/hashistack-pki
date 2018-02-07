#!/bin/bash

set -e

VAULT_CHECK_MOUNTS="${VAULT_ADDR}/v1/sys/mounts"
VAULT_GEN_CA="${VAULT_ADDR}/v1/pki/intermediate/generate/internal"

IS_MOUNT_ACTIVE="$(curl -sH "X-Vault-Token: ${VAULT_TOKEN}" vault.service.consul:8200/v1/sys/mounts| jq -Mr '.data."pki/"')"
[[ "${IS_MOUNT_ACTIVE}" == "null" ]] && echo '{"csr": "foo"}' && exit 0

curl -vvvsX PUT \
	-H "X-Vault-Token: ${VAULT_TOKEN}" \
	-d '{"common_name":"Sub-CA for HashiStack PKI","exclude_cn_from_sans":true,"key_bits":"384","key_type":"ec"}' \
    ${VAULT_GEN_CA} | jq -Mcr '.data'
