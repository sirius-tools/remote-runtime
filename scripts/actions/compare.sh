#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_compare() {
  local a="$1" b="$2" dry_run="$3"
  local cmd="hostname; uname -a; java -version 2>&1 | head -n 1; docker --version || true; df -h | head -n 5; free -m || vm_stat; ss -lnt || netstat -lnt; env | cut -d= -f1 | sort"
  echo "=== target: $a ==="
  action_exec "$a" "$dry_run" "$cmd"
  echo "=== target: $b ==="
  action_exec "$b" "$dry_run" "$cmd"
}
