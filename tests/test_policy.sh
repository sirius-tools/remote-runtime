#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if "$ROOT/scripts/rr" exec cloud-jd-bj-app-01 "rm -rf /" --dry-run >/dev/null 2>&1; then
  echo "policy failed"; exit 1
fi
echo "PASSWORD=abc 1.2.3.4" | "$ROOT/scripts/rr" exec cloud-jd-bj-app-01 "echo PASSWORD=abc 1.2.3.4" --dry-run >/dev/null || true
echo "test_policy ok"
