#!/usr/bin/env bash
# install/04-dev-tools.sh
# Install language runtimes and developer tooling.
# Currently covers: Python (pyenv), Node.js (via NodeSource), Go.
# Idempotent — each tool is only installed when not already present.
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

log_step "INSTALL: Developer Tools"

# ── Python / pyenv ────────────────────────────────────────────────────────────
PYENV_DIR="${TARGET_HOME}/.pyenv"
if [[ -d "${PYENV_DIR}" ]]; then
  log_info "pyenv already installed at ${PYENV_DIR}. Skipping."
else
  log_info "Installing pyenv dependencies…"
  pkg_install \
    libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
    libffi-dev liblzma-dev xz-utils

  log_info "Installing pyenv…"
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would install pyenv for ${TARGET_USER}."
  else
    sudo -u "${TARGET_USER}" \
      bash -c "$(curl -fsSL https://pyenv.run)"
  fi
fi

# ── Node.js (via NodeSource LTS) ──────────────────────────────────────────────
if command -v node &>/dev/null; then
  log_info "Node.js already installed: $(node --version). Skipping."
else
  log_info "Installing Node.js LTS via NodeSource…"
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would install Node.js LTS."
  else
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
fi

# ── Go ────────────────────────────────────────────────────────────────────────
if command -v go &>/dev/null; then
  log_info "Go already installed: $(go version). Skipping."
else
  log_info "Installing Go via apt…"
  pkg_install golang-go
fi

log_info "Developer tools setup completed."
