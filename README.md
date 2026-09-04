# Infrastructure

Terraform-managed Cloudflare and GitHub infrastructure, designed to be bootstrapped and
maintained with [infra-copilot](https://github.com/hasansezertasan/infra-copilot).

## Start here

1. Create a new repository from this GitHub template.
2. Install infra-copilot using its current installation instructions.
3. Ask your agent to use infra-copilot to set up the repository. It will stop for the
   public identifiers needed to create `.infra-copilot/config.md`.
4. After the config is filled, run `./scripts/sync-config.sh` to bind both Terraform
   roots to the configured HCP organization.

Do not commit credentials. Public deployment identifiers belong in
`.infra-copilot/config.md`; API tokens and GitHub App credentials belong only in the
corresponding HCP Terraform workspace. For a manual start, copy
`.infra-copilot/config.md.example` to `.infra-copilot/config.md`, replace every
`replace-with-*` value, and run the synchronization script.

## Shape

Each directory below is an independent Terraform root with its own state and provider
lock file:

| Directory | HCP workspace | Initial responsibility |
|---|---|---|
| `terraform/cloudflare` | `cloudflare` | Verify access to the configured Cloudflare zone |
| `terraform/github` | `github-org` | Verify access to the configured GitHub repositories |

The initial data sources are read-only credential probes. Add managed resources with
infra-copilot after setup. If a resource already exists, import it before applying.

## Development

Review `mise.toml` before trusting it, then install the committed toolchain:

```sh
mise trust mise.toml
MISE_LOCKED=1 mise install terraform gh jq
mise exec -- make check
```

HCP Terraform creates plans through its VCS integration. GitHub Actions runs only
credential-free formatting, validation, and template-contract checks. Applies require
manual confirmation in HCP Terraform.
