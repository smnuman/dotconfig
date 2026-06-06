# Agentkit Installation

- Date: 2026-02-22
- Source repo: https://github.com/developerinlondon/agentkit
- Local clone: ~/codes/agentkit

## Overview

Agentkit is a reusable AI agent skills, rules, plugins, hooks, and tools collection by @developerinlondon. It targets three AI coding tools simultaneously: OpenCode, Claude Code, and Codex CLI. Installed globally via `install.sh --global`.

## What Was Installed

### OpenCode Plugins (registered in opencode.json)

- **git-police.ts** at ~/.agents/plugins/git-police.ts — Blocks commits to main/master, force push, --no-verify, AI attribution (Co-authored-by), push to protected branches. Configurable allowed-repos in ~/.config/agentkit/config.yaml. Registered in opencode.json as file:// plugin entry.
- **format-police.ts** at ~/.agents/plugins/format-police.ts — Auto-formats files on write/edit using dprint. Auto-discovers dprint binary from PATH or mise. Registered in opencode.json as file:// plugin entry.
- **version-police.ts** at ~/.agents/plugins/version-police.ts — Checks Helm chart/npm/Cargo dependency versions when editing Chart.yaml, package.json, or Cargo.toml. Session-deduplicated to avoid repeated checks. Forces update to latest version. Registered in opencode.json as file:// plugin entry.

### OpenCode Skills (auto-discovered from ~/.agents/skills/)

- **autonomous-workflow** at ~/.agents/skills/autonomous-workflow/SKILL.md — Proposal-first development: never create/modify files without approval. Decision authority matrix (fix bugs without asking, but ask before architecture changes). Commit hygiene (no --force, no --no-verify, no AI attribution). Unused variable policy (never prefix with underscore, either use or remove).
- **code-quality** at ~/.agents/skills/code-quality/SKILL.md — Warnings-as-errors policy. No underscore prefixes for unused vars. Mandatory test coverage for new functions. Type safety (no as any, no @ts-ignore, no @ts-expect-error, no empty catch blocks, no deleting failing tests).
- **documentation** at ~/.agents/skills/documentation/SKILL.md — ASCII box-drawing diagrams only (not Mermaid). Plan file format with status/dates/dependencies. Compact tables for comparisons. Code blocks with language tags.

### OpenCode Rules (auto-loaded by glob from ~/.agents/rules/)

- **consent-protocol.md** at ~/.agents/rules/consent-protocol.md, glob: **/* — "If your response contains a question, your turn is over." Prevents agents from asking a question AND taking action in the same response. Applied globally to all files.

### Claude Code Hooks (in ~/.claude/settings.json)

- **git-police.sh** at ~/.claude/hooks/git-police.sh — PreToolUse hook on Bash tool. Same git safety rules as the OpenCode plugin, implemented as a bash script for Claude Code's hook system.
- **format-police.sh** at ~/.claude/hooks/format-police.sh — PostToolUse hook on Edit|Write tools. Auto-formats files using dprint after every edit/write.

### Claude Code Tools

- **fix-ascii-boxes.py** at ~/.claude/tools/fix-ascii-boxes.py — Fixes ASCII box-drawing alignment in markdown files. Handles nested boxes inside-out.

### Codex CLI Policies

- **git-police.rules** at ~/.codex/rules/git-police.rules — Starlark policy enforcing the same git safety rules for OpenAI's Codex CLI.

### Configuration

- **config.yaml** at ~/.config/agentkit/config.yaml — Agentkit configuration. Currently supports git-police.branch-protection.allowed-repos to exempt specific repos from branch protection rules (e.g., dotfiles repos where direct commits to main are acceptable).

## What Was Skipped

- **project-planning skill** — GSD (Get Shit Done) slash commands already provide a far more sophisticated project planning system with questioning, research, requirements, roadmap, wave-based execution, verification, and milestone management.
- **gitops-master skill** — ArgoCD + Kargo specific. Not relevant to current development setup.
- **issue-raiser skill** — GitLab-specific. Current workflow uses GitHub.
- **kubectl-police plugin/hook/policy** — Blocks kubectl create/apply for Kargo CRDs. Not relevant without Kargo/GitOps workflows.
- **credential-bootstrap rule** — OpenBao + ESO credential bootstrap pattern for GitOps apps. Not relevant.

## Also Analyzed: Assay

Assay (https://github.com/developerinlondon/assay) is a Rust + Lua 5.5 runtime for Kubernetes (~9MB binary) that was analyzed but not installed. It's a K8s verification/scripting tool with 23 embedded stdlib modules for Prometheus, Grafana, ArgoCD, Kargo, Vault, etc. Potential future use: verification backend for GSD's verify-work command, or lightweight MCP server via Lua's http.serve(). Local clone at ~/codes/assay.

## Config Files Modified

- ~/.config/opencode/opencode.json — Added 3 file:// plugin entries to the plugin array
- ~/.claude/settings.json — Created by installer with PreToolUse (git-police) and PostToolUse (format-police) hooks. kubectl-police hook was removed post-install.
- ~/.config/agentkit/config.yaml — Created by installer with default config

## Maintenance

- Update: re-run `~/codes/agentkit/install.sh --global` to update all components
- Upstream: `cd ~/codes/agentkit && git pull` to fetch latest from upstream
- Config: Edit ~/.config/agentkit/config.yaml to customize git-police allowed repos
- Format-police requires dprint binary in PATH or installed via mise

## File Tree Summary

```
~/.agents/
├── plugins/
│   ├── format-police.ts
│   ├── git-police.ts
│   └── version-police.ts
├── rules/
│   └── consent-protocol.md
└── skills/
    ├── autonomous-workflow/
    │   └── SKILL.md
    ├── code-quality/
    │   └── SKILL.md
    └── documentation/
        └── SKILL.md

~/.claude/
├── hooks/
│   ├── format-police.sh
│   └── git-police.sh
├── settings.json
└── tools/
    └── fix-ascii-boxes.py

~/.codex/
└── rules/
    ├── default.rules
    └── git-police.rules

~/.config/
├── agentkit/
│   └── config.yaml
└── opencode/
    └── opencode.json (modified)
```
