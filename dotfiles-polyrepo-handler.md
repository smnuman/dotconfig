# Git Handling Directions for `dotconfig` Project

## Overview
This document outlines Git strategies for the `dotconfig` project, located at `~/.config`. It's designed for nomadic, portable deployment across Mac, Windows, and Linux. We use a polyrepo approach (not a monorepo) where `dotconfig` acts as a wrapper repo aggregating sub-projects. Sub-projects (own and third-party) are included via Git submodules for versioning and easy updates, ensuring deployment is painless without scattering repos.

Key principles:
- **Portability**: Everything bundles into one cloneable repo for quick setup on new machines.
- **No monorepo bloat**: Sub-projects remain independent repos but are referenced/included in `dotconfig`.
- **Multi-provider remotes**: Start with GitHub, mirror to GitLab, expand as needed for redundancy.
- **Deployment focus**: Submodules allow pulling updates without manual copies; use scripts for install (e.g., symlink configs).

## Repository Naming Convention

Almost all automation depends on this pattern:

- Local path:  `~/.config/some/tool` or `~/projects/team/web-ui`
- Remote name: `some-tool` or `team-web-ui`
- Rule:        `parent-dir` + `-` + `current-dir` (dots → `-`, strip leading/trailing dots)

Examples:
- `~/.config/zsh`          → `config-zsh`
- `~/.config/zsh/prompt`   → `zsh-prompt`
- `~/projects/acme/frontend` → `acme-frontend`

Only Exception:
- `~/.config`               → `dotconfig`

This name is used by:
- `grepo`, `gsub`, `gsub-all`
- `git-ai-setup` (must match origin name)

## AI Provider Remotes

The command `git-ai-setup` adds the following extra remotes to matching repositories:

| Remote name  | URL pattern                                  | Purpose                              |
|--------------|----------------------------------------------|--------------------------------------|
| xai          | git@github.com:YOUR_USER/REPO.git            | xAI / Grok related work              |
| openai       | git@github.com:YOUR_USER/REPO.git            | OpenAI related work                  |
| anthropic    | git@github.com:YOUR_USER/REPO.git            | Claude / Anthropic related work      |
| google       | git@github.com:YOUR_USER/REPO.git            | Gemini / Google related work         |
| cursor       | git@github.com:YOUR_USER/REPO.git            | Cursor / AI IDE related work         |

These are **not real mirrors** — they are **logical namespaces** on your GitHub account.


## General Git Operations
- **Init and Clone**: Always init `dotconfig` fresh or clone from primary remote (GitHub).
  - Command: `git clone git@github.com:yourusername/dotconfig.git ~/.config`
- **Branching Strategy**: Use `main` for stable, feature branches for changes (e.g., `git checkout -b feat/new-subproject`).
- **Commits**: Atomic, descriptive. Use conventional commits: `feat: add submodule`, `fix: update remote`.
- **Pull/Push**: Always pull before push: `git pull --rebase origin main`.
- **Conflicts**: Resolve manually; prefer rebase over merge for clean history.
- **Ignore Files**: Add `.gitignore` for temp files, OS-specific junk (e.g., `.DS_Store`).
- **Ignore Folders**: Add `.gsubignore` for submodule folders.
- **Hooks**: Use pre-commit hooks for linting (install via `pre-commit install` if using the tool).

## Handling Remotes
Manage multiple providers for redundancy. Primary: GitHub. Mirrors: GitLab, others later.

- **Add Remotes**:
  1. Init or clone primary: `git remote add origin git@github.com:yourusername/dotconfig.git`
  2. Add mirror: `git remote add gitlab git@gitlab.com:yourusername/dotconfig.git`
  3. For others (e.g., Bitbucket): `git remote add bitbucket git@bitbucket.org:yourusername/dotconfig.git`
- **Push to All**: Use a script or alias: `git push origin main && git push gitlab main`
- **Sync Mirrors**: Pull from primary, push to all. Handle divergences by force-pushing if needed (carefully: `git push gitlab main --force-with-lease`).
- **Switch Primary**: If GitHub down, set GitLab as temp origin: `git remote set-url origin git@gitlab.com:yourusername/dotconfig.git`


## Overview – Naming & Structure

