# Contributing to cyberdeck-secret-sauce

Thanks for investing time to improve this project. These guidelines keep things clean and reviewable.

---

## How to contribute

1. **Fork** the repository and create your branch from `main`:
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Make your changes** following the conventions below.

3. **Lint your scripts** locally before pushing:
   ```bash
   # ShellCheck (install: apt install shellcheck)
   shellcheck run.sh lib/*.sh before/*.sh install/*.sh after/*.sh ssh-keys-setup/*.sh

   # shfmt (install: go install mvdan.cc/sh/v3/cmd/shfmt@latest)
   shfmt -d -i 2 -bn -ci run.sh lib/ before/ install/ after/ ssh-keys-setup/
   ```

4. **Open a Pull Request** — the CI will run ShellCheck + shfmt automatically.

---

## Coding conventions

### Script header

Every script must start with:

```bash
#!/usr/bin/env bash
# path/to/script.sh — one-line description
# Additional context if needed.
set -euo pipefail
```

### Naming

| Type | Convention | Example |
|---|---|---|
| Script files | `NN-kebab-case.sh` (zero-padded) | `03-dotfiles.sh` |
| Functions | `snake_case` | `pkg_install` |
| Local variables | `snake_case` | `target_dir` |
| Exported / global variables | `UPPER_SNAKE_CASE` | `DRY_RUN` |
| Private functions | leading `_` | `_parse_args` |

### Idempotency

Every script must be safe to run multiple times without side effects.  
Check state before acting:

```bash
# ✓ Good
if [[ -d "${DEST}" ]]; then
  log_info "Already present. Skipping."
else
  run_cmd git clone "${REPO}" "${DEST}"
fi

# ✗ Bad
git clone "${REPO}" "${DEST}"
```

### Dry-run

Use `run_cmd` from `lib/utils.sh` for all side-effecting commands.  
When `DRY_RUN=true`, `run_cmd` logs intent and returns without executing.

```bash
run_cmd cp -a "${src}" "${dest}"
```

For complex blocks, guard explicitly:

```bash
if [[ "${DRY_RUN}" == "true" ]]; then
  log_info "[DRY-RUN] Would do X"
else
  do_x
fi
```

### Logging

Use only the helpers from `lib/log.sh`. Never use raw `echo`:

```bash
log_info  "Informational message"
log_warn  "Non-fatal warning"
log_error "Fatal error — script will exit"
log_debug "Verbose detail (shown only with LOG_LEVEL=debug)"
log_step  "Phase or section title"
```

### Quoting

Always double-quote variable expansions: `"${VAR}"`.  
ShellCheck will flag unquoted variables.

---

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(install): add tmux plugin manager setup
fix(ssh): skip keygen when key file already exists
docs(readme): add real-world examples section
chore(ci): pin shellcheck to v0.10
```

---

## Adding a new script

1. Choose the correct phase directory (`before/`, `install/`, `after/`, `ssh-keys-setup/`).
2. Name it `NN-description.sh` (increment the two-digit prefix by 1).
3. Use the boilerplate from [`docs/architecture.md`](docs/architecture.md).
4. Make it executable: `chmod +x path/to/script.sh`.
5. Test it in dry-run: `sudo DRY_RUN=true bash path/to/script.sh`.

---

## Reporting bugs

Open an issue and include:
- OS and version (`lsb_release -a`)
- Bash version (`bash --version`)
- The exact command run
- Full output (with `LOG_LEVEL=debug` if possible)
