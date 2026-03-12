# Environment Variables Reference

All variables can be set in `.env` (copy from `.env.example`) or passed as environment variables before running `run.sh`.

## Core settings

| Variable | Default | Description |
|---|---|---|
| `DRY_RUN` | `false` | `true` → print intent only; no changes are made |
| `LOG_LEVEL` | `info` | `info` or `debug` |
| `TARGET_USER` | `$SUDO_USER` or `$USER` | Unix user that owns the setup |
| `TARGET_HOME` | `~TARGET_USER` | Home directory of `TARGET_USER` |
| `PHASES` | `before install after` | Space-separated list of phases to execute |

## Dotfiles

| Variable | Default | Description |
|---|---|---|
| `DOTFILES_REPO` | *(empty — skip)* | Git URL of your dotfiles repository |
| `DOTFILES_DIR` | `~/.dotfiles` | Local clone path |

## Extra packages

| Variable | Default | Description |
|---|---|---|
| `EXTRA_PACKAGES` | *(empty)* | Space-separated list of additional apt packages |

## SSH keys

| Variable | Default | Description |
|---|---|---|
| `SSH_KEY_TYPE` | `ed25519` | Key algorithm: `ed25519` or `rsa` |
| `SSH_KEY_BITS` | `4096` | RSA key size (ignored for ed25519) |
| `SSH_KEY_COMMENT` | `USER@cyberdeck` | Comment embedded in the public key |

## Overriding via command-line flags

Most common variables map to CLI flags in `run.sh`:

```
-n / --dry-run   → DRY_RUN=true
-d / --debug     → LOG_LEVEL=debug
-p / --phases    → PHASES="…"
```

Flags always take effect after `.env` is loaded.  
Explicit environment variables set before the script take precedence over `.env`.
