#!/usr/bin/env bash
# install/00-update-system.sh
# Refresh package index and apply available security updates.
# Idempotent — safe to run multiple times.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export REPO_ROOT

# shellcheck source=../lib/log.sh
source "${REPO_ROOT}/lib/log.sh"
# shellcheck source=../lib/utils.sh
source "${REPO_ROOT}/lib/utils.sh"
# shellcheck source=../lib/env.sh
source "${REPO_ROOT}/lib/env.sh"

load_env

log_step "INSTALL: System Update"

require_cmd apt-get sudo

if [[ "${DRY_RUN}" == "true" ]]; then
  log_info "[DRY-RUN] Would run: apt-get update && apt-get upgrade -y"
else
  log_info "Updating package index…"
  sudo apt-get update -qq

  log_info "Upgrading installed packages…"
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"
fi

log_info "System update completed."
