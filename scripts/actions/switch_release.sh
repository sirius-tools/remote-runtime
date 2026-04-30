#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_switch_release() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local rid
  rid="$(release_id)"
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd
    wd="$(host_var "$h" workdir)"
    ssh_exec "$h" "mkdir -p $wd/releases/$rid $wd/metadata && if [ -L $wd/current ]; then ln -sfn \$(readlink $wd/current) $wd/previous; fi && ln -sfn $wd/releases/$rid $wd/current && printf '%s\n' '{\"release_id\":\"$rid\",\"action\":\"switch_release\"}' >> $wd/metadata/releases.jsonl" "$dry_run" | mask_output
  done <<< "$hosts"
}
