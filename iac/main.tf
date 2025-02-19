# Terraform definition.
terraform {
  # Stores the provisioning state in Akamai Cloud Computing Object Storage (Please change to use your own).
  backend "s3" {
    bucket                      = "fvilarin-devops"
    key                         = "akamai-grafana-loki.tfstate"
    region                      = "us-east-1"
    endpoint                    = "us-east-1.linodeobjects.com"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }

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