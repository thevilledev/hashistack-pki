job "app" {
  type        = "service"
  datacenters = ["dc1"]

  group "app-group" {
    task "test-task" {
      driver = "docker"

      service {
        name = "testapp"
        tags = ["urlprefix-testapp-lb.query.consul/ proto=https tlsskipverify=true"]
        port = "http"

        check {
          type            = "http"
          protocol        = "https"
          tls_skip_verify = true
          path            = "/"
          interval        = "3s"
          timeout         = "3s"
        }
      }

      config {
        image = "vtorhonen/vault-pki-demo-app:latest"

        port_map {
          http = 18080
        }
      }

      env {
        VAULT_ADDR = "http://192.168.33.102:8200"
      }

      vault {
        policies = ["pki-service"]
      }

      resources {
        cpu    = 100
        memory = 32

        network {
          mbits = 1
          port  "http"{}
        }
      }
    }
  }
}
