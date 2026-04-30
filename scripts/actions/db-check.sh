#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_db_check() {
  local target="$1" dry_run="${2:-true}"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    ssh_exec "$h" "command -v pg_isready >/dev/null && pg_isready || command -v mysqladmin >/dev/null && mysqladmin ping || echo 'no db health tool found'" "$dry_run" | mask_output
  done <<< "$hosts"
}
