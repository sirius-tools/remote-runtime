#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"
source "$(dirname "${BASH_SOURCE[0]}")/target.sh"
source "$(dirname "${BASH_SOURCE[0]}")/ssh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/policy.sh"
source "$(dirname "${BASH_SOURCE[0]}")/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/audit.sh"
source "$(dirname "${BASH_SOURCE[0]}")/lock.sh"
source "$(dirname "${BASH_SOURCE[0]}")/report.sh"
source "$(dirname "${BASH_SOURCE[0]}")/task.sh"
source "$(dirname "${BASH_SOURCE[0]}")/release.sh"

render_host_template() {
  local host="$1" template="$2" tail="${3:-200}"
  local service_name workdir
  service_name="$(host_var "$host" service_name)"
  workdir="$(host_var "$host" workdir)"
  printf '%s' "$template" |
    sed "s|{{service_name}}|$service_name|g; s|{{workdir}}|$workdir|g; s|{{tail}}|$tail|g"
}

deploy_method_command() {
  local host="$1" command_key="$2" tail="${3:-200}"
  local method template
  method="$(host_var "$host" deploy_method)"
  template="$(yq eval ".runtime.deploy_methods.\"$method\".\"$command_key\"" "$CFG_DIR/runtime.yaml")"
  [[ "$template" == "null" || -z "$template" ]] && die "missing runtime deploy method command: $method.$command_key"
  render_host_template "$host" "$template" "$tail"
}

remote_release_dirs_cmd() {
  local host="$1"
  local workdir
  workdir="$(host_var "$host" workdir)"
  printf 'mkdir -p %q/releases %q/shared %q/logs %q/backups %q/metadata' "$workdir" "$workdir" "$workdir" "$workdir" "$workdir"
}
