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
    ssh_exec "$h" "$(deploy_method_command "$h" status_command) ; readlink $wd/current 2>/dev/null || true ; readlink $wd/previous 2>/dev/null || true" "$dry_run" | mask_output
  done <<< "$hosts"
}
