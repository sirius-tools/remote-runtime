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
  bad="$(yq eval '.hosts[] | has("ip")' "$CFG_DIR/inventory.yaml" | rg '^true$' || true)"
  [[ -n "$bad" ]] && die "inventory contains forbidden ip field"

  info "config validate ok"
}
