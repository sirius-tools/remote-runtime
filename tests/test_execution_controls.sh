#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-exec-controls.XXXXXX)"
HOME_DIR="$TMPDIR/home"
WORK_DIR="$TMPDIR/work"
mkdir -p "$HOME_DIR" "$WORK_DIR"

cd "$WORK_DIR"

run_rr() {
  HOME="$HOME_DIR" bash "$ROOT/scripts/rr" "$@"
}

if run_rr deploy env:test >/tmp/rr-deploy-no-confirm.out 2>&1; then
  echo "deploy without --yes should be blocked"
  exit 1
fi
grep -Fq "requires --yes" /tmp/rr-deploy-no-confirm.out

run_rr deploy env:test --dry-run >/tmp/rr-deploy-dry-run.out
grep -Fq "DRY-RUN ssh jdcloud" /tmp/rr-deploy-dry-run.out

run_rr restart env:test --dry-run --report >/tmp/rr-restart-report.out
test -n "$(find "$HOME_DIR/.remote-runtime/reports" -name '*-restart-env_test.md' -print -quit)"
grep -Fq '"action":"restart"' "$HOME_DIR/.remote-runtime/audit/$(date +%F).log"

if run_rr deploy env:prod --yes >/tmp/rr-protected.out 2>&1; then
  echo "protected env should require explicit protected confirmation"
  exit 1
fi
grep -Fq "protected target requires RR_CONFIRM_PROTECTED=true" /tmp/rr-protected.out

echo "test_execution_controls ok"
