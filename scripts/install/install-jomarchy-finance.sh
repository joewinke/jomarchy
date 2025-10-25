#!/bin/bash

# JOMARCHY-FINANCE Installation Script
# Extends BASE with finance/banking web apps

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   JOMARCHY-FINANCE INSTALLATION       ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

echo "Select FINANCE components to install..."
echo ""

# Component selection with gum
SELECTED_COMPONENTS=$(gum choose --no-limit \
    --header "Select FINANCE components to install (SPACE to toggle, ENTER to confirm, all selected by default)" \
    --selected "Bank of America" \
    --selected "Chase Bank" \
    --selected "Capital One" \
    "Bank of America" \
    "Chase Bank" \
    "Capital One")

echo ""
echo -e "${BLUE}Installing selected FINANCE components...${NC}"
echo ""

# Install finance web apps if any selected
if [ -n "$SELECTED_COMPONENTS" ]; then
    if [ -f "$SCRIPT_DIR/web-apps-finance.sh" ]; then
        echo -e "${BLUE}→ Installing finance web apps...${NC}"
        bash "$SCRIPT_DIR/web-apps-finance.sh"
    else
        echo -e "${RED}ERROR: web-apps-finance.sh not found${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}No FINANCE components selected, skipping...${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JOMARCHY-FINANCE Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installed finance web apps:"
echo "  ✓ Bank of America"
echo "  ✓ Chase Bank"
echo "  ✓ Capital One"
echo ""
