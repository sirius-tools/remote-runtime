#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-test-policy.XXXXXX)"
run_rr() {
  HOME="$TMPDIR/home" RR_PROJECT_DIR="$TMPDIR/project/.remote-runtime" bash "$ROOT/scripts/rr" "$@"
}
if run_rr exec cloud-jd-bj-app-01 "rm -rf /" --dry-run >/dev/null 2>&1; then
  echo "policy failed"; exit 1
fi
echo "PASSWORD=abc 1.2.3.4" | run_rr exec cloud-jd-bj-app-01 "echo PASSWORD=abc 1.2.3.4" --dry-run >/dev/null || true
echo "test_policy ok"
