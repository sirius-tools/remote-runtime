#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/selector.sh"

resolve_or_fail() {
  local target="$1"
  local hosts
  hosts="$(resolve_hosts "$target")"
  if [[ -z "$hosts" ]]; then
    echo "target not found: $target" >&2
    echo "candidates:" >&2
    suggest_targets >&2
    return 1
  fi
  printf '%s\n' "$hosts"
}
