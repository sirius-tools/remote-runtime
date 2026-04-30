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
