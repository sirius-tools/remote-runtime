#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_report() {
  local target="$1" dry_run="${2:-true}"
  local hosts
  hosts="$(resolve_or_fail "$target" | paste -sd ',' -)"
  write_report "report" "$target" "dry_run: $dry_run
hosts: $hosts" >/dev/null
  echo "report generated for $target"
}
