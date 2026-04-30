#!/usr/bin/env bash
set -euo pipefail

RR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RR_HOME="${HOME}/.remote-runtime"
RR_PROJECT_DIR="$(pwd)/.remote-runtime"
RR_USER_CFG_DIR="${HOME}/.config/remote-runtime"

mkdir -p "$RR_HOME" "$RR_HOME/audit" "$RR_HOME/reports" "$RR_HOME/locks"

die() { echo "[ERROR] $*" >&2; exit 1; }
info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }

expand_home() {
  local p="$1"
  [[ "$p" == ~* ]] && echo "${p/#\~/$HOME}" || echo "$p"
}

require_cmd() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "missing command: $c"
  done
}
