#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_logs() {
  local target="$1" dry_run="$2" tail="$3" follow="$4"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local cmd
    cmd="$(deploy_method_command "$h" logs_command "$tail")"
    [[ "$follow" == "true" ]] && cmd+=" -f"
    ssh_exec "$h" "$cmd" "$dry_run" | mask_output
  done <<< "$hosts"
}
