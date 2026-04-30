#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_logs() {
  local target="$1" dry_run="$2" tail="$3" follow="$4"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local method svc wd cmd
    method="$(host_var "$h" deploy_method)"
    svc="$(host_var "$h" service_name)"
    wd="$(host_var "$h" workdir)"
    if [[ "$method" == "jar-systemd" ]]; then
      cmd="journalctl -u $svc -n $tail --no-pager"
    else
      cmd="cd $wd/current && docker compose logs --tail $tail"
    fi
    [[ "$follow" == "true" ]] && cmd+=" -f"
    ssh_exec "$h" "$cmd" "$dry_run" | mask_output
  done <<< "$hosts"
}
