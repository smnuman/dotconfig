# 🧭 NOMAD System Master Plan

> **Maintained by:** Numan Syed  
> **Time Zone:** GMT+6  
> **Repository:** Private (Encrypted Submodule)  
> **Status:** In Progress

---

## 1. Philosophy

**NOMAD Setup = Minimal + Modular + Portable + Reproducible**

Designed for seamless migration between devices and environments.  
All configs live in a unified `~/.config` tree, are version-controlled, and self-documented.

Goals:

- Fully reproducible environment in minutes on a fresh system.
- Modular and replaceable configuration for each tool.
- Balance between terminal productivity, aesthetics, and maintainability.
- Integration with GitHub, GitLab, and optional cloud/VPS mirrors.

> ✅ macOS Sequoia 15.6 (Apple M1, MacBook Air) confirmed as baseline system.

---

## 2. Structure Overview

| Layer                     | Focus                          | Tools/Actions                          |
| ------------------------- | ------------------------------ | -------------------------------------- |
| **1. Environment Base**   | OS, shells, package managers   | macOS/Linux, Homebrew, coreutils       |
| **2. Dotfiles Framework** | Modular Zsh, Git, Tmux         | `~/.config/zsh`, plugin loader         |
| **3. Dev Environment**    | Python, Node, Rust, Ruby       | pipx, pyenv, npm global mgmt           |
| **4. Productivity Layer** | File, search, monitoring tools | exa, bat, fzf, rg, zoxide, btop        |
| **5. Automation Layer**   | Ansible + shell scripts        | system bootstrap, updates              |
| **6. Workspace Layer**    | Projects & Income streams      | NT8 scripting, web apps, AI automation |
| **7. Backup + Sync**      | Portability & recovery         | GitHub + GitLab, encrypted backups     |
| **8. Cloud + Remote**     | Mirror setups                  | VPS, Codespaces, SSH targets           |
| **9. Aesthetic Layer**    | UI polish                      | LS_COLORS, prompt, NerdFonts           |
| **10. Docs + Help**       | Self-documenting system        | Markdown docs, inline help             |

---

## 3. Folder Tree (Initial Draft)

```
~/.config/
│
├── zsh/
│   ├── env.zsh
│   ├── zsh-aliases
│   ├── git-utils/
│   │   └── git-utils.zsh
│   ├── utils/
│   ├── lib/
│   └── prompt/
│
├── nvim/
│   ├── init.lua
│   ├── lua/
│   └── plugins/
│
├── brew/
│   ├── Brewfile
│   ├── install.sh
│   └── utils/
│
├── tmux/
│   ├── tmux.conf
│   └── utils/
│
├── ansible/
│   ├── playbooks/
│   ├── roles/
│   ├── inventory/
│   └── bootstrap.yml
│
└── scripts/
    ├── system/
    ├── dev/
    ├── git/
    └── sync/
```

> Note: The actual username used within Git automation functions (e.g. `grepo`, `gsub`, `gsubmod`) is dynamically derived within `zsh/git-utils/git-utils.zsh`, **not** hardcoded. The same file also defines the encryption mechanism using `git-crypt`—to be referenced during encryption setup.
>
> Additionally, numerous alias definitions (including advanced `ls` aliases and other productivity shortcuts) are available in `zsh/zsh-aliases`. These will be consulted during phase planning and integration.
>
> Future subfolders or refinements will be added progressively as the system evolves.

---

## 4. Implementation Plan

| Phase                          | Goal                                     | Duration (hrs) |
| ------------------------------ | ---------------------------------------- | -------------- |
| **1. Foundation Setup**        | Confirm Homebrew, Git, SSH, Python, Node | 2–3            |
| **2. Dotfiles Framework**      | Modular Zsh + plugin loader + structure  | 3–4            |
| **3. Dev Stack Integration**   | Python, Node, Rust, Ruby setup           | 3              |
| **4. Productivity Tools**      | exa, bat, fzf, zoxide, rg, etc.          | 2              |
| **5. Neovim Setup**            | Lua config, plugin management            | 4              |
| **6. Tmux Integration**        | Persistence + shortcuts                  | 2              |
| **7. Git + Submodules System** | grepo, gsub, gsubmod utilities           | 3              |
| **8. Automation via Ansible**  | Bootstrap playbooks                      | 5              |
| **9. Docs + Help System**      | READMEs + help commands                  | 3              |
| **10. Backup + Sync + Polish** | GitHub/GitLab + themes                   | 4              |

**Total:** ~30 hours over 5 working days.

---

## 5. Timeline

| Day       | Focus                  | Deliverable                          |
| --------- | ---------------------- | ------------------------------------ |
| **Day 1** | Foundation + Zsh setup | Functional shell + env baseline      |
| **Day 2** | Dev stack + tools      | All language stacks functional       |
| **Day 3** | Neovim + Tmux          | Editor + multiplexer ready           |
| **Day 4** | Git + Automation       | Submodules + Ansible bootstraps      |
| **Day 5** | Backup + Docs          | Fully reproducible NOMAD environment |

---

## 6. Encryption & Repository Strategy

- The `~/.config/nomad` folder will be **encrypted** using `git-crypt` for both GitHub and GitLab.
- Both platforms fully support `git-crypt`; the same GPG keys can be shared for cross-repo access.
- The encryption setup defined in `zsh/git-utils/git-utils.zsh` will be used as the system standard.
- Public release will only occur after a full audit and sanitisation.

**Structure:**

```
~/.config/nomad/
│
├── PLAN.md           # This file
├── bootstrap.sh      # Environment installer
├── secrets/          # Encrypted credentials, keys
├── ansible/          # Playbooks for automation
└── docs/             # Internal documentation
```

---

## 7. Next Steps

1. ✅ Baseline confirmed: macOS Sequoia 15.6, Apple M1, MacBook Air.
2. 🔐 Encryption confirmed: `git-crypt` to be used for both GitHub and GitLab (defined in `git-utils.zsh`).
3. 🧩 Integrate all existing configurations and scripts from prior sources.
4. 🗂 Create `~/.config/nomad` folder locally.
5. 🚀 Begin **Phase 1: Foundation Setup** — Zsh + Homebrew integration.
6. 📘 Review `zsh-aliases` for inclusion in automation and docs.

---

## 8. Update Log

| Date       | Change                        | Notes                                    |
| ---------- | ----------------------------- | ---------------------------------------- |
| 2025-10-18 | Initial version created       | Setup roadmap + encryption plan          |
| 2025-10-18 | System & encryption confirmed | macOS Sequoia + git-crypt for both repos |
| 2025-10-18 | Repo + alias mapping refined  | git-utils path & alias integration added |

---

> **Next Action:** Begin implementation of Phase 1 (Foundation Setup) and ensure integration of all existing configs and utilities.

