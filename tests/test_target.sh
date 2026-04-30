#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if "$ROOT/scripts/rr" status not-exists --dry-run >/tmp/rr-target.err 2>&1; then
  echo "target check failed"; exit 1
fi
rg 'candidates' /tmp/rr-target.err >/dev/null
echo "test_target ok"
