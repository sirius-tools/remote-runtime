#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-test-config.XXXXXX)"
HOME="$TMPDIR/home" RR_PROJECT_DIR="$TMPDIR/project/.remote-runtime" bash "$ROOT/scripts/rr" validate >/dev/null
echo "test_config ok"
