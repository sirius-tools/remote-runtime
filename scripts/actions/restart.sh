#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_restart() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  if [[ "$dry_run" != "true" ]]; then
    acquire_lock "$target" || return 1
    trap 'release_lock "$target"' RETURN
  fi
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    ssh_exec "$h" "$(deploy_method_command "$h" restart_command)" "$dry_run" | mask_output
  done <<< "$hosts"
}
