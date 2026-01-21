#!/bin/bash
set -e

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check dependencies
if ! command -v curl >/dev/null 2>&1; then
  echo -e "${RED}Error: curl is required${NC}"
  exit 1
fi

echo "=== Installing & Configuring Elephant-Iconify ==="
echo "Version: ${VERSION}"
echo ""

# Configure Walker
if [[ -f "$SCRIPT_DIR/configure_walker.sh" ]]; then
  echo "Configuring Walker..."
  "$SCRIPT_DIR/configure_walker.sh"
else
  echo -e "${RED}Error: configure_walker.sh not found${NC}"
  exit 1
fi

# Configure Elephant
if [[ -f "$SCRIPT_DIR/configure_elephant.sh" ]]; then
  echo "Configuring Elephant..."
  "$SCRIPT_DIR/configure_elephant.sh"
else
  echo -e "${RED}Error: configure_elephant.sh not found${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Elephant-Iconify installed successfully!${NC}"
echo "Please restart Walker & Elephant"
