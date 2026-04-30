#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_health() {
  local target="$1" dry_run="$2" json="$3" timeout="$4"
  build_compiled_configs >/dev/null
  local hosts h out status summary
  hosts="$(resolve_or_fail "$target")"
  local rows=""
  local top_success=true
  local retries interval
  retries="$(yq eval '.runtime.default_health_retries // 1' "$CFG_DIR/runtime.yaml")"
  interval="$(yq eval '.runtime.default_health_interval_seconds // 1' "$CFG_DIR/runtime.yaml")"
  while IFS= read -r h; do
    [[ -z "$h" ]] && continue
    local url attempt start end elapsed success
    url="$(host_var "$h" health_url)"
    start="$(date +%s)"
    success=false
    if [[ "$dry_run" == "true" ]]; then
      out="$(ssh_exec "$h" "curl -sS -m $timeout -o /tmp/rr-health.out -w '%{http_code}' '$url'" "$dry_run" 2>&1 || true)"
      status=0
      summary="DRY-RUN"
      success=true
    else
      for attempt in $(seq 1 "$retries"); do
        out="$(ssh_exec "$h" "curl -sS -m $timeout -o /tmp/rr-health.out -w '%{http_code}' '$url'" "$dry_run" 2>&1 || true)"
        status="$out"
        if [[ "$status" =~ ^2 ]]; then
          summary="UP"
          success=true
          break
        fi
        [[ "$attempt" -lt "$retries" ]] && sleep "$interval"
      done
      [[ "$success" == "true" ]] || summary="DOWN"
    fi
    end="$(date +%s)"
    elapsed=$((end - start))
    [[ "$success" == "true" ]] || top_success=false
    rows+="{\"name\":\"$h\",\"success\":$success,\"status\":\"$(json_escape "$status")\",\"summary\":\"$summary\",\"duration_seconds\":$elapsed},"
  done <<< "$hosts"
  rows="[${rows%,}]"

  if [[ "$json" == "true" ]]; then
    echo "{\"success\":$top_success,\"action\":\"health\",\"target\":\"$target\",\"hosts\":$rows}"
  else
    echo "$rows" | mask_output
  fi
  [[ "$top_success" == "true" ]]
}
