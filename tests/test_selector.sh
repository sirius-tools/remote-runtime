#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/rr" list hosts | rg 'cloud-jd-bj-app-01' >/dev/null
"$ROOT/scripts/rr" health env:test --dry-run >/dev/null
"$ROOT/scripts/rr" status role:app --dry-run >/dev/null
echo "test_selector ok"
