# cyberdeck-secret-sauce 🔧

> *"What's the point of having tools if you don't know how to use them?" — R.S.*

A modular, idempotent, dry-run–capable Linux re-deploy kit.  
Boot a fresh machine from zero to fully operational in a single pass, without guesswork.

---

## Quickstart

```bash
# 1. Clone
git clone https://github.com/0x07CB/cyberdeck-secret-sauce.git
cd cyberdeck-secret-sauce

# 2. Configure
cp .env.example .env
$EDITOR .env   # adjust TARGET_USER, DOTFILES_REPO, EXTRA_PACKAGES, …

# 3. Dry-run first — inspect what will happen
sudo DRY_RUN=true ./run.sh

# 4. Run for real
sudo ./run.sh
```

That's it.

---

## Prerequisites

| Requirement | Version |
|---|---|
| Linux (Debian / Ubuntu / Pop!_OS / Kali / Raspberry Pi OS) | any recent |
| Bash | ≥ 4.0 |
| `git`, `curl`, `sudo` | in PATH |

> **Note:** The scripts assume an apt-based distribution. Other distros (dnf / pacman) will receive a warning; install scripts fall back gracefully when possible.

---

## Options

```
Usage: sudo ./run.sh [OPTIONS]

  -n, --dry-run         Print what would happen; make no changes.
  -p, --phases PHASES   Comma/space-separated list of phases.
                        Available: before  install  after  ssh
                        Default:   before  install  after
  -d, --debug           Enable debug-level logging.
  -h, --help            Show this help.
```

### Real examples

```bash
# Full run with debug output
sudo LOG_LEVEL=debug ./run.sh

# Only run pre-flight checks
sudo ./run.sh --phases before

# Install packages + cleanup, skip pre-flight
sudo ./run.sh --phases "install after"

# Set up SSH keys on an existing machine
sudo ./run.sh --phases ssh

# Completely non-destructive preview
sudo ./run.sh --dry-run --phases "before install after ssh"
```

---

## Directory structure

```
cyberdeck-secret-sauce/
├── run.sh                  # Main orchestrator
├── .env.example            # Configuration template
├── lib/
│   ├── log.sh              # Colour logging helpers
│   ├── utils.sh            # Shared utilities (pkg_install, run_cmd, …)
│   └── env.sh              # .env loader + validation
├── before/                 # Phase: pre-flight
├── install/                # Phase: package installation
├── after/                  # Phase: cleanup + verification
├── ssh-keys-setup/         # Phase: SSH key generation
└── docs/                   # Architecture & variable reference
```

See [`docs/architecture.md`](docs/architecture.md) for the full execution flow.

---

## Configuration

Copy `.env.example` to `.env` and edit it:

```bash
cp .env.example .env
```

Key variables:

| Variable | Default | Description |
|---|---|---|
| `DRY_RUN` | `false` | `true` → preview only |
| `LOG_LEVEL` | `info` | `info` or `debug` |
| `TARGET_USER` | `$SUDO_USER` | Target user for all setup |
| `DOTFILES_REPO` | *(empty)* | Git URL of your dotfiles |
| `EXTRA_PACKAGES` | *(empty)* | Extra apt packages (space-separated) |
| `SSH_KEY_TYPE` | `ed25519` | `ed25519` or `rsa` |

Full reference: [`docs/variables.md`](docs/variables.md)

---

## What gets installed

### Phase: `before`
- OS, Bash version, disk space, internet connectivity checks
- Timestamped snapshot of installed packages + key config files

### Phase: `install`
- System packages update
- Essential CLI tools: `git`, `vim`, `tmux`, `htop`, `jq`, `ripgrep`, `bat`, `nmap`, …
- Zsh + Oh My Zsh
- Dotfiles (if `DOTFILES_REPO` is set)
- Developer runtimes: pyenv, Node.js LTS, Go

### Phase: `after`
- APT autoremove + cache clean
- Verification that all key tools are present

### Phase: `ssh` (opt-in)
- Generate ed25519 / RSA keypair (skipped if key already exists)
- Harden `~/.ssh/config` (connection multiplexing, strict host checking, …)

---

## Design principles

- **Fail fast** — `set -euo pipefail` in every script
- **Idempotent** — every step checks state before acting; safe to re-run
- **Dry-run** — `DRY_RUN=true` prints intent; nothing is changed
- **Modular** — one concern per script; phases run independently
- **Quality gates** — ShellCheck + shfmt on every PR via GitHub Actions

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

[MIT](LICENSE) © 0x07CB
