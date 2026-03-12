#!/usr/bin/env bash
# ssh-keys-setup/01-configure-ssh.sh
# Harden the SSH client configuration in ~/.ssh/config.
# Idempotent — appends configuration block only if not already present.
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

log_step "SSH: Configure SSH Client"

SSH_DIR="${TARGET_HOME}/.ssh"
SSH_CONFIG="${SSH_DIR}/config"

ensure_dir "${SSH_DIR}"
if [[ "${DRY_RUN}" != "true" ]]; then
  chmod 700 "${SSH_DIR}"
fi

# ── Idempotency marker ────────────────────────────────────────────────────────
MARKER="# cyberdeck-secret-sauce: global defaults"

if grep -qF "${MARKER}" "${SSH_CONFIG}" 2>/dev/null; then
  log_info "SSH config block already present. Skipping."
else
  log_info "Writing hardened SSH client defaults to ${SSH_CONFIG}…"
  SSH_CONFIG_BLOCK="${MARKER}
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_${SSH_KEY_TYPE}
    HashKnownHosts yes
    StrictHostKeyChecking ask
    ControlMaster auto
    ControlPath ~/.ssh/cm/cm-%r@%h:%p
    ControlPersist 10m
# end cyberdeck-secret-sauce"

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would append the following to ${SSH_CONFIG}:"
    printf '%s\n' "${SSH_CONFIG_BLOCK}"
  else
    backup_file "${SSH_CONFIG}"
    {
      echo ""
      echo "${SSH_CONFIG_BLOCK}"
    } >>"${SSH_CONFIG}"
    chmod 600 "${SSH_CONFIG}"
    log_info "SSH client config updated."
  fi
fi

# ── SSH control socket directory ─────────────────────────────────────────────
ensure_dir "${SSH_DIR}/cm"
if [[ "${DRY_RUN}" != "true" ]]; then
  chmod 700 "${SSH_DIR}/cm"
fi

log_info "SSH configuration completed."
