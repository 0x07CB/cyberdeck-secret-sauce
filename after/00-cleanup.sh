#!/usr/bin/env bash
# after/00-cleanup.sh
# Post-install cleanup: remove unused packages and APT cache.
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

log_step "AFTER: Cleanup"

if [[ "${DRY_RUN}" == "true" ]]; then
  log_info "[DRY-RUN] Would run: apt-get autoremove -y && apt-get clean"
else
  log_info "Removing unused packages…"
  sudo apt-get autoremove -y --purge

  log_info "Cleaning APT cache…"
  sudo apt-get clean

  log_info "Removing stale thumbnail cache…"
  rm -rf "${TARGET_HOME}/.cache/thumbnails"/* 2>/dev/null || true
fi

log_info "Cleanup completed."
