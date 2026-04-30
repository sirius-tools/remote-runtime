#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_backup() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd
    wd="$(host_var "$h" workdir)"
    ssh_exec "$h" "mkdir -p $wd/backups && tar -czf $wd/backups/backup-\$(date +%Y%m%d%H%M%S).tgz -C $wd current shared metadata 2>/dev/null || true" "$dry_run" | mask_output
  done <<< "$hosts"
}
