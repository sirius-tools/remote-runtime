#!/usr/bin/env bash
set -euo pipefail

mask_output() {
  sed -E 's/([0-9]{1,3}\.){3}[0-9]{1,3}/***.***.***.***/g' | \
  sed -E 's/(PASSWORD|TOKEN|SECRET|ACCESS_KEY|PRIVATE_KEY)=([^ ]+)/\1=****/gI'
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}
