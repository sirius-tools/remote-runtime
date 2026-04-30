#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"
source "$(dirname "${BASH_SOURCE[0]}")/status.sh"
source "$(dirname "${BASH_SOURCE[0]}")/metrics.sh"
source "$(dirname "${BASH_SOURCE[0]}")/health.sh"
source "$(dirname "${BASH_SOURCE[0]}")/logs.sh"

action_diagnose() {
  local target="$1" dry_run="$2"
  action_status "$target" "$dry_run"
  action_metrics "$target" "$dry_run"
  action_health "$target" "$dry_run" "false" "10"
  action_logs "$target" "$dry_run" "100" "false"
}
