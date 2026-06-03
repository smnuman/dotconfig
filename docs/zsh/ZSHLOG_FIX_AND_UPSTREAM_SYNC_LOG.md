# zshlog `-v=` Fix & Upstream Sync — Work Log

**Date:** 2026-06-03
**Repos touched:** `config-zsh` (zsh submodule), `zsh-git-utils` (untouched — verified), top-level `~/.config`

---

## 1. Original task — verify `zshlog` parameters

Asked to find `zshlog` and verify its parameters. Found a `zshlog()` function
in `utils/zshlog.core` and audited every option. One real defect: the `-v=`
flag used zsh **indirect expansion** `${(P)vvar}`, treating the supplied value
as a *variable name* rather than a boolean. So the documented `-v=true` form
silently failed (looked up a var literally named `true`), and verbosity could
never be enabled via `-v=`.

### Fix (Option A) — PR #10
Replaced the indirect expansion with a direct literal value:

```zsh
-v=*)  opt_echo="${vval:-false}" ;;   # was: opt_echo="${(P)vvar:-false}"
```

- `-v=true` / `-v=false` now work as documented.
- `-v=$VAR` keeps working (expands to `true`/`false` at the call site).
- Zero call-site changes required.

Merged as **PR #10** (`config-zsh`), squash commit `81f2f08`.

---

## 2. Critical follow-up — there are TWO `zshlog` implementations

`zshlog.core` (the file PR #10 fixed) turned out to be **loaded by nothing**
(`grep zshlog.core` = 0 hits). The implementation that actually runs is the
standalone script **`utils/zshlog`**, which is on `PATH` via `$ZUTILS`:

- `lib/pathtools.zsh` calls `$ZUTILS/zshlog` directly.
- `git-utils.zsh` (submodule) invokes `zshlog --info -v=$GIT_UTILS_DEBUG ...`
  **168×**, resolving via `PATH` to the script.
- The script had **no `-v=` case** → `-v=false` hit the catch-all and errored
  `Invalid option: -v=false`. **Every git-utils log call was silently broken
  at runtime** (message lost, usage dumped to stderr).

### Runtime fix — commit `551ee04`
Added the literal-value case to the *script* `utils/zshlog`:

```zsh
-v=*)  opt_echo="${1#-v=}" ;;   # literal: -v=true|false, or -v=$VAR
```

Verified in a live interactive shell: `-v=true` echoes, `-v=false` quiet,
`-v=$GIT_UTILS_DEBUG` honored both ways, no "Invalid option", logfile written.

> **Open item:** `zshlog.core` vs `utils/zshlog` are now duplicate
> implementations. Consider consolidating (have the script `source` the core,
> or delete the orphan).

---

## 3. Upstream sync — adopt 8 commits without losing local WIP

Local `zsh` submodule `main` was 8 commits behind `origin/main` with a dirty
working tree. Upstream had rewritten `.zshrc` into a WSL-native phase structure
plus a `bootstrap.sh` installer, `env/` modular files, a completions system, etc.

### Method (fully reversible)
1. Physical backup → `~/zsh-wip-backup-2026-06-03/`.
2. Snapshot WIP to branch `wip/pre-sync-2026-06-03` (commit `d027f41`).
3. `git merge --ff-only origin/main`.
4. 3-way `git merge` (commit `5f2ebda`) — resolve conflicts.
5. Fast-forward `main` to the reconciled merge.

### Conflict resolution — upstream structure + re-inject portable WIP
| File | Resolution |
|------|-----------|
| `.zshrc` | upstream + re-inject `secrets.key` sourcing |
| `env.zsh` | upstream + re-inject `GIT_UTILS_DEBUG="false"` |
| `my.zshenv` | auto-merged (`GUTILS` export preserved) |
| `zsh-aliases` | upstream (openclaw aliases → `.zshrc.local`) |
| `git-utils` submodule | upstream `81f3fa4` (local `69ffe3d` was ancestor) |
| `prompt` submodule | upstream `e95dfe0` (local `4b16564` was ancestor) |

### Machine-specific config → `.zshrc.local` (gitignored)
Discovery: on this macOS box, bun **globals** (`openclaw`, `omc`, …) live in
`~/.cache/.bun/bin`, **not** `~/.bun/bin` (which upstream adds). So the local
PATH edit was a real correction, not redundant. Routed all macOS-specific bits
to `.zshrc.local`:
- `~/.cache/.bun/bin` on `PATH`
- bun completions (`~/.bun/_bun`)
- `openclaw` aliases (`clawstart`, `og`)

`bootstrap.sh` gained `generate_zshrc_local()` to recreate this **per-OS**
(`mac` / `wsl` / `linux`) at deployment — commit `29437ff` added the dedicated
WSL branch (probes both bun dirs, sets `BROWSER=wslview`).

---

## 4. Bugs found & fixed along the way
- **`.zshrc:124`** hardcoded `source "/home/numan/.openclaw/completions/openclaw.zsh"`
  (another user's WSL home) → errored on every macOS boot. Replaced with a
  guarded, repo-relative source of the shipped `completions/openclaw.zsh`.
- **`"~/.gitconfig"` quoting** (local WIP): quotes prevented `~` expansion →
  dropped (upstream's unquoted form is correct).
- **`clawstart` alias** nested double-quotes broke the string → fixed to single
  quotes (old kept commented in `.zshrc.local`).
- **`utils/zshlog` `-s` branch** (pre-existing, *not* fixed): `A && {…} || {…}`
  footgun prints "Failed to write log to file" whenever `-s` is passed.
  git-utils doesn't use `-s`; left for a separate change.

---

## 5. Verification
- Interactive `zsh -i` boots clean (no `/home/numan` error).
- `clawstart`/`og` aliases present; `GIT_UTILS_DEBUG=false`; `~/.cache/.bun/bin`
  on `PATH`.
- Runtime `zshlog -v=true/false/$VAR` all correct; logfile written.
- `bootstrap.sh` `bash -n` clean; `generate_zshrc_local` output correct for
  mac/wsl/linux.

## Commits (zsh submodule `main`, ahead of `origin/main`)
```
29437ff fix(bootstrap): give generate_zshrc_local a dedicated WSL branch
551ee04 fix(zshlog): accept -v=true|false in the runtime utils/zshlog script
5f2ebda Merge origin/main into local WIP: adopt upstream WSL-native restructure
d027f41 wip: snapshot before adopting origin/main
81f2f08 fix(zshlog): make -v= literal boolean (PR #10, zshlog.core)
```
