#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR="$(mktemp -d /tmp/rr-improvement-plan.XXXXXX)"
HOME_DIR="$TMPDIR/home"
WORK_DIR="$TMPDIR/work"
mkdir -p "$HOME_DIR/.local/bin" "$HOME_DIR/.ssh/config.d" "$WORK_DIR"

cd "$WORK_DIR"

run_rr() {
  HOME="$HOME_DIR" \
  PATH="$HOME_DIR/.local/bin:$PATH" \
  RR_SSH_CONFIG_DIR="$HOME_DIR/.ssh/config.d" \
  RR_SSH_CONFIG_FILE="$HOME_DIR/.ssh/config" \
  RR_HOME="$HOME_DIR/.remote-runtime" \
  RR_USER_CFG_DIR="$HOME_DIR/.config/remote-runtime" \
  bash "$ROOT/scripts/rr" "$@"
}

run_rr doctor cli > "$TMPDIR/doctor-cli.out"
grep -Fq "rr executable:" "$TMPDIR/doctor-cli.out"
grep -Fq "skill root:" "$TMPDIR/doctor-cli.out"

run_rr config explain > "$TMPDIR/config-explain.out"
grep -Fq "skill defaults:" "$TMPDIR/config-explain.out"
grep -Fq "project config:" "$TMPDIR/config-explain.out"
grep -Fq "user overlays:" "$TMPDIR/config-explain.out"
grep -Fq "compiled cache:" "$TMPDIR/config-explain.out"

run_rr host plan-add \
  --scope user \
  --env test \
  --name lan-home-local-test-02 \
  --ssh-alias lan-home-local-test-02 \
  --host 192.0.2.152 \
  --user appuser > "$TMPDIR/host-plan.out"
grep -Fq "scope: user" "$TMPDIR/host-plan.out"
grep -Fq "$HOME_DIR/.config/remote-runtime/inventory.yaml" "$TMPDIR/host-plan.out"

run_rr host onboard-plan \
  --env dev \
  --address 192.0.2.153 \
  --user appuser \
  --provider home \
  --location local \
  --role app \
  --scope project > "$TMPDIR/onboard-plan.out"
grep -Fq "host onboard plan" "$TMPDIR/onboard-plan.out"
grep -Fq "passwords are never stored" "$TMPDIR/onboard-plan.out"
grep -Fq "inventory stores ssh_alias only" "$TMPDIR/onboard-plan.out"

plan_file="$(awk -F': ' '/plan_file:/ {print $2}' "$TMPDIR/onboard-plan.out")"
[[ -f "$plan_file" ]]

run_rr host onboard-apply --yes --from-plan "$plan_file" > "$TMPDIR/onboard-apply.out"
grep -Fq "host onboarded:" "$TMPDIR/onboard-apply.out"
grep -Fq "host valid:" "$TMPDIR/onboard-apply.out"
grep -Fq "ssh alias resolvable:" "$TMPDIR/onboard-apply.out"
mkdir -p "$HOME_DIR/.config/remote-runtime"
if grep -RiqE 'password|token|private_key' .remote-runtime "$HOME_DIR/.config/remote-runtime"; then
  echo "secret field leaked to runtime config"
  exit 1
fi
if rg -n '192\.0\.2\.153' .remote-runtime "$HOME_DIR/.config/remote-runtime" >/dev/null 2>&1; then
  echo "address leaked to runtime inventory"
  exit 1
fi

run_rr demo docker plan lan-home-local-app-01 --port auto > "$TMPDIR/docker-plan.out"
grep -Fq "docker demo plan" "$TMPDIR/docker-plan.out"
grep -Fq "rr demo docker deploy lan-home-local-app-01" "$TMPDIR/docker-plan.out"

if run_rr demo docker deploy lan-home-local-app-01 --port auto > "$TMPDIR/docker-deploy-no-yes.out" 2>&1; then
  echo "docker demo deploy without --yes unexpectedly succeeded"
  exit 1
fi
grep -Fq "requires --yes" "$TMPDIR/docker-deploy-no-yes.out"

run_rr demo docker deploy lan-home-local-app-01 --port 38180 --yes --dry-run > "$TMPDIR/docker-deploy.out"
grep -Fq "docker compose up -d" "$TMPDIR/docker-deploy.out"
grep -Fq "selected_port: 38180" "$TMPDIR/docker-deploy.out"

run_rr demo docker health lan-home-local-app-01 --port 38180 --dry-run > "$TMPDIR/docker-health.out"
grep -Fq "curl -fsS http://" "$TMPDIR/docker-health.out"
grep -Fq ":38180/" "$TMPDIR/docker-health.out"

run_rr demo docker cleanup lan-home-local-app-01 --yes --dry-run > "$TMPDIR/docker-cleanup.out"
grep -Fq "docker compose down" "$TMPDIR/docker-cleanup.out"

run_rr port find lan-home-local-app-01 --from 18080 --to 18100 --dry-run > "$TMPDIR/port-find.out"
grep -Fq "suggested_port:" "$TMPDIR/port-find.out"
grep -Fq "DRY-RUN ssh" "$TMPDIR/port-find.out"

echo "test_improvement_plan ok"
