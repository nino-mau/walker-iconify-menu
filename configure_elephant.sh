#!/bin/bash
# Configure Elephant for iconify custom menu

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Handle sudo: use actual user's home, not root's
if [ -n "$SUDO_USER" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

RAW_FILE_URL="https://raw.githubusercontent.com/nino-mau/elephant-iconify/main/iconify.lua"
ELEPHANT_CONFIG="$USER_HOME/.config/elephant"
ELEPHANT_MENUS_CONFIG="$ELEPHANT_CONFIG/menus"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if Elephant config directory exists
if [ ! -d "$ELEPHANT_CONFIG" ]; then
  echo -e "${RED}Error: Elephant config directory not found at $ELEPHANT_CONFIG ${NC}"
  exit 1
fi

# Create menus directory if it doesn't exist
if [ ! -d "$ELEPHANT_MENUS_CONFIG" ]; then
  mkdir -p "$ELEPHANT_MENUS_CONFIG"
fi

# Copy or download iconify.lua
if [ -f "$SCRIPT_DIR/iconify.lua" ]; then
  echo "Copying iconify.lua to Elephant menus..."
  cp "$SCRIPT_DIR/iconify.lua" "$ELEPHANT_MENUS_CONFIG/iconify.lua"
else
  echo "Local file not found, downloading from repository..."
  if curl -fsSL "$RAW_FILE_URL" -o "$ELEPHANT_MENUS_CONFIG/iconify.lua"; then
    echo -e "${GREEN}✓ Successfully downloaded iconify.lua${NC}"
  else
    echo -e "${RED}Error: Could not download file${NC}"
    exit 1
  fi
fi

# Verify installation
if [ -f "$ELEPHANT_MENUS_CONFIG/iconify.lua" ]; then
  echo -e "${GREEN}✓ Elephant configured successfully${NC}"
  echo "Menu saved to: $ELEPHANT_MENUS_CONFIG/iconify.lua"
else
  echo -e "${RED}Error: Failed to configure Elephant${NC}"
  exit 1
fi
