#!/usr/bin/env bash
# install/01-essentials.sh
# Install a curated set of essential CLI tools.
# Idempotent — already-installed packages are skipped.
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

log_step "INSTALL: Essential Packages"

ESSENTIAL_PACKAGES=(
  # Core utilities
  curl
  wget
  git
  vim
  tmux
  htop
  tree
  unzip
  jq
  ripgrep
  fd-find
  bat
  # Networking
  nmap
  netcat-openbsd
  dnsutils
  traceroute
  # Build toolchain
  build-essential
  make
  # Process / system
  lsof
  strace
  sysstat
)

# Append user-defined extra packages
if [[ -n "${EXTRA_PACKAGES:-}" ]]; then
  read -ra extra <<<"${EXTRA_PACKAGES}"
  ESSENTIAL_PACKAGES+=("${extra[@]}")
  log_info "Extra packages appended: ${extra[*]}"
fi

pkg_install "${ESSENTIAL_PACKAGES[@]}"

log_info "Essential packages installed."
