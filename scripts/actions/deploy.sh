#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_deploy() {
  local target="$1" dry_run="$2"
  build_compiled_configs >/dev/null
  acquire_lock "$target" || return 1
  local rid
  rid="$(release_id)"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd svc
    wd="$(host_var "$h" workdir)"
    svc="$(host_var "$h" service_name)"
    ssh_exec "$h" "mkdir -p $wd/releases/$rid $wd/shared $wd/logs $wd/backups $wd/metadata" "$dry_run"
    ssh_exec "$h" "ln -sfn $wd/current $wd/previous || true" "$dry_run"
    ssh_exec "$h" "ln -sfn $wd/releases/$rid $wd/current" "$dry_run"
    ssh_exec "$h" "echo deploy-$rid >> $wd/metadata/releases.jsonl" "$dry_run"
    ssh_exec "$h" "systemctl restart $svc || true" "$dry_run"
  done <<< "$hosts"
  release_lock "$target"
}
