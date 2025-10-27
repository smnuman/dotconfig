# Warp Configuration (Nomad Dotfiles Integration)

> **Maintainer:** Numan Syed  
> **Purpose:** Integrate Warp terminal configuration into a portable, version-controlled Nomadic dotfile system.  
> **Last Updated:** 2025-10-23 (+0600)

---

## 🧭 Overview

Warp currently lacks a *readable or exportable* configuration file (e.g., `warp.toml`).  
Most of its settings are stored in internal application folders.  
This setup bridges that gap — allowing you to **sync, back up, and version-control** Warp settings within your dotfiles until Warp provides an official solution.

---

## 📁 Folder Structure

| Path | Description |
|------|--------------|
| `~/.config/warp/` | Main Warp config folder (tracked under git) |
| `~/.config/warp/launch_configurations/` | Symlinked from `~/.warp/launch_configurations/` |
| `~/.config/warp/state/` | Symlinked from `~/Library/Application Support/dev.warp.Warp-Stable/` |
| *(optional)* `~/.config/warp/bootstrap.zsh` | Script to set up or sync this structure automatically |

---

## ⚙️ Implementation Steps

### 1. Create the config directory
```bash
mkdir -p ~/.config/warp
```

### 2. Link Warp's native folders
```bash
ln -sfn ~/.warp/launch_configurations ~/.config/warp/launch_configurations
ln -sfn ~/Library/Application\ Support/dev.warp.Warp-Stable ~/.config/warp/state
```

### 3. (Optional) Add to version control
```bash
cd ~/.config
git add warp
git commit -m "Add Warp configuration symlinks"
```

> 💡 Exclude caches and logs (`~/Library/Caches/dev.warp.Warp-Stable`, `~/Library/Logs/Warp/`)  
> These are temporary and should not be versioned.

---

## 🔁 Syncing Configuration Changes

Create a helper script or function (`warp_sync`) to mirror Warp settings to your config repo:

```bash
warp_sync() {
  local warp_lib="$HOME/Library/Application Support/dev.warp.Warp-Stable"
  local warp_cfg="$HOME/.config/warp/state"
  echo "🔄 Syncing Warp configuration..."
  rsync -a --exclude 'Cache' --exclude 'Logs' "$warp_lib/" "$warp_cfg/"
  echo "✅ Warp configuration synced to ~/.config/warp"
}
```

Run `warp_sync` after you make changes in Warp preferences.

---

## 🧳 Redeploying on a New Machine

When setting up a fresh system:

```bash
# Restore your dotfiles repo
git clone git@github.com:smnuman/dotfiles.git ~/.config

# Re-create Warp’s expected directories
mkdir -p ~/Library/Application\ Support/dev.warp.Warp-Stable

# Re-link Warp config
ln -sfn ~/.config/warp/state ~/Library/Application\ Support/dev.warp.Warp-Stable
ln -sfn ~/.config/warp/launch_configurations ~/.warp/launch_configurations
```

Warp will automatically load your settings from the symlinked folders.

---

## 🧩 Future Migration Plan (When Warp Introduces Native Config Export)

When Warp releases an official exportable configuration file (likely `warp.toml` or similar):

1. **Locate the native file** — typically expected at  
   `~/.config/warp/warp.toml` or `~/.warp/config.toml`.

2. **Remove legacy symlinks:**
   ```bash
   rm ~/.config/warp/state
   rm ~/.config/warp/launch_configurations
   ```

3. **Adopt the new native config file:**
   ```bash
   mv <path-to-native-file> ~/.config/warp/warp.toml
   git add ~/.config/warp/warp.toml
   git commit -m "Adopt native Warp config file"
   ```

4. **Deprecate sync helpers** (no longer needed once official config is plain-text).

---

## 🔒 Notes & Best Practices

- Always back up before syncing or replacing symlinks.  
- Warp stores some sensitive data (workspace tokens, login credentials) in its internal folders — ensure your `.gitignore` excludes such files if they appear.  
- Re-run `warp_sync` after each preference change.  
- Keep this `README.md` for future maintainers or transitions.

---

## 🧠 References

- [Warp Issue #3447 – Feature Request: Export/Access Readable Config File](https://github.com/warpdotdev/Warp/issues/3447)  
- [Warp Official Docs](https://docs.warp.dev/)  
- [macOS Application Support Directory Convention](https://developer.apple.com/documentation/)  

---

## 🚀 Launch Helper Integration

To open Warp “launch configurations” directly from CLI, Alfred, or Raycast,  
use the included helper script: `~/.config/warp/utils/warp-launch.sh`.

### Usage
```bash
warp_launch <config_name>
```
**Example:**
```bash
warp_launch blog
```

This triggers Warp to open the specified YAML configuration (from  
`~/.config/warp/launch_configurations/`).

The bootstrap script automatically provides the `warp_launch` function.  
All launches are logged in `~/.config/logs/warplog.zsh`.

### Integration

You can integrate the launcher into external tools for quick access:

- **`Raycast:`** Add a script command pointing to:  
  `~/.config/warp/utils/warp-launch.sh "{query}"`
- **`Alfred:`** Add a “Run Script” step invoking:  
  `~/.config/warp/utils/warp-launch.sh "{query}"`

---

Once you’ve added both, run:
```bash
source ~/.config/warp/warp-bootstrap.zsh
```
Then test it:
```bash
warp_launch my-project
```
and it’ll launch your project in Warp and log it in `~/.config/logs/warplog.zsh`.

---

**Nomad Strategy Context:**  
This method aligns with the *portable, reproducible setup* ethos — ensuring your Warp terminal behaves identically across any workstation in your nomadic workflow.

---

> _“Until Warp gives us `warp.toml`, we give ourselves reproducibility.”_  
> — **Numan Syed**
