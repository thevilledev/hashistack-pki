resource "tls_locally_signed_cert" "sub_ca" {
  cert_request_pem      = "${var.sub_ca_csr}"
  ca_key_algorithm      = "${tls_private_key.root.algorithm}"
  ca_private_key_pem    = "${tls_private_key.root.private_key_pem}"
  ca_cert_pem           = "${tls_self_signed_cert.root.cert_pem}"
  validity_period_hours = "${var.validity_period_hours}"
  is_ca_certificate     = true
  allowed_uses          = [ "crl_signing", "digital_signature", "key_encipherment", "cert_signing" ]
}