#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common_actions.sh"

action_build() {
  local target="$1" dry_run="${2:-true}"
  build_compiled_configs >/dev/null
  local cmd
  if [[ -f pom.xml || -f mvnw ]]; then
    cmd="$(yq eval '.runtime.build.java.commands.maven' "$CFG_DIR/runtime.yaml")"
  elif [[ -f build.gradle || -f gradlew ]]; then
    cmd="$(yq eval '.runtime.build.java.commands.gradle' "$CFG_DIR/runtime.yaml")"
  else
    echo "no build file detected; skipping local build"
    return 0
  fi
  if [[ "$dry_run" == "true" ]]; then
    echo "DRY-RUN local $cmd"
  else
    bash -lc "$cmd"
  fi
}
