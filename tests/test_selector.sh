#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-test-selector.XXXXXX)"
run_rr() {
  HOME="$TMPDIR/home" RR_PROJECT_DIR="$TMPDIR/project/.remote-runtime" bash "$ROOT/scripts/rr" "$@"
}
run_rr list hosts | rg 'cloud-jd-bj-app-01' >/dev/null
run_rr health env:test --dry-run >/dev/null
run_rr status role:app --dry-run >/dev/null
echo "test_selector ok"
