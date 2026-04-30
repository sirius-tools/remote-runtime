#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_exec() {
  local target="$1" dry_run="$2" cmd="$3"
  build_compiled_configs >/dev/null
  check_dangerous_command "$cmd" || return 1
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    ssh_exec "$h" "$cmd" "$dry_run" | mask_output
  done <<< "$hosts"
}
