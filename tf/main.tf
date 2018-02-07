module "vault_pki" {
    source     = "./vault_pki"
    sub_ca_crt = "${module.ca.sub_ca_crt}"
}

module "ca" {
    source     = "./ca"
    sub_ca_csr = "${module.vault_pki.sub_ca_csr}"
}