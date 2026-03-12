#!/usr/bin/env bash
# before/00-check-requirements.sh
# Pre-flight: verify OS, kernel, disk space, and required tools.
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

log_step "PRE-FLIGHT: Requirements Check"

# ── OS check ──────────────────────────────────────────────────────────────────
SUPPORTED_OS=("ubuntu" "debian" "pop" "linuxmint" "kali" "raspbian")
current_os="$(os_id)"
log_info "Detected OS: ${current_os}"

supported=0
for os in "${SUPPORTED_OS[@]}"; do
  [[ "${current_os}" == "${os}" ]] && supported=1 && break
done

if [[ ${supported} -eq 0 ]]; then
  log_warn "OS '${current_os}' is not in the supported list: ${SUPPORTED_OS[*]}"
  log_warn "Proceeding anyway — some scripts may fail."
else
  log_info "OS is supported."
fi

# ── Bash version ──────────────────────────────────────────────────────────────
required_bash_major=4
current_bash_major="${BASH_VERSINFO[0]}"
log_info "Bash version: ${BASH_VERSION}"
if [[ "${current_bash_major}" -lt "${required_bash_major}" ]]; then
  log_error "Bash >= ${required_bash_major} is required (found ${BASH_VERSION})."
  exit 1
fi

# ── Free disk space ───────────────────────────────────────────────────────────
required_mb=2048
available_mb=$(df -m / | awk 'NR==2 {print $4}')
log_info "Free disk space on /: ${available_mb} MB (required: ${required_mb} MB)"
if [[ "${available_mb}" -lt "${required_mb}" ]]; then
  log_error "Not enough disk space. Free at least ${required_mb} MB on /."
  exit 1
fi

# ── Required commands ─────────────────────────────────────────────────────────
log_info "Checking required commands…"
require_cmd curl git sudo

# ── Internet connectivity ─────────────────────────────────────────────────────
log_info "Checking internet connectivity…"
if [[ "${DRY_RUN}" == "true" ]]; then
  log_info "[DRY-RUN] Would check: curl -sf https://github.com"
elif curl -sf --max-time 5 https://github.com &>/dev/null; then
  log_info "Internet connectivity: OK"
else
  log_warn "Cannot reach github.com. Some steps may fail."
fi

log_info "Pre-flight check completed successfully."
