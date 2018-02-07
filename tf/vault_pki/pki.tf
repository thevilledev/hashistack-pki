# Mount PKI to /pki
resource "vault_mount" "pki" {
    path = "pki"
    type = "pki"
    default_lease_ttl_seconds = "864000"  # 10 days
    max_lease_ttl_seconds     = "2592000" # 30 days 
}

# Dirty hack as a workaround to init sub-CA in Vault
# See: https://github.com/terraform-providers/terraform-provider-vault/issues/67
data "external" "hack_intermediate_ca" {
    program = [ "bash", "${path.module}/scripts/hack_intermediate_ca.sh" ]
}

#resource "vault_generic_secret" "intermediate_ca" {
#    path = "${vault_mount.pki.path}/intermediate/generate/internal"
#    disable_read = true
#    data_json = <<EOF
#{
#    "common_name": "Sub-CA for HashiStack PKI",
#    "key_type": "${var.key_type}",
#    "key_bits": "${var.key_bits}",
#    "exclude_cn_from_sans": true
#}
#EOF
#}

resource "vault_generic_secret" "set_sub_ca" {
    path = "${vault_mount.pki.path}/intermediate/set-signed"
    disable_read = true
    data_json = <<EOF
{
    "certificate": "${join("\\n", split("\n", var.sub_ca_crt))}"
}
EOF
}

# PKI role for services which want to issue certificates autonomously.
resource "vault_generic_secret" "service_consul_role" {
    path       = "${vault_mount.pki.path}/roles/service-consul"
    depends_on = [ "vault_generic_secret.set_sub_ca" ]
    disable_read = true
    data_json  = <<EOF
{
  "allowed_domains": "service.consul",
  "allow_subdomains": true,
  "allow_glob_domains": false,
  "server_flag": true,
  "client_flag": false,
  "key_type": "${var.key_type}",
  "key_bits": "${var.key_bits}"
}
EOF
}

# PKI role for load balancers, that will contacted
# by using prepared queries in Consul. This means
# that glob domains must be supported, so that
# $whatever-mylb.query.consul certificates can be issued.
resource "vault_generic_secret" "query_consul_role" {
    depends_on = [ "vault_generic_secret.set_sub_ca" ]
    path = "${vault_mount.pki.path}/roles/query-consul"
    disable_read = true
    data_json = <<EOF
{
  "allowed_domains": "query.consul",
  "allow_subdomains": true,
  "allow_glob_domains": true,
  "server_flag": true,
  "client_flag": false,
  "key_type": "${var.key_type}",
  "key_bits": "${var.key_bits}"
}
EOF
}

output "sub_ca_csr" {
    value = "${data.external.hack_intermediate_ca.result.csr}"
}