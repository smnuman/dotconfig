# Brew Missing From PATH — Diagnosis & Symlink Fix

**Date:** 2026-06-06
**Repos touched:** `config-zsh` (zsh submodule — `lib/.zprofile`, `bootstrap.sh`), top-level `~/.config` (this doc)

---

## 1. Symptom

```
$ which brew
brew not found
```

User reported brew was "missing from the system" and asked for the **reason**
(not a reinstall).

## 2. Investigation

### Brew binary is intact

| Check                          | Result                                            |
|--------------------------------|---------------------------------------------------|
| `/opt/homebrew/bin/brew`       | exists, `-rwxr-xr-x`, 8671 B, modified 2026-05-21 |
| `/opt/homebrew/Library/Homebrew/` | 225 entries — Ruby core present                |
| `/opt/homebrew/Cellar/`        | 156 entries — packages installed                  |
| `/opt/homebrew/Caskroom/`      | 13 entries — casks installed                      |
| `git log` in `/opt/homebrew`   | recent upstream merges (PR #22329, #22335, …)     |

Brew was **never deleted**.

### `$PATH` was missing `/opt/homebrew/bin`

```
PATH=…/.bun/bin:…/zsh/git-utils:…:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:…
```

No `/opt/homebrew/bin` anywhere — so `which brew` could not find it.

### Root cause: `~/.zprofile` did not exist

On Apple Silicon, brew injects itself into login-shell `$PATH` via
`eval "$(/opt/homebrew/bin/brew shellenv)"`, which normally lives in
`~/.zprofile`. That file was **absent** from `$HOME`:

```
$ ls /Users/mbair13m1/.zprofile
ls: /Users/mbair13m1/.zprofile: No such file or directory
```

The repo already shipped the right content at
`~/.config/zsh/lib/.zprofile`:

```zsh
# eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

…but it was **never symlinked** to `~/.zprofile`. The companion `setup_symlinks()`
in `bootstrap.sh` linked `~/.zshenv` and `~/.zshrc` but had no clause for
`~/.zprofile`, so a fresh install (or a system where the old `.zprofile` was
removed during a `dotfiles` reset) ended up without brew on PATH.

This matches the existing memory note about per-OS machine config (see also
[zsh config conventions]). It is the *running implementation* that was wrong —
the source file existed but had no path into `$HOME`.

---

## 3. Fix

### 3a. `lib/.zprofile` — portable across Mac architectures

The original line hard-coded `/opt/homebrew` (Apple Silicon). Rewrote to handle
Intel Macs (`/usr/local/bin/brew`) as well, preserving the old line as a
commented-out reference per repo convention:

```zsh
# --- legacy single-arch version (kept commented for reference) ---
# eval "$(/opt/homebrew/bin/brew shellenv)"

# --- portable across Apple Silicon and Intel Macs ---
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
```

### 3b. Symlink (manual, immediate)

```bash
ln -s /Users/mbair13m1/.config/zsh/lib/.zprofile /Users/mbair13m1/.zprofile
```

Verified in a fresh login shell:

```
$ zsh -l -c 'which brew && brew --version'
/opt/homebrew/bin/brew
Homebrew 5.1.12
```

### 3c. `bootstrap.sh` — automate the symlink for future installs

Added a new macOS-only clause to `setup_symlinks()` (after the `~/.zshrc`
block), mirroring the existing `~/.zshenv` / `~/.zshrc` pattern:

- Skip if `~/.zprofile` is already a symlink (idempotent).
- Backup an existing regular file to `~/.zprofile.pre-bootstrap`.
- `ln -sf "$ZDOTDIR/lib/.zprofile" "$HOME/.zprofile"`.
- Honours `--dry-run`.
- Gated on `[[ "$PLATFORM" == "macos" ]]` so Linux/WSL hosts are unaffected.

Dry-run on the current machine prints `✓ ~/.zprofile already linked`, confirming
the new branch is reachable and idempotent.

---

## 4. Why this was easy to miss

- `~/.zshenv` and `~/.zshrc` symlinks were both present and recent
  (`.zshenv` from 2025-08-18, `.zshrc` from 2026-06-02), masking the fact that
  the third critical home-dir dotfile was absent.
- Brew's own shellenv writes to `~/.zprofile` *only when the user runs the
  official install script*. Anyone bringing their own dotfiles must wire this
  up themselves — exactly what this commit now does.
- The `bootstrap.sh` post-install summary previously printed the legacy hint
  *"Install Homebrew → brew shellenv > ~/.config/brew/.env"*. That cached-env
  pattern is superseded by the new symlink and has been replaced in
  `print_summary()` — it now either (a) confirms brew is loaded via the
  `~/.zprofile` symlink, or (b) instructs the user to install Homebrew and
  notes the symlink will pick it up automatically on next login. No further
  follow-up needed.

---

## 5. Verification checklist

- [x] `/opt/homebrew/bin/brew` still executable, untouched.
- [x] `~/.zprofile` is a symlink → `~/.config/zsh/lib/.zprofile`.
- [x] `zsh -l -c 'which brew'` → `/opt/homebrew/bin/brew`.
- [x] `zsh -l -c 'brew --version'` → `Homebrew 5.1.12`.
- [x] `bash -n bootstrap.sh` → no syntax errors.
- [x] `bootstrap.sh --dry-run` → reports `~/.zprofile already linked`.

---

## 6. Files changed

| File                                             | Change                                            |
|--------------------------------------------------|---------------------------------------------------|
| `~/.config/zsh/lib/.zprofile`                    | Portable Apple Silicon + Intel brew shellenv      |
| `~/.config/zsh/bootstrap.sh`                     | `setup_symlinks()` now links `~/.zprofile` on macOS |
| `~/.zprofile`                                    | New symlink → `~/.config/zsh/lib/.zprofile`       |
| `~/.config/docs/zsh/BREW_SHELLENV_SYMLINK_FIX_LOG.md` | This work log (new)                          |
