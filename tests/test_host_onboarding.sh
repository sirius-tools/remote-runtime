#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-host-onboarding.XXXXXX)"
HOME_DIR="$TMPDIR/home"
WORK_DIR="$TMPDIR/work"
mkdir -p "$HOME_DIR" "$WORK_DIR"

cd "$WORK_DIR"

HOME="$HOME_DIR" \
RR_SSH_CONFIG_DIR="$HOME_DIR/.ssh/config.d" \
RR_SSH_CONFIG_FILE="$HOME_DIR/.ssh/config" \
bash "$ROOT/scripts/rr" host add \
  --env test \
  --name lan-home-local-test-01 \
  --ssh-alias lan-home-local-test-01 \
  --host 192.0.2.151 \
  --user appuser \
  --role test \
  --provider home \
  --location local >/dev/null

yq eval -e '.hosts."lan-home-local-test-01".ssh_alias == "lan-home-local-test-01"' .remote-runtime/inventory.yaml >/dev/null
yq eval -e '.hosts."lan-home-local-test-01" | has("ip") | not' .remote-runtime/inventory.yaml >/dev/null
yq eval -e '.environments.test.hosts[] == "lan-home-local-test-01"' .remote-runtime/environments.yaml >/dev/null
grep -Fq 'Host lan-home-local-test-01' "$HOME_DIR/.ssh/config.d/remote-runtime.conf"
grep -Fq 'HostName 192.0.2.151' "$HOME_DIR/.ssh/config.d/remote-runtime.conf"

if grep -Riq 'password' .remote-runtime "$HOME_DIR/.ssh"; then
  echo "password leaked to config"
  exit 1
fi

echo "test_host_onboarding ok"
