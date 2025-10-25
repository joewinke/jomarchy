#!/bin/bash

# JOMARCHY Installation Script
# Installs base system for any Omarchy installation

set -e  # Exit on error

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

# Component selection with gum
SELECTED_COMPONENTS=$(gum choose --no-limit \
    --header "Select BASE components to install (SPACE to toggle, ENTER to confirm, all selected by default)" \
    --selected "Essential packages (browsers, utilities, text editor, Claude Code)" \
    --selected "Bash customizations" \
    --selected "Chrome extensions (Copy on Select, Dark Reader, 1Password)" \
    --selected "ChezWizper (voice transcription)" \
    --selected "Universal web apps (Proton Mail, Kagi, YouTube, X, Zoom)" \
    --selected "Claude launchers (Linux, Personal)" \
    --selected "Claude Code MCP configuration" \
    --selected "Waybar customizations" \
    --selected "Custom scripts (zoom toggle, file search, screensaver)" \
    "Essential packages (browsers, utilities, text editor, Claude Code)" \
    "Bash customizations" \
    "Chrome extensions (Copy on Select, Dark Reader, 1Password)" \
    "ChezWizper (voice transcription)" \
    "Universal web apps (Proton Mail, Kagi, YouTube, X, Zoom)" \
    "Claude launchers (Linux, Personal)" \
    "Claude Code MCP configuration" \
    "Waybar customizations" \
    "Custom scripts (zoom toggle, file search, screensaver)")

echo ""
echo -e "${BLUE}Installing selected BASE components...${NC}"
echo ""

# Phase 1: Core System
echo -e "${BLUE}=== Phase 1: Core System ===${NC}"
echo ""

if echo "$SELECTED_COMPONENTS" | grep -q "Essential packages"; then
    if [ -f "$SCRIPT_DIR/essential-packages.sh" ]; then
        echo -e "${GREEN}→${NC} Running essential-packages.sh..."
        bash "$SCRIPT_DIR/essential-packages.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Bash customizations"; then
    if [ -f "$SCRIPT_DIR/bash-customizations-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running bash-customizations-universal.sh..."
        bash "$SCRIPT_DIR/bash-customizations-universal.sh"
    fi
fi

echo ""

# Phase 2: Applications
echo -e "${BLUE}=== Phase 2: Applications ===${NC}"
echo ""

if echo "$SELECTED_COMPONENTS" | grep -q "Chrome extensions"; then
    if [ -f "$SCRIPT_DIR/chrome-extensions.sh" ]; then
        echo -e "${GREEN}→${NC} Running chrome-extensions.sh..."
        bash "$SCRIPT_DIR/chrome-extensions.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "ChezWizper"; then
    if [ -f "$SCRIPT_DIR/chezwizper.sh" ]; then
        echo -e "${GREEN}→${NC} Running chezwizper.sh..."
        bash "$SCRIPT_DIR/chezwizper.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Universal web apps"; then
    if [ -f "$SCRIPT_DIR/web-apps-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running web-apps-universal.sh..."
        bash "$SCRIPT_DIR/web-apps-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Claude launchers"; then
    if [ -f "$SCRIPT_DIR/claude-launchers-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-launchers-universal.sh..."
        bash "$SCRIPT_DIR/claude-launchers-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Claude Code MCP"; then
    if [ -f "$SCRIPT_DIR/claude-code-mcp.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-code-mcp.sh..."
        bash "$SCRIPT_DIR/claude-code-mcp.sh"
    fi
fi

echo ""

# Phase 3: Customizations
echo -e "${BLUE}=== Phase 3: Customizations ===${NC}"
echo ""

if echo "$SELECTED_COMPONENTS" | grep -q "Waybar customizations"; then
    if [ -f "$SCRIPT_DIR/waybar-customizations-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running waybar-customizations-universal.sh..."
        bash "$SCRIPT_DIR/waybar-customizations-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Custom scripts"; then
    if [ -f "$SCRIPT_DIR/custom-scripts-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running custom-scripts-universal.sh..."
        bash "$SCRIPT_DIR/custom-scripts-universal.sh"
    fi
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
