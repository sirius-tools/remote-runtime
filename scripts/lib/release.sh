#!/usr/bin/env bash
set -euo pipefail

release_id() {
  local sha
  sha="$(git rev-parse --short HEAD 2>/dev/null || echo local)"
  date +%Y%m%d%H%M%S-"$sha"
}
