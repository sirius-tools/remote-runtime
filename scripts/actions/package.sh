#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_package() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local first artifact_dir artifact_pattern
  first="$(resolve_or_fail "$target" | head -n 1)"
  artifact_dir="$(host_var "$first" artifact_dir)"
  artifact_pattern="$(host_var "$first" artifact_pattern)"
  [[ "$artifact_dir" == "null" || -z "$artifact_dir" ]] && artifact_dir="target"
  [[ "$artifact_pattern" == "null" || -z "$artifact_pattern" ]] && artifact_pattern="*.jar"
  if [[ "$dry_run" == "true" ]]; then
    echo "DRY-RUN package find $artifact_dir -name '$artifact_pattern'"
  else
    find "$artifact_dir" -name "$artifact_pattern" -type f | head -n 1 | grep -q . || die "artifact not found: $artifact_dir/$artifact_pattern"
  fi
}
