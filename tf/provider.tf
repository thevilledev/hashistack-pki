provider "vault" {
  address = "http://vault.service.consul:8200"
}

provider "consul" {
  datacenter = "dc1"
  address    = "consul.service.consul:8500"
}

provider "external" {}

provider "tls" {}

provider "template" {}

terraform {
  backend "consul" {
    address = "consul.service.consul:8500"
    path    = "terraform/hashistack-pki.tfstate"
  }
}
