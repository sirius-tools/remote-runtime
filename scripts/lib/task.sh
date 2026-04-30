#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

task_steps() {
  local task="$1"
  yq eval ".tasks.\"$task\".steps[]" "$CFG_DIR/tasks.yaml" 2>/dev/null || true
}
