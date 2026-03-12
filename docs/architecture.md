# Architecture Overview

## Directory structure

```
cyberdeck-secret-sauce/
├── run.sh                     # Main orchestrator — start here
├── .env.example               # Configuration template (copy → .env)
├── lib/
│   ├── log.sh                 # Structured, colour-coded logging
│   ├── utils.sh               # Reusable helpers (pkg_install, run_cmd, …)
│   └── env.sh                 # .env loader + variable defaults & validation
├── before/                    # Phase 1 — pre-flight checks
│   ├── 00-check-requirements.sh
│   └── 01-snapshot.sh
├── install/                   # Phase 2 — package & tool installation
│   ├── 00-update-system.sh
│   ├── 01-essentials.sh
│   ├── 02-zsh.sh
│   ├── 03-dotfiles.sh
│   └── 04-dev-tools.sh
├── after/                     # Phase 3 — post-install cleanup & verification
│   ├── 00-cleanup.sh
│   └── 01-verify.sh
├── ssh-keys-setup/            # Phase 4 (optional) — SSH key generation & config
│   ├── 00-generate-keys.sh
│   └── 01-configure-ssh.sh
├── docs/
│   ├── architecture.md        # This file
│   └── variables.md           # Full variable reference
└── .github/
    └── workflows/
        └── ci.yml             # ShellCheck + shfmt on every PR
```

## Execution flow

```
run.sh
  └─► load env (.env → defaults → validate)
  └─► phase: before
  │     00-check-requirements.sh  → OS, Bash version, disk, internet
  │     01-snapshot.sh            → backup packages list + key config files
  └─► phase: install
  │     00-update-system.sh       → apt-get update && upgrade
  │     01-essentials.sh          → curated CLI tools
  │     02-zsh.sh                 → Zsh + Oh My Zsh
  │     03-dotfiles.sh            → clone & link dotfiles (if configured)
  │     04-dev-tools.sh           → pyenv, Node.js LTS, Go
  └─► phase: after
  │     00-cleanup.sh             → apt autoremove, clean cache
  │     01-verify.sh              → assert key tools are present
  └─► phase: ssh  (opt-in)
        00-generate-keys.sh       → ssh-keygen (skips if key exists)
        01-configure-ssh.sh       → harden ~/.ssh/config
```

## Design principles

| Principle | Implementation |
|---|---|
| **Fail fast** | `set -euo pipefail` in every script |
| **Idempotent** | Each step checks state before acting |
| **Dry-run** | `DRY_RUN=true` prints intent; nothing is changed |
| **Centralised config** | All variables in `.env` / environment; no magic constants |
| **Structured logging** | `lib/log.sh` — timestamped, colour-coded, level-gated |
| **Modular** | One concern per script; phases are independently runnable |
| **Quality gates** | ShellCheck + shfmt enforced on every PR via GitHub Actions |

## Adding a new phase or script

1. Create the directory (or reuse an existing phase directory).
2. Name the script `NN-description.sh` (zero-padded number for ordering).
3. Start the script with:

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export REPO_ROOT
source "${REPO_ROOT}/lib/log.sh"
source "${REPO_ROOT}/lib/utils.sh"
source "${REPO_ROOT}/lib/env.sh"
load_env
```

4. Make it executable: `chmod +x path/to/NN-description.sh`
5. If it's a new phase, add a case entry to `_phase_dir()` in `run.sh`.
