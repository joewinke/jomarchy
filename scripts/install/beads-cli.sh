#!/bin/bash

# Install Beads CLI
# Dependency-aware task planning system for AI agents

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Installing Beads CLI...${NC}"
echo ""

# Check if already installed
if command -v bd &> /dev/null; then
    CURRENT_VERSION=$(bd --version 2>/dev/null | grep -oP 'v\K[0-9.]+' || echo 'unknown')
    echo -e "${YELLOW}  ⊘ Beads CLI already installed (version $CURRENT_VERSION)${NC}"
    echo "  Checking for updates..."
    echo ""

    # Try to update via installer
    curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

    NEW_VERSION=$(bd --version 2>/dev/null | grep -oP 'v\K[0-9.]+' || echo 'unknown')
    if [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
        echo -e "${GREEN}  ✓ Updated Beads from $CURRENT_VERSION to $NEW_VERSION${NC}"
    else
        echo -e "${GREEN}  ✓ Beads is up to date${NC}"
    fi
else
    echo "  → Installing Beads CLI via official installer..."
    echo ""

    # Use official installer
    curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

    echo ""
    echo -e "${GREEN}  ✓ Beads CLI installed${NC}"
fi

# Verify installation
if command -v bd &> /dev/null; then
    VERSION=$(bd --version 2>/dev/null | head -1 || echo 'unknown')
    echo ""
    echo "  Installed: $VERSION"
    echo "  Command: bd"
else
    echo -e "${YELLOW}  ⚠ Beads CLI installed but 'bd' not in PATH${NC}"
    echo "  You may need to restart your shell"
fi

echo ""
echo "  Usage:"
echo "    bd init                    # Initialize beads in current project"
echo "    bd ready                   # Show tasks ready to work"
echo "    bd create \"Task title\"     # Create new task"
echo "    bd list                    # List all tasks"
echo "    bd --help                  # Full command list"
echo ""
