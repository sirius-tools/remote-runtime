#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

lock_file_for() {
  local target="$1"
  echo "$RR_HOME/locks/${target//[:\/ ]/_}.lock"
}

acquire_lock() {
  local target="$1"
  local lf
  lf="$(lock_file_for "$target")"
  if [[ -f "$lf" ]]; then
    echo "lock exists: $lf" >&2
    return 1
  fi
  date +%s > "$lf"
}

release_lock() {
  local target="$1"
  rm -f "$(lock_file_for "$target")"
}

lock_list() { ls -1 "$RR_HOME/locks"/*.lock 2>/dev/null || true; }
lock_clear() { rm -f "$(lock_file_for "$1")"; }
