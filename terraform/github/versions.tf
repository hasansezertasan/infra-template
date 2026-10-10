terraform {
  required_version = "1.16.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13.0"
    }
  }

  cloud {
    organization = "replace-with-hcp-org"

    workspaces {
      name = "github-org"
    }
  }
}
