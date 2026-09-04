#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel)
config="$root/.infra-copilot/config.md"

if [[ ! -f "$config" ]]; then
  printf 'missing %s; create it from .infra-copilot/config.md.example first\n' "$config" >&2
  exit 1
fi

hcp_org=$(sed -nE 's/^hcp_org:[[:space:]]*"?([^"[:space:]]+)"?[[:space:]]*$/\1/p' "$config")
if [[ -z "$hcp_org" || "$hcp_org" == replace-with-* ]]; then
  printf 'hcp_org must be filled in before syncing Terraform\n' >&2
  exit 1
fi

if [[ ! "$hcp_org" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
  printf 'hcp_org contains characters that are unsafe for an HCP organization slug\n' >&2
  exit 1
fi

paths=(
  "$root/terraform/cloudflare/versions.tf"
  "$root/terraform/github/versions.tf"
)

for path in "${paths[@]}"; do
  if [[ $(grep -Ec '^[[:space:]]+organization[[:space:]]*=' "$path") -ne 1 ]]; then
    printf '%s must contain exactly one cloud organization assignment\n' "$path" >&2
    exit 1
  fi

  temporary=$(mktemp "${path}.tmp.XXXXXX")
  trap 'rm -f -- "$temporary"' EXIT
  awk -v organization="$hcp_org" '
    /^[[:space:]]+organization[[:space:]]*=/ {
      print "    organization = \"" organization "\""
      next
    }
    { print }
  ' "$path" > "$temporary"
  mv -- "$temporary" "$path"
  trap - EXIT
done

mise exec -- terraform -chdir="$root/terraform/cloudflare" fmt versions.tf
mise exec -- terraform -chdir="$root/terraform/github" fmt versions.tf

printf 'Terraform cloud organization synchronized to %s\n' "$hcp_org"
