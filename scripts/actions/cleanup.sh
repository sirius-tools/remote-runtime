#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_cleanup() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd keep
    wd="$(host_var "$h" workdir)"
    keep="$(host_var "$h" keep_releases)"
    [[ "$keep" == "null" || -z "$keep" ]] && keep=5
    ssh_exec "$h" "ls -1dt $wd/releases/* 2>/dev/null | tail -n +$((keep + 1)) | xargs -r rm -rf" "$dry_run" | mask_output
  done <<< "$hosts"
}
