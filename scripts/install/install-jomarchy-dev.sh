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
echo -e "${BLUE}Select DEV components to install:${NC}"
echo ""

SELECTED_COMPONENTS=$(gum choose --no-limit \
    --height=30 \
    --selected "*" \
    "━━━ CORE PACKAGES ━━━" \
    "  VSCodium" \
    "  Node.js & npm" \
    "━━━ CLI TOOLS ━━━" \
    "  GitHub CLI" \
    "  Stripe CLI" \
    "  Supabase CLI" \
    "━━━ WEB APPS ━━━" \
    "  GitHub" \
    "  Cloudflare" \
    "  Supabase" \
    "  Tailwind CSS" \
    "  DaisyUI" \
    "  Svelte" \
    "━━━ CUSTOMIZATIONS ━━━" \
    "  GitHub repository cloning" \
    "  Claude desktop shortcuts (per project)" \
    "  Daily Claude quote timer")

echo ""
echo -e "${BLUE}Installing selected DEV components...${NC}"
echo ""

# Install based on selections
if echo "$SELECTED_COMPONENTS" | grep -qE "(  VSCodium|  Node.js & npm)"; then
    if [ -f "$SCRIPT_DIR/dev-packages.sh" ]; then
        echo -e "${GREEN}→${NC} Running dev-packages.sh..."
        # TODO: Make dev-packages.sh accept parameters for selective installation
        # For now, it installs all packages if any are selected
        bash "$SCRIPT_DIR/dev-packages.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -qE "(  GitHub CLI|  Stripe CLI|  Supabase CLI)"; then
    if [ -f "$SCRIPT_DIR/dev-tools-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running dev-tools-local.sh..."
        bash "$SCRIPT_DIR/dev-tools-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  GitHub repository cloning"; then
    if [ -f "$SCRIPT_DIR/bash-customizations-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running bash-customizations-local.sh..."
        bash "$SCRIPT_DIR/bash-customizations-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Claude desktop shortcuts"; then
    if [ -f "$SCRIPT_DIR/claude-launchers-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running claude-launchers-local.sh..."
        bash "$SCRIPT_DIR/claude-launchers-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -qE "(  GitHub|  Cloudflare|  Supabase|  Tailwind CSS|  DaisyUI|  Svelte)"; then
    if [ -f "$SCRIPT_DIR/web-apps-local.sh" ]; then
        echo -e "${GREEN}→${NC} Running web-apps-local.sh..."
        # TODO: Make web-apps-local.sh accept parameters for selective installation
        # For now, it installs all web apps if any are selected
        bash "$SCRIPT_DIR/web-apps-local.sh"
    fi
fi

if echo "$SELECTED_COMPONENTS" | grep -q "  Daily Claude quote timer"; then
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

# Mark profile as installed
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
    source "$SCRIPT_DIR/../lib/common.sh"
    add_installed_profile "DEV"
fi

echo "What was installed:"
echo ""
echo "DEV PROFILE:"
echo "  ✓ Dev packages (VSCodium, Node.js, npm)"
echo "  ✓ Dev tools (GitHub CLI, Stripe CLI, Supabase CLI)"
echo "  ✓ GitHub repository selection (your choice)"
echo "  ✓ Project shortcuts (automatically generated from your repos)"
echo "  ✓ Development web apps (GitHub, Cloudflare, Supabase)"
echo "  ✓ Dev docs (Tailwind CSS, DaisyUI, Svelte)"
echo "  ✓ Daily Claude quote timer (9am EST)"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart your shell: source ~/.bashrc"
echo "2. Test Claude CLI: cl (opens Claude in terminal)"
echo "3. Run 'jomarchy' to access the management menu"
echo ""
echo "Want AI-assisted development tools?"
echo "  Install the AGENT-TOOLS profile:"
echo "    • Agent Mail (multi-agent coordination)"
echo "    • Beads (dependency-aware task planning)"
echo "    • 43 bash agent tools"
echo "    • Global + per-repo configuration"
echo "  Run: jomarchy  (then select 'Install Additional Profiles')"
echo ""
