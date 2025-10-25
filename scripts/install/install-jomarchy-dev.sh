#!/bin/bash

# JOMARCHY-DEV Installation Script
# Installs development environment (includes JOMARCHY base)

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
    --header "Select DEV components to install (SPACE to toggle, ENTER to confirm, all selected by default)" \
    --selected "VS Code, Node.js, npm" \
    --selected "GitHub CLI" \
    --selected "Stripe CLI" \
    --selected "Supabase CLI" \
    --selected "Development web apps (GitHub, Cloudflare, Supabase, etc)" \
    --selected "GitHub repository cloning" \
    --selected "Claude project launchers" \
    --selected "Daily Claude quote timer" \
    "VS Code, Node.js, npm" \
    "GitHub CLI" \
    "Stripe CLI" \
    "Supabase CLI" \
    "Development web apps (GitHub, Cloudflare, Supabase, etc)" \
    "GitHub repository cloning" \
    "Claude project launchers" \
    "Daily Claude quote timer")

echo ""
echo -e "${BLUE}Installing selected DEV components...${NC}"
echo ""

# Install based on selections
if echo "$SELECTED_COMPONENTS" | grep -q "VS Code, Node.js, npm"; then
    if [ -f "$SCRIPT_DIR/dev-packages.sh" ]; then
        echo -e "${GREEN}→${NC} Running dev-packages.sh..."
        bash "$SCRIPT_DIR/dev-packages.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -qE "(GitHub CLI|Stripe CLI|Supabase CLI)"; then
    if [ -f "$SCRIPT_DIR/dev-tools-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running dev-tools-local.sh..."
        bash "$SCRIPT_DIR/dev-tools-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "GitHub repository cloning"; then
    if [ -f "$SCRIPT_DIR/bash-customizations-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running bash-customizations-local.sh..."
        bash "$SCRIPT_DIR/bash-customizations-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Claude project launchers"; then
    if [ -f "$SCRIPT_DIR/claude-launchers-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-launchers-local.sh..."
        bash "$SCRIPT_DIR/claude-launchers-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Development web apps"; then
    if [ -f "$SCRIPT_DIR/web-apps-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running web-apps-local.sh..."
        bash "$SCRIPT_DIR/web-apps-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "Daily Claude quote timer"; then
    if [ -f "$SCRIPT_DIR/claude-daily-quote.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-daily-quote.sh..."
        bash "$SCRIPT_DIR/claude-daily-quote.sh"
    fi
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}JOMARCHY-DEV Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo "What was installed:"
echo ""
echo "BASE (JOMARCHY):"
echo "  ✓ Core packages, ChezWizper, universal web apps, etc."
echo ""
echo "DEV ADDITIONS:"
echo "  ✓ Dev packages (VS Code, Node.js, npm)"
echo "  ✓ Dev tools (GitHub CLI, Stripe CLI, Supabase CLI)"
echo "  ✓ GitHub repository selection (your choice)"
echo "  ✓ Auto-generated Claude aliases for selected repos"
echo "  ✓ Development web apps (GitHub, Cloudflare, Supabase, project apps)"
echo "  ✓ Daily Claude quote timer (9am EST)"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart your shell: source ~/.bashrc"
echo "2. Test your Claude aliases (based on repos selected)"
echo "3. Review: cat ~/code/jomarchy/JOMARCHY-DEV.md"
echo ""
echo "Hardware-specific configurations:"
echo "  For Beelink SER9 Pro: https://github.com/joewinke/jomarchy-beelink"
echo ""
