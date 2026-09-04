locals {
  config_path          = "${path.root}/../../.infra-copilot/config.md"
  config_example_path  = "${path.root}/../../.infra-copilot/config.md.example"
  config_document      = file(fileexists(local.config_path) ? local.config_path : local.config_example_path)
  infra_copilot_config = yamldecode(trimspace(split("---", local.config_document)[1]))
  managed_repositories = toset([
    for repository in local.infra_copilot_config.managed_repos : split("/", repository)[1]
  ])
}

# These read-only lookups prove that the GitHub App can access every configured
# repository. Add managed resources in separate, purpose-named files after setup.
data "github_repository" "managed" {
  for_each = local.managed_repositories
  name     = each.value
}

check "github_owner_matches_config" {
  assert {
    condition     = var.github_owner == local.infra_copilot_config.github_org
    error_message = "github_owner must match github_org in .infra-copilot/config.md."
  }
}
