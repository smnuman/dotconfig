# Dotconfig Analysis Report

Date: 2026-02-17
Scope: `/Users/mbair13m1/.config` (full tree scan, key configs, workflow scripts, and repo metadata)

## 1) Executive Understanding

This folder is a personal workstation-control repo that combines:
- A parent Git repo (`.config`) acting as an orchestrator.
- A submodule-first workflow model centered on `brew` and `zsh`.
- A custom Zsh + Git automation layer (`zsh/git-utils`) for creating repos, adding submodules, syncing parent/submodule pointers, and adding security controls (git-crypt, secret scanning hooks).
- Local machine runtime state for tools (Claude, Raycast, OpenCode, shell sessions/logs), mixed into the same directory hierarchy.

The intent is portable, modular dotfiles. The current reality is close to that, but mixed with significant local-state and secrets exposure.

## 2) Repo Topology and Ground Truth

Observed from parent repo:
- Parent repo tracks both normal directories and submodule gitlinks.
- `.gitmodules` defines:
  - `brew` -> `git@github.com:smnuman/config-brew.git`
  - `zsh` -> `git@github.com:smnuman/config-zsh.git`
- `git ls-tree HEAD` shows `brew` and `zsh` as mode `160000` (submodule entries).

Important local state observation:
- `brew/` has its own `.git` directory and is a normal standalone repo locally.
- `zsh/` currently has no `zsh/.git` in this workspace copy, despite parent treating it as submodule.
- This indicates submodule state drift/inconsistency that needs reconciliation before cleanup implementation.

## 3) Ignore Mechanisms (Implemented Behavior)

### 3.1 Parent `.gitignore` behavior

File: `/Users/mbair13m1/.config/.gitignore`

What it does:
- Ignores high-churn/local runtime folders (`claude/`, `gh/`, `glab-cli/`, `raycast/`, `logs/*`, etc.).
- Ignores runtime artifacts (`*.log`, `*.zip`, `.zcompdump`, `.DS_Store`).
- Keeps documentation via `!*.md` and `!README.md`.
- Explicitly avoids suppressing submodule metadata with:
  - `!.gitmodules`
  - `!/zsh/`
  - `!/brew/`
  - `!.gitignore`, `!.gitattributes`, `!.gitkeep`

Interpretation:
- Parent ignore policy is primarily “track curated config + docs; drop local runtime noise.”
- It is tuned to preserve submodule declarations while suppressing machine-local drift.

### 3.2 `.gsubignore` behavior (submodule candidate filter)

File: `/Users/mbair13m1/.config/.gsubignore`

Purpose:
- Exclusion list for `gsub-all`, not the same as `.gitignore`.
- Defines which directories should NOT be auto-converted into submodules.

Current top-level user exclusions include:
- `.claude/`, `claude/`, `gh/`, `glab-cli/`, `raycast/`, `tmux/`, `vscode/`, `warp/`, etc.

Interpretation:
- Intended as a governance file for “polyrepo boundaries.”
- This is critical for automation safety when batch-submoduling directories.

### 3.3 Generated ignore defaults in git-utils

File: `/Users/mbair13m1/.config/zsh/git-utils/gignore-defaults.zsh`

Provides:
- `GITIGNORE_DEFAULTS` for `git-genignore`.
- `GSUBIGNORE_DEFAULTS` for `gsub-genignore`.

Defaults include OS/editor/temp/dependency artifacts plus sensitive patterns (`*.env`, `*.key`, `*.pem`, `secrets/`, etc.).

Interpretation:
- You implemented policy-as-code defaults for consistency across repos.

### 3.4 Ignore command tooling

File: `/Users/mbair13m1/.config/zsh/git-utils/git-utils.zsh`

Commands:
- `git-genignore`: generates `.gitignore` from defaults (interactive overwrite).
- `gsub-genignore`: generates or deduplicates `.gsubignore`, preserving a user section marker.
- `gsubignore`: add/remove/list/clear entries in the user section with wildcard support and validation.
- `gsub-all`: respects `.gsubignore` + built-in defaults when deciding submodule candidates.

Interpretation:
- Ignore management is mature and scriptable; this is a strong part of the system.

## 4) Repo Naming Convention (Documented vs Implemented)

### 4.1 Documented convention

File: `/Users/mbair13m1/.config/dotfiles-polyrepo-handler.md`

Document says:
- Standard name = `parent-dir` + `-` + `current-dir`.
- Dots converted to hyphens, trim leading/trailing dots.
- Explicit exception: local `~/.config` should map to remote `dotconfig`.

### 4.2 Implemented naming in core git-utils

File: `/Users/mbair13m1/.config/zsh/git-utils/git-utils.zsh` (`_grepo_name`)

Actual behavior:
- Builds `${parent}-${base}` from path.
- Strips leading dots only.
- Enforces max length and simple charset for custom names.
- No explicit hardcoded exception for `~/.config -> dotconfig`.

