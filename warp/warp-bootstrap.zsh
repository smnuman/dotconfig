#!/usr/bin/env zsh
# ============================================================================
# Warp Bootstrap Script (Nomad Dotfiles Integration)
# Maintainer: Numan Syed
# Last Updated: 2025-10-22 (+0600)
# ============================================================================
#
# Description:
#   Automates Warp configuration setup for a Nomadic dotfile workflow.
#   - Detects system paths and ensures consistency
#   - Creates required folders
#   - Sets up symlinks for Warp configuration
#   - Provides a warp_sync() helper to manually sync settings
#
# Usage:
#   source ~/.config/warp/warp-bootstrap.zsh
#   warp_setup        # One-time setup
#   warp_sync         # Manual sync anytime
#
# ============================================================================

# --- Paths ---
export WARP_APP_SUPPORT="$HOME/Library/Application Support/dev.warp.Warp-Stable"
export WARP_CONFIG_DIR="$HOME/.config/warp"
export WARP_LAUNCH_DIR="$HOME/.warp/launch_configurations"
export WARP_LOG_FILE="$HOME/.config/logs/warplog.zsh"

# --- Logging helper ---
warp_log() {
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  print -P "%F{cyan}[Warp]%f $1"
  mkdir -p "${WARP_LOG_FILE:h}"
  echo "[$timestamp] $1" >> "$WARP_LOG_FILE"
}

# --- Setup Warp symlinks ---
warp_setup() {
  warp_log "Initialising Warp Nomadic setup..."

  # Ensure directories exist
  mkdir -p "$WARP_CONFIG_DIR"
  mkdir -p "$WARP_APP_SUPPORT"
  mkdir -p "$HOME/.warp"

  # Create symlinks
  ln -sfn "$WARP_LAUNCH_DIR" "$WARP_CONFIG_DIR/launch_configurations"
  ln -sfn "$WARP_APP_SUPPORT" "$WARP_CONFIG_DIR/state"

  # Backlink Warp folders for consistency
  ln -sfn "$WARP_CONFIG_DIR/state" "$WARP_APP_SUPPORT"
  ln -sfn "$WARP_CONFIG_DIR/launch_configurations" "$HOME/.warp/launch_configurations"

  warp_log "Symlinks established."
  warp_log "Configuration directories ensured at: ${(q)WARP_CONFIG_DIR} and ${(q)WARP_APP_SUPPORT}"
  warp_log "Warp configuration is now portable under ~/.config/warp/"
}

# --- Sync Warp configuration ---
warp_sync() {
  warp_log "Syncing Warp configuration from App Support to ~/.config/warp/state..."
  rsync -a --exclude 'Cache' --exclude 'Logs' "$WARP_APP_SUPPORT/" "$WARP_CONFIG_DIR/state/"
  warp_log "✅ Warp configuration synced."
  warp_log "Synced contents from ${(q)WARP_APP_SUPPORT} to ${(q)${WARP_CONFIG_DIR}/state/}"
}

# --- Optional cleanup ---
warp_cleanup() {
  warp_log "Cleaning existing Warp symlinks and restoring defaults..."
  rm -f "$WARP_CONFIG_DIR/state"
  rm -f "$WARP_CONFIG_DIR/launch_configurations"
  rm -f "$HOME/.warp/launch_configurations"
  warp_log "Cleanup complete."
  warp_log "Warp cleanup logged at $(date '+%H:%M:%S')."
}

# --- Launch Warp configuration ---
warp_launch() {
  local cfg_name="$1"
  local launcher="$HOME/.config/warp/utils/warp-launch.sh"

  if [[ -z "$cfg_name" ]]; then
    warp_log "Usage: warp_launch <config_name>"
    return 1
  fi

  if [[ ! -x "$launcher" ]]; then
    warp_log "⚠️  warp-launch.sh not found or not executable at $launcher"
    return 1
  fi

  warp_log "Launching Warp configuration '$cfg_name'..."
  "$launcher" "$cfg_name" && warp_log "✅ Warp launch executed for '$cfg_name'"
}

warp_log "Warp launch helper available via 'warp_launch <name>'"

warp_log "Bootstrap script loaded. Use 'warp_setup' to initialise or 'warp_sync' to update."
