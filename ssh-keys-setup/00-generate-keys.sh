#!/usr/bin/env bash
# ssh-keys-setup/00-generate-keys.sh
# Generate SSH keypair for TARGET_USER if not already present.
# Idempotent — skips generation when the key already exists.
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

log_step "SSH: Generate Keypair"

SSH_DIR="${TARGET_HOME}/.ssh"
KEY_FILE="${SSH_DIR}/id_${SSH_KEY_TYPE}"

ensure_dir "${SSH_DIR}"

if [[ "${DRY_RUN}" != "true" ]]; then
  chmod 700 "${SSH_DIR}"
fi

if [[ -f "${KEY_FILE}" ]]; then
  log_info "SSH key already exists: ${KEY_FILE}. Skipping generation."
else
  log_info "Generating SSH key: type=${SSH_KEY_TYPE}, comment=${SSH_KEY_COMMENT}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would run: ssh-keygen -t ${SSH_KEY_TYPE} -C ${SSH_KEY_COMMENT} -f ${KEY_FILE} -N ''"
  else
    local_args=(-t "${SSH_KEY_TYPE}" -C "${SSH_KEY_COMMENT}" -f "${KEY_FILE}" -N "")
    if [[ "${SSH_KEY_TYPE}" == "rsa" ]]; then
      local_args+=(-b "${SSH_KEY_BITS}")
    fi
    sudo -u "${TARGET_USER}" ssh-keygen "${local_args[@]}"
    log_info "Key generated: ${KEY_FILE}"
    log_info "Public key:"
    cat "${KEY_FILE}.pub"
  fi
fi