Implication:
- Core workflow scripts can produce names diverging from documented exception unless custom repo names are provided.

### 4.3 Implemented naming in AI remote setup helper

File: `/Users/mbair13m1/.config/zsh/git-utils/git-ai-remotes` (`__git_ai_get_repo_name`)

Actual behavior:
- Has explicit special-case:
  - If `PWD == $HOME/.config`, return `dotconfig`.
- Otherwise applies parent-current normalization.

Implication:
- Naming logic is split and inconsistent between scripts (`git-utils.zsh` vs `git-ai-remotes`).

### 4.4 Legacy helper script behavior

File: `/Users/mbair13m1/.config/ai-git-setup`

Behavior:
- Builds remote repo names from `basename "$(git rev-parse --show-toplevel)"`.
- For `.config`, basename may remain `.config` (not `dotconfig`) depending on path normalization.

Implication:
- A third naming path exists and may create remote mismatch.

## 5) Installation and Clone Techniques (Special Treatment Needed)

### 5.1 Main bootstrap expectations

From `/Users/mbair13m1/.config/README.md`:
- Recommended clone:
  - `git clone --recursive ... ~/.config`
- If already cloned without recursion:
  - `git submodule update --init --recursive`
- Essential symlinks:
  - `~/.zshenv -> ~/.config/zsh/my.zshenv`
  - `~/.gitconfig -> ~/.config/git/gitconfig`
- Brew setup from `brew/Brewfile`.

### 5.2 Zsh startup dependency chain

Files:
- `/Users/mbair13m1/.config/zsh/my.zshenv`
- `/Users/mbair13m1/.config/zsh/env.zsh`
- `/Users/mbair13m1/.config/zsh/.zshrc`

Special treatment:
- `~/.zshenv` symlink is required for expected environment boot.
- Boot expects utility files and log directories under `.config/zsh/*`.
- Plugin manager may clone missing plugins on first interactive shell boot.

### 5.3 Git identity/provider initialization dependency

File: `/Users/mbair13m1/.config/zsh/lib/zsh-initgit.zsh`

Special treatment:
- `GIT_USER` is derived from provider/env/remote/CLI fallbacks.
- GitHub/GitLab CLI availability (`gh`, `glab`, `jq`) influences full behavior.
- Several workflows (`grepo`, `gsub`, AI remotes) depend on this being resolved.

### 5.4 Submodule + standalone repo duality

Current state in this workspace suggests:
- Parent expects `brew` and `zsh` as submodules.
- Local may contain standalone repo semantics (`brew`) and inconsistent submodule metadata (`zsh`).

Special treatment before cloning/migration:
- Verify submodule health with:
  - `git submodule status --recursive`
  - `git ls-tree HEAD`
  - presence/absence of `<submodule>/.git` vs gitfile entries.
- Decide authoritative model (strict submodule vs flat tracked dirs) before automating onboarding.

### 5.5 Encryption behavior and clone caveat

File: `/Users/mbair13m1/.config/.gitattributes`

Observation:
- Broad git-crypt attribute patterns are configured, including several `.git*` files.

Special treatment:
- On a fresh clone where encrypted files are present, usable content may require git-crypt initialization and unlock flow.

## 6) Additional Findings Already Discovered

### 6.1 Security exposure (high priority)

Plaintext secrets/tokens are present in active/local configs, including:
- `/Users/mbair13m1/.config/zsh/env.zsh`
- `/Users/mbair13m1/.config/opencode/opencode.json`
- `/Users/mbair13m1/.config/opencode/openclaw-mcp.json`
- `/Users/mbair13m1/.config/glab-cli/config.yml`

Impact:
- Environment compromise risk.
- Potential accidental disclosure via shell, logs, backups, or future commits.

### 6.2 Local state mixed with config source

Large runtime-heavy directories:
- `claude/`, `raycast/`, `opencode/`, `zsh/.zsh_sessions`, `zsh/logs`, backup artifacts.

Impact:
- Reduces repo clarity and portability.
- Raises noise and drift risk.

### 6.3 Broken symlink

- `/Users/mbair13m1/.config/eza/theme.yml` points to missing target `.../eza-themes/themes/catppuccin.yml`.

### 6.4 Command/config drift and duplicate behaviors

Examples:
- Multiple git remote toggle implementations (`gitconfig` alias + `git-utils` function + alias variants).
- Naming logic duplicated with inconsistent exceptions.

## 7) What This Means for the 3 Implementation Tracks

Before implementing cleanup/hardening/submodule-repair, the key prerequisite is to lock policy decisions:
- Single source of truth for repo naming (including `.config -> dotconfig` exception).
- Single source of truth for ignore policy generation vs manual overrides.
- Single authoritative submodule model for `brew` and `zsh`.
- Secret storage boundary (env vault/keychain/unencrypted local-only files) and commit policy.

This report captures those prerequisite mechanics so the next implementation phase can be executed without conflicting assumptions.

