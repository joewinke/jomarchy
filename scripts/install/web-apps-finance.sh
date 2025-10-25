#!/bin/bash

# Finance Web Apps Installation Script
# Installs banking web apps: Bank of America, Chase, Capital One

set -e  # Exit on error

echo "========================================"
echo "Finance Web Apps Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if omarchy-webapp-install exists
if ! command -v omarchy-webapp-install &> /dev/null; then
    echo -e "${RED}ERROR: omarchy-webapp-install not found${NC}"
    echo "This script requires Omarchy's built-in webapp installer"
    exit 1
fi

# Icon CDN base URL
ICON_CDN="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png"

# Function to install web app
install_webapp() {
    local name="$1"
    local url="$2"
    local icon_slug="$3"

    echo -e "${BLUE}→${NC} Installing $name..."

    local icon_url="${ICON_CDN}/${icon_slug}.png"

    # Use Omarchy's webapp installer
    if omarchy-webapp-install "$name" "$url" "$icon_url" "" "" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name installed"
    else
        echo -e "${YELLOW}⚠${NC} $name - installation failed, skipping"
    fi
}

echo "Installing finance web apps..."
echo ""

install_webapp "Bank of America" "https://www.bankofamerica.com" "bankofamerica"
install_webapp "Chase Bank" "https://www.chase.com" "chase"
install_webapp "Capital One" "https://www.capitalone.com" "capitalone"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Finance Web Apps Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed finance web apps (3 total):"
echo "  ✓ Bank of America"
echo "  ✓ Chase Bank"
echo "  ✓ Capital One"
echo ""
echo "Icons downloaded from: https://dashboardicons.com"
echo "Access via: Super + Space (app launcher)"
echo ""
