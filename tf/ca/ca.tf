resource "tls_private_key" "root" {
  algorithm   = "${var.key_algorithm}"
  ecdsa_curve = "${var.ecdsa_curve}"
}

resource "tls_self_signed_cert" "root" {
  key_algorithm         = "${var.key_algorithm}"
  private_key_pem       = "${tls_private_key.root.private_key_pem}"
  validity_period_hours = "${var.validity_period_hours}"
  is_ca_certificate     = true
  allowed_uses          = [ "crl_signing", "digital_signature", "key_encipherment", "cert_signing" ]
  subject {
      common_name       = "HashiStack PKI CA"
      organization      = "HashiStack Users 4ever"
  }
}