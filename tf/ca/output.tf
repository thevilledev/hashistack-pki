output "sub_ca_crt" {
    value = "${tls_locally_signed_cert.sub_ca.cert_pem}"
}