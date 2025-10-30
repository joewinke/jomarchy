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
echo -e "${BLUE}Select BASE components to install:${NC}"
echo ""

SELECTED_COMPONENTS=$(gum choose --no-limit \
    --height=25 \
    --selected "*" \
    "━━━ PACKAGES (installed software) ━━━" \
    "  Firefox" \
    "  Sublime Text 4" \
    "  Claude Code" \
    "  yt-dlp (video downloader)" \
    "  Tailscale (VPN)" \
    "  nwg-displays (display manager)" \
    "  JetBrains Mono font" \
    "━━━ SYSTEM CUSTOMIZATIONS (configs, themes, keybindings) ━━━" \
    "  Bash aliases (cl, cp shortcuts + directory setup)" \
    "  Waybar customizations" \
    "  Utility keybindings (Super+Z zoom, F4 file search, Super+L screensaver)" \
    "━━━ DESKTOP APPS (shortcuts and integrations) ━━━" \
    "  Chrome extensions (Copy on Select, Dark Reader, 1Password)" \
    "  ChezWizper (voice transcription via Super+R)" \
    "  Claude desktop shortcuts (Linux, Personal)" \
    "  Claude Code browser tools (Chrome DevTools integration)" \
    "━━━ WEB APPS (browser-based applications) ━━━" \
    "  Proton Mail" \
    "  Kagi (search)" \
    "  YouTube" \
    "  X (Twitter)" \
    "  Email/Calendar/Drive keybinds (Super+Shift+E/C/D)")

echo ""
echo -e "${BLUE}Installing selected BASE components...${NC}"
echo ""

# Phase 1: Core System
echo -e "${BLUE}=== Phase 1: Core System ===${NC}"
echo ""

# Check if any essential packages were selected
if echo "$SELECTED_COMPONENTS" | grep -qE "(  Firefox|  Sublime Text|  Claude Code|  yt-dlp|  Tailscale|  nwg-displays|  JetBrains Mono|  ChezWizper)"; then
    if [ -f "$SCRIPT_DIR/essential-packages.sh" ]; then
        echo -e "${GREEN}→${NC} Running essential-packages.sh..."
        # TODO: Make essential-packages.sh accept parameters for selective installation
        # For now, it installs all packages if any are selected (ydotool auto-included for ChezWizper)
        bash "$SCRIPT_DIR/essential-packages.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Bash aliases"; then
    if [ -f "$SCRIPT_DIR/bash-customizations-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running bash-customizations-universal.sh..."
        bash "$SCRIPT_DIR/bash-customizations-universal.sh"
    fi
fi

echo ""

# Phase 2: Applications
echo -e "${BLUE}=== Phase 2: Applications ===${NC}"
echo ""

if echo "$SELECTED_COMPONENTS" | grep -q "  Chrome extensions"; then
    if [ -f "$SCRIPT_DIR/chrome-extensions.sh" ]; then
        echo -e "${GREEN}→${NC} Running chrome-extensions.sh..."
        bash "$SCRIPT_DIR/chrome-extensions.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  ChezWizper"; then
    if [ -f "$SCRIPT_DIR/chezwizper.sh" ]; then
        echo -e "${GREEN}→${NC} Running chezwizper.sh..."
        bash "$SCRIPT_DIR/chezwizper.sh"
    fi
fi

# Check if any universal web apps were selected
if echo "$SELECTED_COMPONENTS" | grep -qE "(  Proton Mail|  Kagi|  YouTube|  X \(Twitter\))"; then
    if [ -f "$SCRIPT_DIR/web-apps-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running web-apps-universal.sh..."
        # TODO: Make web-apps-universal.sh accept parameters for selective installation
        # For now, it installs all web apps if any are selected
        bash "$SCRIPT_DIR/web-apps-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Claude desktop shortcuts"; then
    if [ -f "$SCRIPT_DIR/claude-launchers-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-launchers-universal.sh..."
        bash "$SCRIPT_DIR/claude-launchers-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Claude Code browser tools"; then
    if [ -f "$SCRIPT_DIR/claude-code-mcp.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-code-mcp.sh..."
        bash "$SCRIPT_DIR/claude-code-mcp.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Email/Calendar/Drive keybinds"; then
    if [ -f "$SCRIPT_DIR/email-calendar-keybinds.sh" ]; then
        echo -e "${GREEN}→${NC} Running email-calendar-keybinds.sh..."
        bash "$SCRIPT_DIR/email-calendar-keybinds.sh"
    fi
fi

echo ""

# Phase 3: Customizations
echo -e "${BLUE}=== Phase 3: Customizations ===${NC}"
echo ""

if echo "$SELECTED_COMPONENTS" | grep -q "  Waybar customizations"; then
    if [ -f "$SCRIPT_DIR/waybar-customizations-universal.sh" ]; then
        echo -e "${GREEN}→${NC} Running waybar-customizations-universal.sh..."
        bash "$SCRIPT_DIR/waybar-customizations-universal.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Utility keybindings"; then
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

# Mark profile as installed
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
    source "$SCRIPT_DIR/../lib/common.sh"
    add_installed_profile "BASE"
fi


echo "What was installed:"
echo ""
echo "✓ Core packages (Firefox, claude-code, Sublime, Tailscale, ChezWizper, etc.)"
echo "✓ ChezWizper voice transcription (Super+R)"
echo "✓ 10 universal web apps"
echo "✓ 3 Chrome extensions"
echo "✓ Email/Calendar/Drive keybinds (Super+Shift+E/C/D - if configured)"
echo "✓ Intelligent multi-monitor workspace configuration (1-3 monitors)"
echo "✓ Waybar customizations (clock, ChezWizper, color-coded workspaces)"
echo "✓ Custom scripts (toggle-zoom Super+Z, file-search F4)"
echo "✓ Hyprsunset blue light filter (auto-adjusts by time)"
echo "✓ Bash customizations (cl, cp aliases + ~/code/{linux,personal})"
echo "✓ Claude desktop shortcuts (Linux, Personal)"
echo "✓ Claude Code MCP configuration (Chrome DevTools)"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart your shell: source ~/.bashrc"
echo "2. Test ChezWizper: Press Super+R"
echo "3. Review: cat ~/code/jomarchy/JOMARCHY.md"
echo ""
echo "For development tools, run: jomarchy --install (select DEV profile)"
echo ""
