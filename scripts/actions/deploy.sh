#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_deploy() {
  local target="$1" dry_run="$2"
  build_compiled_configs >/dev/null
  if [[ "$dry_run" != "true" ]]; then
    acquire_lock "$target" || return 1
    trap 'release_lock "$target"' RETURN
  fi
  local rid
  rid="$(release_id)"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  action_build "$target" "$dry_run"
  action_package "$target" "$dry_run"
  action_backup "$target" "$dry_run"
  action_upload "$target" "$dry_run"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd restart_cmd
    wd="$(host_var "$h" workdir)"
    restart_cmd="$(deploy_method_command "$h" restart_command)"
    ssh_exec "$h" "mkdir -p $wd/releases/$rid $wd/shared $wd/logs $wd/backups $wd/metadata && cp -a $wd/incoming/. $wd/releases/$rid/ 2>/dev/null || true && if [ -L $wd/current ]; then ln -sfn \$(readlink $wd/current) $wd/previous; fi && ln -sfn $wd/releases/$rid $wd/current && printf '%s\n' '{\"release_id\":\"$rid\",\"action\":\"deploy\"}' >> $wd/metadata/releases.jsonl && $restart_cmd" "$dry_run"
  done <<< "$hosts"
  action_health "$target" "$dry_run" "false" "10"
}
