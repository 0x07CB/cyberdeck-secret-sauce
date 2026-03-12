#!/usr/bin/env bash
# after/01-verify.sh
# Post-install verification: assert that key tools are present and functional.
# Exits non-zero if critical tools are missing.
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

log_step "AFTER: Verification"

REQUIRED_TOOLS=(
  curl
  wget
  git
  vim
  tmux
  jq
  zsh
)

failed=0
for tool in "${REQUIRED_TOOLS[@]}"; do
  if command -v "${tool}" &>/dev/null; then
    log_info "  ✓ ${tool} ($(command -v "${tool}"))"
  else
    log_error "  ✗ ${tool} — NOT FOUND"
    failed=$((failed + 1))
  fi
done

if [[ ${failed} -gt 0 ]]; then
  log_error "${failed} tool(s) missing. Review the install logs above."
  exit 1
fi

log_info "All required tools verified. System is ready."
