#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

validate_configs() {
  build_compiled_configs >/dev/null
  cfg_get inventory.yaml '.hosts' >/dev/null
  cfg_get environments.yaml '.environments' >/dev/null
  cfg_get tasks.yaml '.tasks' >/dev/null
  cfg_get policies.yaml '.policies' >/dev/null

  local bad
  bad="$(yq eval '.hosts[] | has("ip") or has("host") or has("hostname") or has("password") or has("token") or has("private_key")' "$CFG_DIR/inventory.yaml" | grep -E '^true$' || true)"
  [[ -n "$bad" ]] && die "inventory contains forbidden connection or secret field"

  bad="$(yq eval '.hosts | to_entries[] | select(.value.ssh_alias == null or .value.ssh_alias == "") | .key' "$CFG_DIR/inventory.yaml")"
  [[ -n "$bad" ]] && die "inventory host missing ssh_alias: $bad"

  bad=""
  local env_host
  while IFS= read -r env_host; do
    [[ -z "$env_host" || "$env_host" == "null" ]] && continue
    if ! yq eval -e ".hosts.\"$env_host\"" "$CFG_DIR/inventory.yaml" >/dev/null 2>&1; then
      bad+="${env_host}"$'\n'
    fi
  done < <(yq eval '.environments[].hosts[]?' "$CFG_DIR/environments.yaml" 2>/dev/null || true)
  [[ -n "$bad" ]] && die "environment references unknown host: $bad"

  info "config validate ok"
}
