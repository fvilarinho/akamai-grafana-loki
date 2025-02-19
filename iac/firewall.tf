locals {
  allowedIpv4 = concat(var.settings.allowedIps.ipv4, [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
  allowedIpv6 = concat(var.settings.allowedIps.ipv6, [ "::1/128" ])
}

data "http" "myIp" {
  url = "https://ipinfo.io"
}

resource "linode_firewall" "default" {
  label           = "${var.settings.label}-cnb-fw"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  nodebalancers = [
    data.external.fetchEndpoints.result.grafanaLoadBalancerId,
    data.external.fetchEndpoints.result.lokiIngestLoadBalancerId
  ]

  inbound {
    label    = "allow-external-ips"
    action   = "ACCEPT"
    protocol = "TCP"
    ipv4     = local.allowedIpv4
    ipv6     = local.allowedIpv6
  }

  depends_on = [
    data.http.myIp,
    data.external.fetchEndpoints
  ]
}