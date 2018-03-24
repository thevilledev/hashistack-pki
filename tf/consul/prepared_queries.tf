# Consul prepared queries for service discovery
#
# This resource ensures that every DNS query
# targeted to a service gets a DNS response
# which includes all healthy load balancer
# IP addresses. In short:
#
# app.service.consul maps to all Nomad clients
# running the actual service
#
# app-lb.query.consul maps to all load balancers,
# whic route traffic to app.service.consul

resource "consul_prepared_query" "lb" {
  # if our lb is unhealthy, no use responding
  # to dns queries
  only_passing = true

  # catch-all query string
  name = ""

  # respond to "${service_name}-lb.query.consul" queries
  # and catch service name to \1 match group
  template {
    type   = "name_prefix_match"
    regexp = "^(.+)-lb"
  }

  # Use HTTPS lb service
  service = "lb-https"
}
