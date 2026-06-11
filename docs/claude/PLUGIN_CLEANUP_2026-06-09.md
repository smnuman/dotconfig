# Claude Code Plugin Cleanup — Stale `oh-my-claudecode@Yeachan-Heo` Registration

**Date:** 2026-06-09
**Trigger:** `/doctor` reported `Plugin (oh-my-claudecode@Yeachan-Heo): Marketplace Yeachan-Heo not found`

## Summary

Removed a stale, duplicate registration of the `oh-my-claudecode` plugin that
pointed at a marketplace (`Yeachan-Heo`) which no longer exists. The live install
(`oh-my-claudecode@omc`, v4.14.4) was already present and unaffected; the warning
was pure leftover state from a previous install method.

## Diagnosis

```
installed_plugins.json          known_marketplaces.json
─────────────────────           ───────────────────────
oh-my-claudecode@Yeachan-Heo ──X──> "Yeachan-Heo"  (NOT DEFINED)  <- doctor error
   v4.11.5
   installPath: /opt/homebrew/lib/node_modules/
                oh-my-claude-sisyphus  (MISSING on disk)

oh-my-claudecode@omc ──────────────> "omc" (defined, repo cached)  <- the live one
   v4.14.4                                                             v4.14.4 ✓
```

Four facts confirmed the registration was stale (confidence: high):

1. `known_marketplaces.json` defines `claude-plugins-official`, `thedotmack`,
   `claude-code-plugins`, and `omc` — there is **no** `Yeachan-Heo` marketplace.
2. The plugin's recorded `installPath`
   (`/opt/homebrew/lib/node_modules/oh-my-claude-sisyphus`) is **missing** on disk.
3. A working duplicate, `oh-my-claudecode@omc` v4.14.4, exists with its repo cached
   under `~/.config/claude/plugins/cache/omc/oh-my-claudecode/4.14.4`.
4. `settings.json` had **both** variants enabled simultaneously.

**Root cause:** OMC was originally installed from a marketplace named `Yeachan-Heo`,
then later reinstalled from a marketplace named `omc` (both resolve to the same
GitHub repo, `Yeachan-Heo/oh-my-claudecode.git`). The original registration was
never cleaned up — its marketplace entry was dropped from `known_marketplaces.json`
and its install directory was removed, but it remained listed as installed and
enabled. `/doctor` flags it because the marketplace can no longer be resolved.

## Changes

Both edited files are **gitignored machine state**, so the edits live locally and
are not part of this commit (only this document is committed):

1. `~/.config/claude/settings.json`
   - Removed `"oh-my-claudecode@Yeachan-Heo": true` from `enabledPlugins`.
   - Result: `enabledPlugins` = `claude-mem@thedotmack`, `oh-my-claudecode@omc`.

2. `~/.config/claude/plugins/installed_plugins.json`
   - Removed the stale `oh-my-claudecode@Yeachan-Heo` v4.11.5 entry.

### Left intentionally untouched

- `extraKnownMarketplaces.omc.url` in `settings.json`
- `~/.claude/plugins/config.json` `repositories` entry

Both reference the URL `Yeachan-Heo/oh-my-claudecode.git` — that is the upstream
**GitHub repo name**, not the broken marketplace registration. Removing them would
be incorrect.

## Verification

- Both JSON files re-validated as well-formed after editing.
- `grep` confirmed no remaining `oh-my-claudecode@Yeachan-Heo` references in either file.
- `enabledPlugins` now lists only the two live plugins.

## Notes

- `/doctor` reads the plugin registry at session start, so the warning may persist
  for the current session and clears on the next Claude Code restart.
- The live OMC install (`@omc` v4.14.4) was not modified and continues to function.
- Because `settings.json` and `installed_plugins.json` are gitignored, this fix must
  be re-applied manually on any other machine that carries the same stale state.
