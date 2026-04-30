#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_rollback() {
  local target="$1" dry_run="$2"
  build_compiled_configs >/dev/null
  if [[ "$dry_run" != "true" ]]; then
    acquire_lock "$target" || return 1
    trap 'release_lock "$target"' RETURN
  fi
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd restart_cmd
    wd="$(host_var "$h" workdir)"
    restart_cmd="$(deploy_method_command "$h" restart_command)"
    ssh_exec "$h" "current=\$(readlink $wd/current 2>/dev/null || true); previous=\$(readlink $wd/previous 2>/dev/null || true); test -n \"\$previous\" && ln -sfn \"\$previous\" $wd/current && printf '%s\n' \"{\\\"action\\\":\\\"rollback\\\",\\\"from\\\":\\\"\$current\\\",\\\"to\\\":\\\"\$previous\\\"}\" >> $wd/metadata/releases.jsonl && $restart_cmd" "$dry_run"
  done <<< "$hosts"
  action_health "$target" "$dry_run" "false" "10"
}
