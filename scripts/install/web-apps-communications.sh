#!/bin/bash

# Communications Web Apps Installation Script
# Installs messaging apps: Discord, WhatsApp, Slack, Gmail

set -e  # Exit on error

echo "========================================"
echo "Communications Web Apps Installation"
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

echo "Installing communications web apps..."
echo ""

install_webapp "Discord" "https://discord.com/app" "discord"
install_webapp "WhatsApp" "https://web.whatsapp.com" "whatsapp"
install_webapp "Slack" "https://slack.com/signin" "slack"
install_webapp "Gmail" "https://mail.google.com" "gmail"
install_webapp "Zoom" "https://zoom.us" "zoom"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Communications Web Apps Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed communications web apps (5 total):"
echo "  ✓ Discord"
echo "  ✓ WhatsApp"
echo "  ✓ Slack"
echo "  ✓ Gmail"
echo "  ✓ Zoom"
echo ""
echo "Icons downloaded from: https://dashboardicons.com"
echo "Access via: Super + Space (app launcher)"
echo ""
