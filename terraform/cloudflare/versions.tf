terraform {
  required_version = "= 1.16.1"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.24"
    }
  }

  cloud {
    organization = "replace-with-hcp-org"

    workspaces {
      name = "cloudflare"
    }
  }
}
