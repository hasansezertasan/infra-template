locals {
  config_path          = "${path.root}/../../.infra-copilot/config.md"
  config_example_path  = "${path.root}/../../.infra-copilot/config.md.example"
  config_document      = file(fileexists(local.config_path) ? local.config_path : local.config_example_path)
  infra_copilot_config = yamldecode(trimspace(split("---", local.config_document)[1]))
  managed_repositories = toset([
    for repository in local.infra_copilot_config.managed_repos : basename(repository)
  ])
}

# These read-only lookups prove that the GitHub App can access every configured
# repository. Add managed resources in separate, purpose-named files after setup.
data "github_repository" "managed" {
  for_each = local.managed_repositories
  name     = each.value

  lifecycle {
    precondition {
      condition = (
        var.github_owner == local.infra_copilot_config.github_org &&
        length(local.infra_copilot_config.managed_repos) > 0 &&
        alltrue([
          for repository in local.infra_copilot_config.managed_repos :
          length(regexall("/", repository)) == 1 &&
          startswith(repository, "${local.infra_copilot_config.github_org}/")
        ])
      )
      error_message = "github_owner and every managed_repos owner must match github_org."
    }
  }
}
