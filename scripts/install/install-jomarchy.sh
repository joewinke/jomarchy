#!/bin/bash

# JOMARCHY Installation Script
# Installs base system for any Omarchy installation

set -e  # Exit on error

echo "=========================================="
echo "JOMARCHY: Base System Installation"
echo "=========================================="
echo ""
echo "This will install the universal base system."
echo "See JOMARCHY.md for details."
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

echo -e "${BLUE}Installing JOMARCHY base system...${NC}"
echo ""

# Phase 1: Core System
echo -e "${BLUE}=== Phase 1: Core System ===${NC}"
echo ""

if [ -f "$SCRIPT_DIR/essential-packages.sh" ]; then
    echo -e "${GREEN}→${NC} Running essential-packages.sh..."
    bash "$SCRIPT_DIR/essential-packages.sh"
else
    echo -e "${YELLOW}⚠${NC} essential-packages.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/bash-customizations-universal.sh" ]; then
    echo -e "${GREEN}→${NC} Running bash-customizations-universal.sh..."
    bash "$SCRIPT_DIR/bash-customizations-universal.sh"
else
    echo -e "${YELLOW}⚠${NC} bash-customizations-universal.sh not found, skipping"
fi

echo ""

# Phase 2: Applications
echo -e "${BLUE}=== Phase 2: Applications ===${NC}"
echo ""

if [ -f "$SCRIPT_DIR/chrome-extensions.sh" ]; then
    echo -e "${GREEN}→${NC} Running chrome-extensions.sh..."
    bash "$SCRIPT_DIR/chrome-extensions.sh"
else
    echo -e "${YELLOW}⚠${NC} chrome-extensions.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/chezwizper.sh" ]; then
    echo -e "${GREEN}→${NC} Running chezwizper.sh..."
    bash "$SCRIPT_DIR/chezwizper.sh"
else
    echo -e "${YELLOW}⚠${NC} chezwizper.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/web-apps-universal.sh" ]; then
    echo -e "${GREEN}→${NC} Running web-apps-universal.sh..."
    bash "$SCRIPT_DIR/web-apps-universal.sh"
else
    echo -e "${YELLOW}⚠${NC} web-apps-universal.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/claude-launchers-universal.sh" ]; then
    echo -e "${GREEN}→${NC} Running claude-launchers-universal.sh..."
    bash "$SCRIPT_DIR/claude-launchers-universal.sh"
else
    echo -e "${YELLOW}⚠${NC} claude-launchers-universal.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/claude-code-mcp.sh" ]; then
    echo -e "${GREEN}→${NC} Running claude-code-mcp.sh..."
    bash "$SCRIPT_DIR/claude-code-mcp.sh"
else
    echo -e "${YELLOW}⚠${NC} claude-code-mcp.sh not found, skipping"
fi

echo ""

# Phase 3: Customizations
echo -e "${BLUE}=== Phase 3: Customizations ===${NC}"
echo ""

if [ -f "$SCRIPT_DIR/waybar-customizations-universal.sh" ]; then
    echo -e "${GREEN}→${NC} Running waybar-customizations-universal.sh..."
    bash "$SCRIPT_DIR/waybar-customizations-universal.sh"
else
    echo -e "${YELLOW}⚠${NC} waybar-customizations-universal.sh not found, skipping"
fi

if [ -f "$SCRIPT_DIR/custom-scripts-universal.sh" ]; then
    echo -e "${GREEN}→${NC} Running custom-scripts-universal.sh..."
    bash "$SCRIPT_DIR/custom-scripts-universal.sh"
else
    echo -e "${YELLOW}⚠${NC} custom-scripts-universal.sh not found, skipping"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}JOMARCHY Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo "What was installed:"
echo ""
echo "✓ Core packages (VS Code, Node.js, Firefox, claude-code, Sublime, Tailscale, etc.)"
echo "✓ ChezWizper voice transcription (Super+R)"
echo "✓ 10 universal web apps"
echo "✓ 3 Chrome extensions"
echo "✓ Intelligent multi-monitor workspace configuration (1-3 monitors)"
echo "✓ Waybar customizations (clock, ChezWizper, color-coded workspaces)"
echo "✓ Custom scripts (toggle-zoom Super+Z, file-search F4)"
echo "✓ Hyprsunset blue light filter (auto-adjusts by time)"
echo "✓ Bash customizations (cl, cp aliases + ~/code/{linux,personal})"
echo "✓ 2 Claude desktop launchers"
echo "✓ Claude Code MCP configuration (Chrome DevTools)"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart your shell: source ~/.bashrc"
echo "2. Test ChezWizper: Press Super+R"
echo "3. Review: cat ~/code/linux/JOMARCHY.md"
echo ""
echo "For development machines, run: ./install-omarchy-dev.sh"
echo ""
