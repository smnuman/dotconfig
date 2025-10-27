#!/usr/bin/env zsh
# ============================================================================
# Warp Launch Helper (Nomad Edition)
# Author: Numan Syed
# Last Updated: 2025-10-23 (+0600)
# ============================================================================
#
# Description:
#   Launches a saved Warp "launch configuration" (.yaml) directly from CLI,
#   Alfred, or Raycast by name. Works seamlessly with symlinked config folders.
#
# Usage:
#   warp-launch <config_name>
#   warp-launch "My Project"
#
# ============================================================================
set -e

LAUNCH_DIR="$HOME/.config/warp/launch_configurations"

if [[ -z "$1" ]]; then
  echo "Usage: warp-launch <config_name>"
  echo "Available configurations:"
  ls -1 "$LAUNCH_DIR" | sed 's/.yaml//'
  exit 1
fi

TARGET="$LAUNCH_DIR/$1.yaml"

if [[ ! -f "$TARGET" ]]; then
  echo "❌ Launch configuration not found: $TARGET"
  echo "Available:"
  ls -1 "$LAUNCH_DIR" | sed 's/.yaml//'
  exit 1
fi

echo "🚀 Launching Warp configuration: $1"

# Use AppleScript (JXA) to tell Warp to open the config
osascript <<EOF
tell application "Warp"
    activate
    open POSIX file "$TARGET"
end tell
EOF

echo "✅ Warp should now open with the '$1' configuration."
