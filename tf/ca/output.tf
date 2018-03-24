output "sub_ca_crt" {
    value = "${tls_locally_signed_cert.sub_ca.cert_pem}"
}

output "ca_crt" {
    value = "${tls_self_signed_cert.root.cert_pem}"
}