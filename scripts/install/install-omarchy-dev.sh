#!/bin/bash

# OMARCHY-DEV Installation Script
# Installs development environment (includes OMARCHY-ALL base)

set -e  # Exit on error

echo "=========================================="
echo "OMARCHY-DEV: Development Environment"
echo "=========================================="
echo ""
echo "This will install the base system + development additions."
echo "See OMARCHY-DEV.md for details."
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

# First, install OMARCHY-ALL base if not already done
echo -e "${BLUE}Step 1: Ensuring base system is installed...${NC}"
echo ""

if [ -f "$SCRIPT_DIR/install-omarchy-all.sh" ]; then
    read -p "Run OMARCHY-ALL installation? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPT_DIR/install-omarchy-all.sh"
    else
        echo -e "${YELLOW}→${NC} Skipping base installation (assuming already installed)"
    fi
else
    echo -e "${RED}ERROR: install-omarchy-all.sh not found${NC}"
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

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}OMARCHY-DEV Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo "What was installed:"
echo ""
echo "BASE (OMARCHY-ALL):"
echo "  ✓ Core packages, ChezWizper, universal web apps, etc."
echo ""
echo "DEV ADDITIONS:"
echo "  ✓ Dev tools (Stripe CLI, Supabase CLI, v4l2loopback-dkms)"
echo "  ✓ Work project repos (flush, chimaro, steelbridge)"
echo "  ✓ Work project aliases (cf, cc, cs)"
echo "  ✓ 3 work Claude launchers"
echo "  ✓ 15 work-specific web apps"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart your shell: source ~/.bashrc"
echo "2. Test work aliases: cf, cc, cs"
echo "3. Review: cat ~/code/linux/OMARCHY-DEV.md"
echo ""
echo "For Beelink hardware config, run: ./install-omarchy-beelink.sh"
echo ""
