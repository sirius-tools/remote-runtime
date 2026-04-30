#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-action-commands.XXXXXX)"
HOME_DIR="$TMPDIR/home"
WORK_DIR="$TMPDIR/work"
mkdir -p "$HOME_DIR" "$WORK_DIR"

cd "$WORK_DIR"

run_rr() {
  HOME="$HOME_DIR" bash "$ROOT/scripts/rr" "$@"
}

run_rr restart cloud-jd-bj-app-01 --dry-run >/tmp/rr-restart.out
grep -Fq "docker compose up -d" /tmp/rr-restart.out

run_rr backup lan-office-local-app-01 --dry-run >/tmp/rr-backup.out
grep -Fq "tar -czf" /tmp/rr-backup.out

run_rr port-check env:test --dry-run >/tmp/rr-port.out
grep -Fq "ss -lnt" /tmp/rr-port.out

run_rr rollback lan-office-local-app-01 --dry-run --yes >/tmp/rr-rollback.out
grep -Fq "readlink" /tmp/rr-rollback.out
if grep -Fq "$(pwd)" /tmp/rr-rollback.out; then
  echo "rollback expanded readlink locally"
  exit 1
fi

echo "test_action_commands ok"
