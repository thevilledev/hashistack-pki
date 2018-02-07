provider "vault" {
  address = "http://vault.service.consul:8200"
}

provider "external" {}

provider "tls" {}

terraform {
  backend "consul" {
    address = "consul.service.consul:8500"
    path    = "terraform/hashistack-pki.tfstate"
  }
}