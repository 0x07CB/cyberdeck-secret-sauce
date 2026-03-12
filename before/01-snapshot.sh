#!/usr/bin/env bash
# before/01-snapshot.sh
# Create a lightweight pre-install snapshot: list of installed packages
# and key config files. Stored in ~/.cyberdeck/snapshots/<timestamp>/.
# Idempotent — each run creates a new timestamped snapshot directory.
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

log_step "PRE-FLIGHT: Snapshot"

SNAPSHOT_BASE="${TARGET_HOME}/.cyberdeck/snapshots"
SNAPSHOT_DIR="${SNAPSHOT_BASE}/$(date '+%Y%m%d_%H%M%S')"

log_info "Snapshot directory: ${SNAPSHOT_DIR}"
ensure_dir "${SNAPSHOT_DIR}"

# ── Installed packages ────────────────────────────────────────────────────────
if command -v dpkg-query &>/dev/null; then
  log_info "Capturing installed package list (dpkg)…"
  if [[ "${DRY_RUN}" == "true" ]]; then
    log_info "[DRY-RUN] Would write package list to ${SNAPSHOT_DIR}/packages.txt"
  else
    dpkg-query -W --showformat='${Package}\t${Version}\n' \
      >"${SNAPSHOT_DIR}/packages.txt"
    log_info "Package list saved."
  fi
fi

# ── Key config files ──────────────────────────────────────────────────────────
CONFIG_FILES=(
  "${TARGET_HOME}/.bashrc"
  "${TARGET_HOME}/.zshrc"
  "${TARGET_HOME}/.profile"
  "${TARGET_HOME}/.ssh/config"
  "/etc/apt/sources.list"
)

for f in "${CONFIG_FILES[@]}"; do
  if [[ -f "${f}" ]]; then
    rel="${f//\//_}"
    log_info "Backing up ${f}…"
    if [[ "${DRY_RUN}" == "true" ]]; then
      log_info "[DRY-RUN] Would copy ${f} → ${SNAPSHOT_DIR}/${rel}"
    else
      cp -a "${f}" "${SNAPSHOT_DIR}/${rel}"
    fi
  fi
done

log_info "Snapshot completed: ${SNAPSHOT_DIR}"