**Local path**          | **Remote repo name**     | **Role**
------------------------|--------------------------|--------------------------------------
`~/.config/`            | `dotconfig`              | Main wrapper / aggregator repo
`~/.config/brew`        | `config-brew`            | Homebrew / Brew Bundle configuration
`~/.config/zsh`         | `config-zsh`             | Zsh configuration
`~/.config/zsh/prompt`  | `zsh-prompt`             | Custom prompt (nested submodule)

- The local folder is **never** called `dotconfig` on disk.
- The name `dotconfig` exists **only** as the Git remote repository name.
- All submodule paths use the **final local name** (`brew`, `zsh`, `prompt`), **not** the remote repo name.

## .gitmodules – Main repo (`~/.config/`)

```ini
[submodule "brew"]
	path = brew
	url = git@github.com:YOUR_USERNAME/config-brew.git
	branch = main

[submodule "zsh"]
	path = zsh
	url = git@github.com:YOUR_USERNAME/config-zsh.git
	branch = main
```
## Nested submodule– inside `~/.config/zsh/`
```ini
[submodule "prompt"]
	path = prompt
	url = git@github.com:YOUR_USERNAME/zsh-prompt.git
	branch = main

```

## Clone / Bootstrap one-liner (example)
```sh
# Option A – fresh machine
git clone --recurse-submodules git@github.com:YOUR_USERNAME/dotconfig.git ~/.config

# Option B – already have ~/.config but not yet a repo
cd ~/.config
git init
git remote add origin git@github.com:YOUR_USERNAME/dotconfig.git
git fetch origin
git checkout main
git submodule update --init --recursive
```
## Quick install / update script skeleton
```sh
#!/usr/bin/env zsh
set -euo pipefail

cd ~/.config

echo "→ Updating main repo + submodules"
git pull --recurse-submodules=on-demand
git submodule update --init --recursive

echo "→ Deploying (symlinks / stow / copy)"
# Example with symlinks
ln -sf ~/.config/brew   ~/.config/brew   # usually not needed
ln -sf ~/.config/zsh    ~/.config/zsh    # usually not needed

# Or use GNU stow if you prefer
# stow --target="$HOME" --restow brew zsh

echo "Done."
```


## Including Sub-Projects (Current)

| Repo Name       | Submodule Path (in dotconfig) | Local Target       |
|-----------------|-------------------------------|--------------------|
| `config-brew`   | `brew`                        | `~/.config/brew`   |
| `config-zsh`    | `zsh`                         | `~/.config/zsh`    |
| `zsh-prompt`    | `zsh/prompt` (nested)         | `~/.config/zsh/prompt` |

**Add commands:**
```sh
git submodule add .../config-brew.git brew
git submodule add .../config-zsh.git  zsh
```

- **Add Own Sub-Project**:
  1. Create separate repo (e.g., `git init projectA && cd projectA && git remote add origin git@github.com:yourusername/projectA.git`)
  2. In `dotconfig`: `git submodule add git@github.com:yourusername/projectA.git subprojects/projectA`
  3. Commit: `git commit -m "feat: add projectA submodule"`

- **Add Third-Party**:
  1. `git submodule add https://github.com/thirdparty/repo.git subprojects/thirdparty-repo`
  2. Commit as above.

- **Update Submodules**:
  - Init after clone: `git submodule update --init --recursive`
  - Pull updates: `git submodule update --remote --merge`
  - For all: `git submodule foreach git pull origin main`

- **Deployment**:
  - Post-clone script: Symlink sub-project files to `~/.config` paths.
  - Example zsh script (`deploy.sh`):
    ```sh
    #!/usr/bin/env zsh
    cd ~/.config/dotconfig
    git submodule update --init --recursive
    ln -s subprojects/projectA/config ~/.config/projectA-config
    # Add more symlinks or copies as needed
    ```

## Quick Reference / Cookbook

Most common day-to-day commands (assuming you are inside `~/.config`):

