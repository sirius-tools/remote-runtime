#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

is_protected_target() {
  local target="$1"
  [[ "$target" == env:* ]] || return 1
  local env="${target#env:}"
  [[ "$(yq eval ".environments.\"$env\".protected" "$CFG_DIR/environments.yaml" 2>/dev/null || echo false)" == "true" ]]
}

check_dangerous_command() {
  local cmd="$1"
  local p
  while IFS= read -r p; do
    [[ -z "$p" || "$p" == "null" ]] && continue
    if [[ "$cmd" == *"$p"* ]]; then
      echo "blocked dangerous command pattern: $p" >&2
      return 1
    fi
  done < <(yq eval '.policies.commands.dangerous_patterns[]' "$CFG_DIR/policies.yaml")
  return 0
}
