#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_metrics() {
  local target="$1" dry_run="$2"
  local hosts h
  build_compiled_configs >/dev/null
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    local wd svc status_cmd cmd
    wd="$(host_var "$h" workdir)"
    svc="$(host_var "$h" service_name)"
    status_cmd="$(deploy_method_command "$h" status_command)"
    cmd="hostname; uptime; df -h; free -m || vm_stat; (uptime | awk -F'load averages?: ' '{print \$2}' || true); ss -lnt || netstat -lnt; docker --version || true; docker ps --format '{{.Names}} {{.Status}}' 2>/dev/null || true; $status_cmd || true; readlink $wd/current 2>/dev/null || true; readlink $wd/previous 2>/dev/null || true"
    ssh_exec "$h" "$cmd" "$dry_run" | mask_output
  done <<< "$hosts"
}
