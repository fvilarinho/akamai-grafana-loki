# Terraform definition.
terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }

    null = {
      source = "hashicorp/null"
    }

    local = {
      source = "hashicorp/local"
    }

    external = {
      source = "hashicorp/external"
    }

    http = {
      source = "hashicorp/http"
    }
  }
}

# Akamai Cloud Computing provider definition.
provider "linode" {
  token = var.credentials.token
}
