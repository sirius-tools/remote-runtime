#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_health() {
  local target="$1" dry_run="$2" json="$3" timeout="$4"
  build_compiled_configs >/dev/null
  local hosts h out status summary
  hosts="$(resolve_or_fail "$target")"
  local rows=""
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local url
    url="$(host_var "$h" health_url)"
    out="$(ssh_exec "$h" "curl -sS -m $timeout -o /tmp/rr-health.out -w '%{http_code}' '$url'" "$dry_run" 2>&1 || true)"
    if [[ "$dry_run" == "true" ]]; then
      status=0; summary="DRY-RUN"
    else
      status="$out"
      [[ "$status" =~ ^2 ]] && summary="UP" || summary="DOWN"
    fi
    rows+="{\"name\":\"$h\",\"success\":$([[ "$summary" == "UP" || "$summary" == "DRY-RUN" ]] && echo true || echo false),\"status\":\"$status\",\"summary\":\"$summary\"},"
  done <<< "$hosts"
  rows="[${rows%,}]"

  if [[ "$json" == "true" ]]; then
    echo "{\"success\":true,\"action\":\"health\",\"target\":\"$target\",\"hosts\":$rows}"
  else
    echo "$rows" | mask_output
  fi
}
