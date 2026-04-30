#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_rollback() {
  local target="$1" dry_run="$2"
  acquire_lock "$target" || return 1
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    local wd svc
    wd="$(host_var "$h" workdir)"
    svc="$(host_var "$h" service_name)"
    ssh_exec "$h" "test -L $wd/previous && ln -sfn \"$(readlink $wd/previous 2>/dev/null || echo $wd/previous)\" $wd/current" "$dry_run"
    ssh_exec "$h" "systemctl restart $svc || true" "$dry_run"
  done <<< "$hosts"
  release_lock "$target"
}