| Action                              | Command                                                | Notes / When to use                                 |
|-------------------------------------|--------------------------------------------------------|-----------------------------------------------------|
| Update everything (pull + submodules) | `udot` or `~/.config/update.zsh`                      | Daily / after new machine                           |
| Commit + push submodule changes     | `_gsubmod "message"`                                   | Inside submodule (zsh/, brew/, prompt/, etc.)      |
| Commit + push parent (pointers)     | `_gparent "message"`                                   | Inside `~/.config` after submodule update          |
| Full sync (submodule → parent)      | `gsync "message"`                                      | Most common sync flow                               |
| Sync all submodules + parent        | `gsync-all "message"`                                  | When many submodules changed                        |
| Create new standalone repo          | `grepo "Initial commit" [custom-name]`                 | For new component before submodule                  |
| Add folder as submodule             | `gsub foldername "Adding submodule" [custom-name]`     | Most common way to add new piece                    |
| Bulk add folders as submodules      | `gsub-all "Adding components" [options]`               | When bootstrapping or reorganizing                  |
| Remove submodule cleanly            | `gunsub brew`                                          | When you want to stop tracking a component         |
| Switch github ↔ gitlab origin       | `git-toggle-remote`                                    | When changing primary provider                      |
| Show sync status                    | `gsync-status`                                         | Quick health check                                  |
| Check for secrets                   | `gsecrets`                                             | Before sensitive commit                             |
| Setup git-crypt if needed           | `gencrypt_setup`                                       | Usually auto-called by grepo/gsub                   |

## 2. Bootstrap script for new machines

Create this file: `~/.config/bootstrap.zsh`

```sh
#!/usr/bin/env zsh
# ~/.config/bootstrap.zsh
# One-shot setup for fresh machine

set -euo pipefail

REPO_URL="git@github.com:YOUR_USERNAME/dotconfig.git"
TARGET="$HOME/.config"

print -P "%F{blue}→ Bootstrapping dotfiles into ${TARGET}%f"

# 1. Clone main repo + submodules
if [[ ! -d "${TARGET}/.git" ]]; then
    print -P "%F{yellow}Cloning fresh...%f"
    git clone --recurse-submodules "$$   {REPO_URL}" "   $${TARGET}"
else
    print -P "%F{yellow}Already exists → pulling latest...%f"
    cd "${TARGET}"
    git fetch --all
    git checkout main
    git pull --recurse-submodules=on-demand
    git submodule update --init --recursive
fi

# 2. Run update script (ensures latest state)
print -P "%F{cyan}→ Running update...%f"
"${TARGET}/update.zsh" || print -P "%F{red}Update failed – check manually%f"

# 3. Optional post-clone actions (add your own)
# source "${TARGET}/zsh/env.zsh"          # if you want immediate env
# zsh -c "source ${TARGET}/zsh/.zshrc"    # reload zshrc

print -P "%F{green}✓ Bootstrap complete.%f"
print -P "  Start a new shell or run: source ~/.zshrc"
```
### Make executable:
```sh
chmod +x ~/.config/bootstrap.zsh
```
### Usage on new machine:
```sh
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotconfig/main/bootstrap.zsh)"
```
or just:
```sh
zsh ~/.config/bootstrap.zsh   # after manual clone
```
## 3. Multi-remote support (GitHub + GitLab)
Add this function to `~/.config/zsh/git-utils/git-utils.zsh` (or wherever you keep utilities):
```sh
# Push to all configured remotes
git-push-all() {
    local branch="$$   {1:-   $$(git rev-parse --abbrev-ref HEAD)}"
    local remotes=($$   (git remote | grep -E '^(origin|github|gitlab|bitbucket)   $$'))

    [[ ${#remotes[@]} -eq 0 ]] && { echo "No known remotes found."; return 1; }

    for remote in "${remotes[@]}"; do
        print -P "%F{cyan}→ Pushing to $$   {remote}/   $${branch}%f"
        git push "$$   {remote}" "   $${branch}" || {
            print -P "%F{yellow}Push to ${remote} failed – skipping%f"
        }
    done

    print -P "%F{green}Push to all remotes completed.%f"
}

# Optional: alias
# alias gpa='git-push-all'
```

### Usage examples:
```sh
git-push-all                # current branch to all remotes
git-push-all main           # explicit branch
```
### You can also extend `gsync` to call `git-push-all` instead of plain `git push`:
```sh
# Inside _gsync-push() or gsync() replace git push with:
git-push-all "$branch" || print -P "%F{yellow}Multi-remote push had issues%f"
```

This template is deployable out-of-the-box. Run `git add dotfile-polyrepo-handler.md && git commit -m "docs: add git handling directions"` to include it in your repo.

If this misses specifics (e.g., exact sub-projects or tools), clarify: 1) List a third-party example? 2) Any anti-submodule prefs? 3) Deployment OS priorities?
