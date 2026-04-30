#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_metrics() {
  local target="$1" dry_run="$2"
  local cmd="hostname; uptime; df -h; free -m || vm_stat; ss -lnt || netstat -lnt; docker --version || true"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    ssh_exec "$h" "$cmd" "$dry_run" | mask_output
  done <<< "$hosts"
}
