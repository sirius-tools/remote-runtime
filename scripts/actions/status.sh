#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_status() {
  local target="$1" dry_run="$2"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local method svc wd
    method="$(host_var "$h" deploy_method)"
    svc="$(host_var "$h" service_name)"
    wd="$(host_var "$h" workdir)"
    if [[ "$method" == "jar-systemd" ]]; then
      ssh_exec "$h" "systemctl status $svc --no-pager | head -n 20" "$dry_run" | mask_output
    else
      ssh_exec "$h" "cd $wd/current && docker compose ps" "$dry_run" | mask_output
    fi
  done <<< "$hosts"
}
