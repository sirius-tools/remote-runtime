#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

write_report() {
  local action="$1" target="$2" content="$3"
  local f="$RR_HOME/reports/$(date +%Y%m%d%H%M%S)-${action}-${target//[:\/ ]/_}.md"
  cat > "$f" <<R
# remote-runtime report

- time: $(date -u +%FT%TZ)
- action: $action
- target: $target

## details
$content
R
  echo "$f"
}
