#!/usr/bin/env bash
# run.sh — cyberdeck-secret-sauce main orchestrator
#
# Usage:
#   sudo ./run.sh [OPTIONS]
#
# Options:
#   -n, --dry-run         Print what would happen; make no changes.
#   -p, --phases PHASES   Comma/space-separated list of phases to run.
#                         Available: before install after ssh
#                         Default: before install after
#   -d, --debug           Enable debug-level logging.
#   -h, --help            Show this help message.
#
# Environment variables override flags (see .env.example).
#
# Examples:
#   sudo ./run.sh
#   sudo ./run.sh --dry-run
#   sudo ./run.sh --phases "before install"
#   DRY_RUN=true LOG_LEVEL=debug sudo -E ./run.sh
set -euo pipefail

# ── Resolve repo root ─────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT

# ── Bootstrap: load libs before anything else ─────────────────────────────────
# shellcheck source=lib/log.sh
source "${REPO_ROOT}/lib/log.sh"
# shellcheck source=lib/utils.sh
source "${REPO_ROOT}/lib/utils.sh"
# shellcheck source=lib/env.sh
source "${REPO_ROOT}/lib/env.sh"

# ── Parse CLI arguments ───────────────────────────────────────────────────────
_parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n | --dry-run)
        DRY_RUN=true
        ;;
      -d | --debug)
        LOG_LEVEL=debug
        ;;
      -p | --phases)
        shift
        [[ $# -gt 0 ]] || {
          log_error "--phases requires an argument."
          exit 1
        }
        PHASES="${1//,/ }"
        ;;
      -h | --help)
        _print_usage
        exit 0
        ;;
      *)
        log_error "Unknown argument: $1"
        _print_usage
        exit 1
        ;;
    esac
    shift
  done
}

_print_usage() {
  cat <<'EOF'
Usage: sudo ./run.sh [OPTIONS]

Options:
  -n, --dry-run         Print what would happen; no changes are made.
  -p, --phases PHASES   Comma or space-separated list of phases.
                        Available: before  install  after  ssh
                        Default:   before  install  after
  -d, --debug           Enable debug-level logging.
  -h, --help            Show this help and exit.

Environment variables (override flags):
  DRY_RUN     true | false
  LOG_LEVEL   info | debug
  PHASES      "before install after ssh"

See .env.example for the full list of configuration variables.
EOF
}

# ── Phase → directory mapping ─────────────────────────────────────────────────
_phase_dir() {
  case "$1" in
    before) printf '%s/before' "${REPO_ROOT}" ;;
    install) printf '%s/install' "${REPO_ROOT}" ;;
    after) printf '%s/after' "${REPO_ROOT}" ;;
    ssh) printf '%s/ssh-keys-setup' "${REPO_ROOT}" ;;
    *)
      log_error "Unknown phase: '$1'. Valid phases: before install after ssh"
      exit 1
      ;;
  esac
}

# ── Run all scripts in a phase directory ─────────────────────────────────────
_run_phase() {
  local phase="$1"
  local phase_dir
  phase_dir="$(_phase_dir "${phase}")"

  if [[ ! -d "${phase_dir}" ]]; then
    log_warn "Phase directory not found: ${phase_dir}. Skipping."
    return 0
  fi

  log_step "PHASE: ${phase^^}"

  local scripts=()
  # shellcheck disable=SC2207
  mapfile -t scripts < <(find "${phase_dir}" -maxdepth 1 -name '*.sh' | sort)

  if [[ ${#scripts[@]} -eq 0 ]]; then
    log_warn "No scripts found in ${phase_dir}."
    return 0
  fi

  for script in "${scripts[@]}"; do
    log_info "Running: ${script##"${REPO_ROOT}/"}"
    bash "${script}"
    log_info "Completed: ${script##"${REPO_ROOT}/"}"
  done
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  _parse_args "$@"
  load_env

  log_step "cyberdeck-secret-sauce 🚀"
  log_info "DRY_RUN    : ${DRY_RUN}"
  log_info "LOG_LEVEL  : ${LOG_LEVEL}"
  log_info "TARGET_USER: ${TARGET_USER}"
  log_info "PHASES     : ${PHASES}"
  log_debug "REPO_ROOT  : ${REPO_ROOT}"

  local start_time
  start_time="$(date +%s)"

  # Execute requested phases
  read -ra phase_list <<<"${PHASES}"
  for phase in "${phase_list[@]}"; do
    _run_phase "${phase}"
  done

  local end_time elapsed
  end_time="$(date +%s)"
  elapsed=$((end_time - start_time))

  log_step "DONE ✓ (${elapsed}s)"
  [[ "${DRY_RUN}" == "true" ]] && log_warn "Dry-run mode: no changes were made."
}

main "$@"
