#!/usr/bin/env bash
# install/02-zsh.sh
# Install Zsh and Oh My Zsh (if not already present) for TARGET_USER.
# Idempotent — skips any step that is already done.
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

log_step "INSTALL: Zsh + Oh My Zsh"

# ── Install Zsh ───────────────────────────────────────────────────────────────
pkg_install zsh

# ── Set Zsh as default shell ──────────────────────────────────────────────────
ZSH_PATH="$(command -v zsh)"
current_shell="$(getent passwd "${TARGET_USER}" | cut -d: -f7)"

if [[ "${current_shell}" == "${ZSH_PATH}" ]]; then
  log_info "Zsh is already the default shell for ${TARGET_USER}."
else
  log_info "Setting Zsh as default shell for ${TARGET_USER}…"
  run_cmd sudo chsh -s "${ZSH_PATH}" "${TARGET_USER}"
fi

# ── Oh My Zsh ────────────────────────────────────────────────────────────────
OMZ_DIR="${TARGET_HOME}/.oh-my-zsh"
if [[ -d "${OMZ_DIR}" ]]; then
  log_info "Oh My Zsh already installed at ${OMZ_DIR}. Skipping."
else
  log_info "Installing Oh My Zsh…"
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would install Oh My Zsh for ${TARGET_USER}."
  else
    # Unattended install: RUNZSH=no prevents spawning a new shell mid-script.
    sudo -u "${TARGET_USER}" env RUNZSH=no CHSH=no \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
fi

log_info "Zsh setup completed."
