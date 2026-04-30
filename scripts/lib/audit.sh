#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

write_audit() {
  local action="$1" target="$2" hosts="$3" dry_run="$4" success="$5" duration_ms="$6"
  local f="$RR_HOME/audit/$(date +%F).log"
  printf '{"time":"%s","user":"%s","action":"%s","target":"%s","resolved_hosts":[%s],"dry_run":%s,"success":%s,"duration_ms":%s}\n' \
    "$(date -u +%FT%TZ)" "${USER:-unknown}" "$action" "$target" "$hosts" "$dry_run" "$success" "$duration_ms" >> "$f"
}
