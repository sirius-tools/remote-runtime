#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_logs_collect() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local tail_lines="${3:-200}"
    ssh_exec "$h" "$(deploy_method_command "$h" logs_command "$tail_lines")" "$dry_run" | mask_output
  done <<< "$hosts"
}
