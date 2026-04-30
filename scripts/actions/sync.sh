#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_sync() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd
    wd="$(host_var "$h" workdir)"
    ssh_exec "$h" "mkdir -p $wd/shared $wd/logs $wd/metadata" "$dry_run" | mask_output
  done <<< "$hosts"
}
