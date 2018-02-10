job "lb" {
    type = "service"
    datacenters = [ "dc1" ]
    group "fabio" {
        count = 1
        task "fabio" {
            driver = "docker"
            config {
                image = "fabiolb/fabio:1.5.7-go1.9.4"
                port_map = {
                    http = 8080
                    https = 8443
                    ui = 9998
                }
                command = "/fabio"
                args = [
                    "-cfg", "/local/fabio.properties"
                ]
            }
            template {
                destination = "local/fabio.properties"
                perms = "755"
                data = <<EOD
registry.consul.addr = ${NOMAD_IP_http}:8500
proxy.addr = :8080,:8443;cs=vault-pki;tlsmin=tls12;tlsmax=tls12
proxy.cs = cs=vault-pki;type=vault-pki;cert=pki/issue/query-consul;refresh=24h
registry.consul.register.enabled = false
EOD
        }
        env {
          VAULT_ADDR = "http://${NOMAD_IP_http}:8200"
        }

      service {
        name = "lb-ui"
        port = "ui"
      }

      service {
          name = "lb-http"
          port = "http"
      }

      service {
          name = "lb-https"
          port = "https"
      }

      resources {
        cpu = 100
        memory = 128
        network {
          mbits = 5
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
          port "ui" {
            static = 8998
          }
        }
      }
      vault {
        policies = ["pki-lb"]
      }
    }
  }
}
