#!/usr/bin/env bash
set -euo pipefail

SKILL_HOME="${CODEX_HOME:-$HOME/.codex}/skills"
TARGET_SKILL_DIR="$SKILL_HOME/remote-runtime"

rm -rf "$TARGET_SKILL_DIR"
rm -f "$HOME/.local/bin/rr"

echo "removed skill: $TARGET_SKILL_DIR"
echo "removed optional cli link: $HOME/.local/bin/rr"
