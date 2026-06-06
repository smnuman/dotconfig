# Repository Hierarchy & git-utils Analysis

**By:** OpenCode - Claude Opus 4.6 - Anthropic (Sysiphus-UltraWorker) <br>
**Date:** 2026-02-21 <br>
**Scope:** Full analysis of `~/.config` repo hierarchy, submodule structure, and `zsh/git-utils/` contents

---

## Repository Hierarchy & Submodule Map

There are **4 independent Git repos** in a nested structure:

```
~/.config/                          → git@github.com:smnuman/config-zsh.git  (root)
├── .gitmodules                     → tracks: brew, zsh
│
├── brew/                           → git@github.com:smnuman/config-brew.git  (submodule ✓)
│
├── zsh/                            → git@github.com:smnuman/config-zsh.git   (submodule ⚠️ PROBLEM)
│   ├── .gitmodules                 → tracks: prompt (path=prompt, url=smnuman/zsh-prompt)
│   │
│   ├── prompt/                     → git@github.com:smnuman/zsh-prompt.git   (submodule of zsh ✓)
│   │   ├── .gitmodules             → DELETED (was self-referencing, correctly removed)
│   │   └── no submodules
│   │
│   └── git-utils/                  → git@github.com:smnuman/zsh-git-utils.git (standalone repo, NOT a submodule)
│       ├── no .gitmodules
│       └── no submodules
```

---

## Key Observations

### 1. Root `.config` has a circular submodule problem

- Root repo remote = `smnuman/config-zsh.git`
- Root `.gitmodules` lists `zsh` submodule pointing to `smnuman/config-zsh.git`
- **The root repo points to itself as a submodule.** The `zsh/` submodule has `-` prefix in `git submodule status`, meaning it's not initialized — likely because it's the same repo.

### 2. `prompt/.gitmodules` was correctly removed

- The self-referencing submodule entry (`path = prompt, url = smnuman/zsh-prompt`) has been deleted. The file no longer exists on disk.
- `prompt/` has no submodules of its own — clean state.

### 3. `git-utils/` is a standalone repo, NOT registered as a submodule

- It has its own `.git/` and remote (`smnuman/zsh-git-utils.git`)
- It's NOT listed in `zsh/.gitmodules` — only `prompt` is listed there
- It has no `.gitmodules` of its own

### 4. Current git status (as of analysis)

- Root/zsh are `ahead 1` with staged `.gitattributes` and modified `.gitignore`, `.gsubignore`, `ai-git-setup`
- Untracked files: `GROK.md`, `dotfiles-polyrepo-handler.md`
- `prompt/` is clean (`main` tracking `origin/main`)

---

## `git-utils/` Contents Summary

### Core Files

| File | Purpose | Lines |
|---|---|---|
| `git-utils.zsh` | Main toolkit — all submodule/repo management functions | 1769 |
| `git-ai-remotes` | AI remote management (xai, openai, anthropic, google, cursor remotes) | 451 |
| `gignore-defaults.zsh` | Default patterns for `.gitignore` and `.gsubignore` generation | 121 |
| `git_users.zsh` | Empty file (placeholder) | 1 |

### Utility Scripts

| File | Purpose |
|---|---|
| `git-status-ls` | Enhanced `git status --porcelain` with human-readable labels |
| `lsg` | Full-featured `ls` with git status annotations (branch, ahead/behind, modified, staged, submodule state) — 848 lines of bash |
| `ignores` | Quick helper to append patterns to `.gitignore` |

### Config/Meta

| File | Purpose |
|---|---|
| `.gitignore` | Ignores archives, backups, logs, `old-files/`, `git_users.zsh`, `README_*.md`, `run-once-*.zsh` |
| `.gitattributes.backup` | Backup from git-crypt setup |
| `.gitcrypt` | Git-crypt encryption marker |
| `.venv/` | Python virtual environment (likely for testing) |
| `old-files/` | Archived old versions (gitignored) |

---

## Key Functions in `git-utils.zsh`

### Repository Management

| Function | What it does |
|---|---|
| `grepo` | Init + push directory as new GitHub/GitLab repo |
| `gsub` | Add directory as git submodule to parent |
| `gunsub` | Cleanly remove a submodule |
| `gsub-all` | Batch-convert folders to submodules (respects `.gsubignore`) |

### Sync Operations

| Function | What it does |
|---|---|
| `gsync` | Full fetch + push sync for submodule and parent |
| `gsync-all` | Recursively sync all submodules + parent |
| `gsync-status` | Show ahead/behind status for submodule and parent |
| `_gsync-push` | Internal: push both submodule and parent |
| `_gsync-pull` | Internal: pull both submodule and parent |
| `_gsubmod` | Internal: commit + push submodule repo |
| `_gparent` | Internal: commit + push parent repo (submodule pointers) |

### Ignore File Management

| Function | What it does |
|---|---|
| `gsub-genignore` | Generate `.gsubignore` with standard exclusions |
| `gsubignore` | Add/remove/list entries in `.gsubignore` (supports wildcards, dry-run) |
| `git-genignore` | Generate `.gitignore` from default patterns |

### Encryption & Security

| Function | What it does |
|---|---|
| `gencrypt_setup` | Setup git-crypt with auto-detection of sensitive files |
| `gitcrypt` | Add files/folders to `.gitcrypt` manifest |
| `gencrypt_check` | Check if a file is encrypted under git-crypt |
| `gsecrets` | Scan for potential secrets in unencrypted files |
| `gshook` | Install pre-commit hook for secret scanning |
| `_gsensitive` | Internal: detect sensitive files in a directory |

### Provider Helpers

| Function | What it does |
|---|---|
| `_grepo_name` | Generate standardized repo name from directory path (`parent-child` format) |
| `_githost` | Get provider (github/gitlab) from `$GIT_PROVIDER` |
| `_gurl` | Generate SSH remote URL for provider |
| `_gitcli` | Get CLI command for provider (`gh`/`glab`) |
| `_gituser` | Get username from `$GITHUB_USER`/`$GITLAB_USER` |

### Misc Utilities

| Function | What it does |
|---|---|
| `git-toggle-remote` | Switch origin between GitHub and GitLab |
| `git-aliases` | Display git aliases from config |
| `git-push-all` | Push to all configured remotes |
| `_gisolate` | Isolate a directory as its own git repo with protective `.gitignore` |
| `_backup` | Create timestamped backup of a file |

---

## Key Functions in `git-ai-remotes`

| Function | What it does |
|---|---|
| `git-ai-setup` | Add AI remotes (xai, openai, anthropic, google, cursor) to all repos under cwd |
| `git-ai-push` | Push current branch to all AI remotes |
| `git-ai-status` | Show table of all repos with their branches and remotes |
| `git-ai-doctor` | Health check: missing origins, detached HEADs, missing AI remotes |
| `git_ai::run_parallel` | Internal: run commands in parallel with concurrency limit |
| `git_ai::scope` | Internal: determine scope (cwd or provided paths) |
| `git_ai::discover_repos` | Internal: find all git repos under a path |

---

## What Needs Attention

1. **Root `.config` circular submodule**: The root repo (`config-zsh.git`) lists `zsh/` as a submodule pointing to the same `config-zsh.git` URL. This is a self-referencing loop.
2. **`git-utils/` not registered as submodule**: It exists as an independent repo inside `zsh/` but isn't tracked in `zsh/.gitmodules`. If it should be a submodule, it needs to be added.
3. **`prompt/.gitmodules` cleanup**: Already deleted. The `prompt/` repo is clean with no submodule references.
