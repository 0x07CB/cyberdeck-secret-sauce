#!/usr/bin/env bash
# install/03-dotfiles.sh
# Clone and link dotfiles from DOTFILES_REPO into TARGET_HOME.
# Idempotent — skips clone if the directory already exists; uses 'git pull'
# to update instead.
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

log_step "INSTALL: Dotfiles"

if [[ -z "${DOTFILES_REPO:-}" ]]; then
  log_info "DOTFILES_REPO is not set — skipping dotfiles setup."
  exit 0
fi

# ── Clone or update ───────────────────────────────────────────────────────────
if [[ -d "${DOTFILES_DIR}/.git" ]]; then
  log_info "Dotfiles already cloned at ${DOTFILES_DIR}. Pulling latest…"
  run_cmd git -C "${DOTFILES_DIR}" pull --ff-only
else
  log_info "Cloning dotfiles from ${DOTFILES_REPO}…"
  run_cmd git clone --depth=1 "${DOTFILES_REPO}" "${DOTFILES_DIR}"
fi

# ── Run install script if present ─────────────────────────────────────────────
for installer in install.sh bootstrap.sh setup.sh Makefile; do
  target="${DOTFILES_DIR}/${installer}"
  if [[ -f "${target}" ]]; then
    log_info "Running dotfiles installer: ${installer}"
    if [[ "${DRY_RUN}" == "true" ]]; then
      log_info "[DRY-RUN] Would run: ${target}"
    elif [[ "${installer}" == "Makefile" ]]; then
      make -C "${DOTFILES_DIR}" install
    else
      bash "${target}"
    fi
    break
  fi
done

log_info "Dotfiles setup completed."
