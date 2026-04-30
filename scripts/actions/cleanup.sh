#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_cleanup() {
  local target="$1" dry_run="${2:-true}"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    ssh_exec "$h" "echo action cleanup on $h" "$dry_run" | mask_output
  done <<< "$hosts"
}
