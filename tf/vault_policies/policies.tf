data "template_file" "lb_policy_file" {
    template = "${file("${path.module}/policies/lb.hcl.tmpl")}"
}

data "template_file" "service_policy_file" {
    template = "${file("${path.module}/policies/service.hcl.tmpl")}"
}

resource "vault_policy" "lb_policy" {
    name = "pki-lb"
    policy = "${data.template_file.lb_policy_file.rendered}"
}

resource "vault_policy" "service_policy" {
    name = "pki-service"
    policy = "${data.template_file.service_policy_file.rendered}"
}