#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_upload() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local wd artifact_dir artifact_pattern alias artifact
    wd="$(host_var "$h" workdir)"
    artifact_dir="$(host_var "$h" artifact_dir)"
    artifact_pattern="$(host_var "$h" artifact_pattern)"
    alias="$(host_alias "$h")"
    [[ "$artifact_dir" == "null" || -z "$artifact_dir" ]] && artifact_dir="target"
    [[ "$artifact_pattern" == "null" || -z "$artifact_pattern" ]] && artifact_pattern="*.jar"
    artifact="$(find "$artifact_dir" -name "$artifact_pattern" -type f 2>/dev/null | head -n 1 || true)"
    if [[ "$dry_run" == "true" ]]; then
      echo "DRY-RUN rsync ${artifact:-$artifact_dir/$artifact_pattern} $alias:$wd/incoming/"
    else
      [[ -n "$artifact" ]] || die "artifact not found: $artifact_dir/$artifact_pattern"
      ssh_exec "$h" "mkdir -p $wd/incoming" "$dry_run" >/dev/null
      rsync -az "$artifact" "$alias:$wd/incoming/"
    fi
  done <<< "$hosts"
}
