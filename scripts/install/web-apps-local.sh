#!/bin/bash

# Development Web Apps Installation Script
# Installs development-specific web apps for development machines

set -e  # Exit on error

echo "========================================"
echo "Development Web Apps Installation"
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

echo "Installing development web apps..."
echo ""

# Development Platforms (universal - for any developer)
echo -e "${BLUE}=== Development Platforms ===${NC}"
install_webapp "GitHub" "https://github.com" "github"
install_webapp "Cloudflare" "https://dash.cloudflare.com" "cloudflare"
install_webapp "Supabase" "https://supabase.com/dashboard" "supabase"
echo ""

# Development Documentation & Resources
echo -e "${BLUE}=== Development Resources ===${NC}"
install_webapp "Tailwind CSS" "https://tailwindcss.com/docs" "tailwindcss"
install_webapp "DaisyUI" "https://daisyui.com" "daisyui"
install_webapp "Svelte" "https://svelte.dev/docs" "svelte"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Development Web Apps Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed development web apps:"
echo "  ✓ GitHub"
echo "  ✓ Cloudflare"
echo "  ✓ Supabase"
echo "  ✓ Tailwind CSS"
echo "  ✓ DaisyUI"
echo "  ✓ Svelte"
echo ""
echo "Icons downloaded from: https://dashboardicons.com"
echo "Access via: Super + Space (app launcher)"
echo ""
echo "Note: Personal project apps (Chimaro, Marduk, etc.) are available"
echo "in the jomarchy-machines repo under JOE-PERSONAL profile."
echo ""
