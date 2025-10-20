#!/bin/bash

# Universal Web Apps Installation Script
# Installs 10 universal web apps for all Omarchy systems

set -e  # Exit on error

echo "========================================"
echo "Universal Web Apps Installation"
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

echo "Installing 10 universal web apps..."
echo ""

# Development
echo -e "${BLUE}=== Development ===${NC}"
install_webapp "GitHub" "https://github.com" "github"
install_webapp "Cloudflare" "https://dash.cloudflare.com" "cloudflare"
install_webapp "Supabase" "https://supabase.com/dashboard" "supabase"
echo ""

# Communication
echo -e "${BLUE}=== Communication ===${NC}"
install_webapp "Proton Mail" "https://mail.proton.me" "protonmail"
echo ""

# Search
echo -e "${BLUE}=== Search ===${NC}"
install_webapp "Kagi" "https://kagi.com" "kagi"
echo ""

# Social & Media
echo -e "${BLUE}=== Social & Media ===${NC}"
install_webapp "YouTube" "https://youtube.com" "youtube"
install_webapp "X" "https://x.com" "twitter"
install_webapp "Discord" "https://discord.com" "discord"
install_webapp "WhatsApp" "https://web.whatsapp.com" "whatsapp"
echo ""

# Productivity
echo -e "${BLUE}=== Productivity ===${NC}"
install_webapp "Zoom" "https://zoom.us" "zoom"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Universal Web Apps Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed web apps:"
echo ""
echo "  ✓ GitHub, Cloudflare, Supabase"
echo "  ✓ Proton Mail"
echo "  ✓ Kagi"
echo "  ✓ YouTube, X, Discord, WhatsApp"
echo "  ✓ Zoom"
echo ""
echo "Icons downloaded from: https://dashboardicons.com"
echo "Access via: Super + Space (app launcher)"
echo ""
