variable "credentials" {
  default = {
    token = "<token>"
  }
}

variable "settings" {
  default = {
    label      = "akamai-grafana-loki"
    region     = "<region>"
    kubeconfig = "<kubeconfig-filename>"

    allowedIps = {
      ipv4 = [ "0.0.0.0/0" ]
      ipv6 = [ "::/0" ]
    }
  }
}