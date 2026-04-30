#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

resolve_hosts() {
  local target="$1"
  build_compiled_configs >/dev/null

  if yq eval -e ".hosts.\"$target\"" "$CFG_DIR/inventory.yaml" >/dev/null 2>&1; then
    echo "$target"; return 0
  fi

  case "$target" in
    env:*)
      yq eval ".environments.\"${target#env:}\".hosts[]" "$CFG_DIR/environments.yaml" 2>/dev/null || true
      ;;
    label:*)
      yq eval ".hosts | to_entries[] | select(.value.labels[] == \"${target#label:}\") | .key" "$CFG_DIR/inventory.yaml" 2>/dev/null || true
      ;;
    role:*|type:*|provider:*|location:*)
      local k="${target%%:*}" v="${target#*:}"
      yq eval ".hosts | to_entries[] | select(.value.$k == \"$v\") | .key" "$CFG_DIR/inventory.yaml" 2>/dev/null || true
      ;;
    *)
      true
      ;;
  esac | awk 'NF' | sort -u
}

suggest_targets() {
  yq eval '.hosts | keys | .[]' "$CFG_DIR/inventory.yaml" 2>/dev/null || true
}
