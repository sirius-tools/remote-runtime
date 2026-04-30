#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_exec() {
  local target="$1" dry_run="$2" cmd="$3" json="${4:-false}"
  build_compiled_configs >/dev/null
  check_dangerous_command "$cmd" || return 1
  local hosts h
  hosts="$(resolve_or_fail "$target")"
  local rows="" top_success=true
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    if [[ "$json" == "true" ]]; then
      local out rc
      set +e
      out="$(ssh_exec "$h" "$cmd" "$dry_run" 2>&1 | mask_output)"
      rc=$?
      set -e
      [[ "$rc" -eq 0 ]] || top_success=false
      rows+="{\"name\":\"$h\",\"success\":$([[ "$rc" -eq 0 ]] && echo true || echo false),\"output\":\"$(json_escape "$out")\"},"
    else
      ssh_exec "$h" "$cmd" "$dry_run" | mask_output
    fi
  done <<< "$hosts"
  if [[ "$json" == "true" ]]; then
    echo "{\"success\":$top_success,\"action\":\"exec\",\"target\":\"$target\",\"hosts\":[${rows%,}]}"
  fi
  [[ "$top_success" == "true" ]]
}
