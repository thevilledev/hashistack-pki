variable "key_algorithm" {
    default = "ECDSA"
}

variable "ecdsa_curve" {
    default = "P384"
}

variable "sub_ca_csr" {
    type = "string"
}

variable "validity_period_hours" {
    default = 8760
}