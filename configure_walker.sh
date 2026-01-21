#!/bin/bash
# Configure Walker for iconify custom menu

RED='\033[0;31m'
NC='\033[0m'

# Handle sudo: use actual user's home, not root's
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

WALKER_CONFIG="$USER_HOME/.config/walker/config.toml"

if [ ! -f "$WALKER_CONFIG" ]; then
  echo "${RED} Walker config not found at $WALKER_CONFIG ${NC}"
  exit 1
fi

# Check if iconify is already configured
if grep -q '"menus:iconify" = \[' "$WALKER_CONFIG"; then
  echo "Iconify is already configured in your Walker config"
  exit 0
fi

# Create backup
BACKUP="${WALKER_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$WALKER_CONFIG" "$BACKUP"
echo "Backup created: $BACKUP"

ICONIFY_CONFIG=' "menus:iconify" = [
  { action = "copy_name", label = "Copy name", bind = "Return", default = true },
  { action = "copy_svg", label = "Copy svg", bind = "ctrl s"  },
  { action = "toggle_search_all", label = "All", bind = "ctrl a", after = "AsyncReload" },
  { action = "toggle_search_lucide", label = "Lucide", bind = "ctrl l", after = "AsyncReload" },
  { action = "toggle_search_hugeicons", label = "Hugeicons", bind = "ctrl h", after = "AsyncReload" },
  { action = "toggle_search_phosphor", label = "Phosphor", bind = "ctrl p", after = "AsyncReload" },
  { action = "toggle_search_tabler", label = "Tabler", bind = "ctrl t", after = "AsyncReload" },
]'

# Check if [providers.actions] section exists
if grep -q '\[providers.actions\]' "$WALKER_CONFIG"; then
  # Create temp file with numr config inserted after [providers.actions]
  awk -v cfg="$ICONIFY_CONFIG" '
        /\[providers.actions\]/ { print; print cfg; next }
        { print }
    ' "$WALKER_CONFIG" >"${WALKER_CONFIG}.tmp"
  mv "${WALKER_CONFIG}.tmp" "$WALKER_CONFIG"
else
  # Append new section at end
  echo "" >>"$WALKER_CONFIG"
  echo "[providers.actions]" >>"$WALKER_CONFIG"
  echo "$ICONIFY_CONFIG" >>"$WALKER_CONFIG"
fi

echo "Walker configured for iconify"
