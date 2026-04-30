#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

CFG_DIR="${RR_HOME}/compiled"
mkdir -p "$CFG_DIR"

cfg_merge_file() {
  local dst="$1" src="$2"
  [[ -f "$src" ]] || return 0
  if [[ ! -s "$dst" ]]; then
    cp "$src" "$dst"
  else
    yq eval-all 'select(fileIndex==0) * select(fileIndex==1)' "$dst" "$src" > "${dst}.tmp"
    mv "${dst}.tmp" "$dst"
  fi
}

build_compiled_configs() {
  require_cmd yq
  local inv="$CFG_DIR/inventory.yaml" env="$CFG_DIR/environments.yaml" tasks="$CFG_DIR/tasks.yaml" pol="$CFG_DIR/policies.yaml" rt="$CFG_DIR/runtime.yaml"
  : > "$inv"; : > "$env"; : > "$tasks"; : > "$pol"; : > "$rt"

  cfg_merge_file "$inv" "$RR_ROOT/config/inventory.yaml"
  cfg_merge_file "$env" "$RR_ROOT/config/environments.yaml"
  cfg_merge_file "$tasks" "$RR_ROOT/config/tasks.yaml"
  cfg_merge_file "$pol" "$RR_ROOT/config/policies.yaml"
  cfg_merge_file "$rt" "$RR_ROOT/config/runtime.yaml"

  cfg_merge_file "$inv" "$RR_PROJECT_DIR/inventory.yaml"
  cfg_merge_file "$env" "$RR_PROJECT_DIR/environments.yaml"
  cfg_merge_file "$tasks" "$RR_PROJECT_DIR/tasks.yaml"
  cfg_merge_file "$rt" "$RR_PROJECT_DIR/runtime.yaml"

  cfg_merge_file "$inv" "$RR_USER_CFG_DIR/inventory.yaml"
  cfg_merge_file "$env" "$RR_USER_CFG_DIR/environments.yaml"
  cfg_merge_file "$tasks" "$RR_USER_CFG_DIR/tasks.yaml"
  cfg_merge_file "$pol" "$RR_USER_CFG_DIR/policies.yaml"
  cfg_merge_file "$rt" "$RR_USER_CFG_DIR/runtime.yaml"

  echo "$CFG_DIR"
}

cfg_get() {
  local file="$1" expr="$2"
  yq eval "$expr" "$CFG_DIR/$file"
}
