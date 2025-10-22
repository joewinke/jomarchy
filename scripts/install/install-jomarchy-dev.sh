#!/bin/bash

# JOMARCHY-DEV Installation Script
# Installs development environment (includes JOMARCHY base)

set -e  # Exit on error

echo "=========================================="
echo "JOMARCHY-DEV: Development Environment"
echo "=========================================="
echo ""
echo "This will install the base system + development additions."
echo "See JOMARCHY-DEV.md for details."
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

# First, install JOMARCHY base if not already done
echo -e "${BLUE}Step 1: Ensuring base system is installed...${NC}"
echo ""

if [ -f "$SCRIPT_DIR/install-jomarchy.sh" ]; then
    read -p "Run JOMARCHY installation? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPT_DIR/install-jomarchy.sh"
    else
        echo -e "${YELLOW}→${NC} Skipping base installation (assuming already installed)"
    fi
else
    echo -e "${RED}ERROR: install-jomarchy.sh not found${NC}"
    echo "Cannot proceed without base system installation"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 2: Installing development-specific components...${NC}"
echo ""

# Development tools
if [ -f "$SCRIPT_DIR/dev-tools-local.sh" ]; then
    echo -e "${GREEN}→${NC} Running dev-tools-local.sh..."
    bash "$SCRIPT_DIR/dev-tools-local.sh"
else
    echo -e "${YELLOW}⚠${NC} dev-tools-local.sh not found, skipping"
fi

# Work project setup
if [ -f "$SCRIPT_DIR/bash-customizations-local.sh" ]; then
    echo -e "${GREEN}→${NC} Running bash-customizations-local.sh..."
    bash "$SCRIPT_DIR/bash-customizations-local.sh"
else
    echo -e "${YELLOW}⚠${NC} bash-customizations-local.sh not found, skipping"
fi

# Claude launchers for work projects
if [ -f "$SCRIPT_DIR/claude-launchers-local.sh" ]; then
    echo -e "${GREEN}→${NC} Running claude-launchers-local.sh..."
    bash "$SCRIPT_DIR/claude-launchers-local.sh"
else
    echo -e "${YELLOW}⚠${NC} claude-launchers-local.sh not found, skipping"
fi

# Work web apps
if [ -f "$SCRIPT_DIR/web-apps-local.sh" ]; then
    echo -e "${GREEN}→${NC} Running web-apps-local.sh..."
    bash "$SCRIPT_DIR/web-apps-local.sh"
else
    echo -e "${YELLOW}⚠${NC} web-apps-local.sh not found, skipping"
fi

# Daily Claude quote timer
if [ -f "$SCRIPT_DIR/claude-daily-quote.sh" ]; then
    echo -e "${GREEN}→${NC} Running claude-daily-quote.sh..."
    bash "$SCRIPT_DIR/claude-daily-quote.sh"
else
    echo -e "${YELLOW}⚠${NC} claude-daily-quote.sh not found, skipping"
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
echo "  ✓ Dev tools (GitHub CLI, Stripe CLI, Supabase CLI)"
echo "  ✓ GitHub repository selection (your choice)"
echo "  ✓ Auto-generated Claude aliases for selected repos"
echo "  ✓ Work-specific web apps"
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
