#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

WITH_CLI=false
if [[ "${1:-}" == "--with-cli" ]]; then
  WITH_CLI=true
fi

for c in bash ssh scp rsync curl yq rsync; do
  command -v "$c" >/dev/null 2>&1 || { echo "missing: $c"; exit 1; }
done

SKILL_HOME="${CODEX_HOME:-$HOME/.codex}/skills"
TARGET_SKILL_DIR="$SKILL_HOME/remote-runtime"

mkdir -p "$SKILL_HOME"
mkdir -p "$HOME/.remote-runtime" "$HOME/.remote-runtime/audit" "$HOME/.remote-runtime/reports" "$HOME/.remote-runtime/locks"

# Install as a Codex skill bundle (default behavior).
rm -rf "$TARGET_SKILL_DIR"
mkdir -p "$TARGET_SKILL_DIR"
rsync -a --delete \
  --exclude ".git/" \
  --exclude ".remote-runtime/" \
  "$ROOT/" "$TARGET_SKILL_DIR/"

mkdir -p "$HOME/.remote-runtime" "$HOME/.remote-runtime/audit" "$HOME/.remote-runtime/reports" "$HOME/.remote-runtime/locks"
chmod +x "$ROOT/scripts/rr"
find "$ROOT/scripts/actions" -name '*.sh' -exec chmod +x {} \;
chmod +x "$TARGET_SKILL_DIR/scripts/rr"
find "$TARGET_SKILL_DIR/scripts/actions" -name '*.sh' -exec chmod +x {} \;

if [[ "$WITH_CLI" == "true" ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$TARGET_SKILL_DIR/scripts/rr" "$HOME/.local/bin/rr"
fi

echo "skill installed to: $TARGET_SKILL_DIR"
echo "next:"
echo "  1) Restart or refresh Codex session so skill discovery reloads."
if [[ "$WITH_CLI" == "true" ]]; then
  echo "  2) rr doctor"
  echo "  3) rr init"
else
  echo "  2) Optional CLI link: ./install.sh --with-cli"
  echo "  3) Or run directly: $TARGET_SKILL_DIR/scripts/rr doctor"
fi
