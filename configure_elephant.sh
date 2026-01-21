#!/bin/bash
# Configure Elephant for iconify custom menu

RED='\033[0;31m'
NC='\033[0m'

REPO_URL="https://github.com/nino-mau/elephant-iconify.git"
ELEPHANT_CONFIG="$USER_HOME/.config/elephant"
ELEPHANT_MENUS_CONFIG="$USER_HOME/.config/elephant/menus"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Handle sudo: use actual user's home, not root's
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

if [ ! -f "$ELEPHANT_CONFIG" ]; then
  echo "${RED} Elephant config not found at $ELEPHANT_CONFIG ${NC}"
  exit 1
fi

if [ ! -f "$ELEPHANT_MENUS_CONFIG" ]; then
  mkdir -p "$ELEPHANT_CONFIG/menus"
fi

if [ ! -f "$SCRIPT_DIR/iconify.lua" ]; then
  echo "Couldn't find the necessary file locally, downloading from repo..."
  if curl -fsSL "$REPO_URL" -o "$ELEPHANT_MENUS_CONFIG/iconify.lua"; then
    echo "Successfully downloaded $DEST"
  else
    echo "${RED} Error: Could not download file. ${NC}"
  fi
else
  cp "$SCRIPT_DIR/iconify.lua" "$ELEPHANT_MENUS_CONFIG/iconify.lua"
fi

if [ -f "$ELEPHANT_MENUS_CONFIG/iconify.lua" ]; then
  echo "Successfully saved to: $TARGET_DIR/$FILE_NAME"
else
  echo "${RED} Failed to configure elephant. ${NC}"
fi

echo "Elephant configured for iconify"
