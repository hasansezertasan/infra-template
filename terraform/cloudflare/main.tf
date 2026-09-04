locals {
  config_path          = "${path.root}/../../.infra-copilot/config.md"
  config_example_path  = "${path.root}/../../.infra-copilot/config.md.example"
  config_document      = file(fileexists(local.config_path) ? local.config_path : local.config_example_path)
  infra_copilot_config = yamldecode(trimspace(split("---", local.config_document)[1]))
}

# This read-only lookup proves that the HCP workspace token can access the configured
# zone. Add managed resources in separate, purpose-named files after setup.
data "cloudflare_zone" "configured" {
  zone_id = local.infra_copilot_config.cloudflare_zone_id
}

check "cloudflare_zone_matches_config" {
  assert {
    condition = (
      data.cloudflare_zone.configured.name == local.infra_copilot_config.apex_domain &&
      data.cloudflare_zone.configured.account.id == local.infra_copilot_config.cloudflare_account_id
    )
    error_message = "The configured Cloudflare zone, domain, and account do not match."
  }
}
