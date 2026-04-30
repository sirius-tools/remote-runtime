#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

is_protected_target() {
  local target="$1"
  [[ "$target" == env:* ]] || return 1
  local env="${target#env:}"
  [[ "$(yq eval ".environments.\"$env\".protected" "$CFG_DIR/environments.yaml" 2>/dev/null || echo false)" == "true" ]]
}

check_dangerous_command() {
  local cmd="$1"
  local p
  while IFS= read -r p; do
    [[ -z "$p" || "$p" == "null" ]] && continue
    if [[ "$cmd" == *"$p"* ]]; then
      echo "blocked dangerous command pattern: $p" >&2
      return 1
    fi
  done < <(yq eval '.policies.commands.dangerous_patterns[]' "$CFG_DIR/policies.yaml")
  return 0
}

action_requires_confirm() {
  local action="$1"
  local configured
  while IFS= read -r configured; do
    [[ "$configured" == "$action" ]] && return 0
  done < <(yq eval '.policies.commands.require_confirm_actions[]' "$CFG_DIR/policies.yaml" 2>/dev/null || true)
  return 1
}

target_is_protected() {
  local target="$1"
  if [[ "$target" == env:* ]]; then
    is_protected_target "$target"
    return $?
  fi
  return 1
}

enforce_action_policy() {
  local action="$1" target="$2" dry_run="$3" yes="$4"
  build_compiled_configs >/dev/null

  [[ "$dry_run" == "true" ]] && return 0

  if target_is_protected "$target" && [[ "${RR_CONFIRM_PROTECTED:-false}" != "true" ]]; then
    die "protected target requires RR_CONFIRM_PROTECTED=true"
  fi

  if action_requires_confirm "$action" && [[ "$yes" != "true" ]]; then
    die "action $action requires --yes"
  fi
}
