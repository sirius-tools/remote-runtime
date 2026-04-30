#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

host_alias() {
  local host="$1"
  yq eval ".hosts.\"$host\".ssh_alias" "$CFG_DIR/inventory.yaml"
}

host_var() {
  local host="$1" key="$2"
  yq eval ".hosts.\"$host\".vars.\"$key\"" "$CFG_DIR/inventory.yaml"
}

ssh_exec() {
  local host="$1" cmd="$2" dry_run="$3"
  local alias
  alias="$(host_alias "$host")"
  [[ "$alias" == "null" || -z "$alias" ]] && { echo "missing ssh_alias for $host" >&2; return 1; }
  if [[ "$dry_run" == "true" ]]; then
    echo "DRY-RUN ssh $alias '$cmd'"
  else
    ssh "$alias" "$cmd"
  fi
}
