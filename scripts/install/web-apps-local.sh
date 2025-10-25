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

# Development Platforms
echo -e "${BLUE}=== Development Platforms ===${NC}"
install_webapp "GitHub" "https://github.com" "github"
install_webapp "Cloudflare" "https://dash.cloudflare.com" "cloudflare"
install_webapp "Supabase" "https://supabase.com/dashboard" "supabase"
echo ""

# Development Projects
echo -e "${BLUE}=== Development Projects ===${NC}"
install_webapp "Chimaro Local" "http://localhost:3000" "localhost"
echo ""

# Backend Services
echo -e "${BLUE}=== Backend Services ===${NC}"
echo -e "${YELLOW}→${NC} Note: Update project IDs in URLs after installation"
install_webapp "Supabase Chimaro" "https://supabase.com/dashboard/project/PROJECT_ID" "supabase"
install_webapp "Supabase Flush" "https://supabase.com/dashboard/project/PROJECT_ID" "supabase"
install_webapp "Supabase Steelbridge" "https://supabase.com/dashboard/project/PROJECT_ID" "supabase"
echo ""

# Development Tools
echo -e "${BLUE}=== Development Tools ===${NC}"
install_webapp "Marduk" "https://mm.marduk.app" "marduk"
install_webapp "Dev Tracker" "https://coda.io" "coda"
install_webapp "Apify" "https://console.apify.com" "apify"
install_webapp "DaisyUI" "https://daisyui.com" "daisyui"
install_webapp "Docker" "https://localhost:9443" "docker"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Development Web Apps Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed development web apps:"
echo ""
echo "  ✓ GitHub, Cloudflare, Supabase"
echo "  ✓ Chimaro Local"
echo "  ✓ 3x Supabase projects (update IDs manually)"
echo "  ✓ Dev tools (Marduk, Dev Tracker, Apify, DaisyUI, Docker)"
echo ""
echo "Next steps:"
echo "  1. Update Supabase project IDs in .desktop files"
echo ""
echo "Icons downloaded from: https://dashboardicons.com"
echo "Access via: Super + Space (app launcher)"
echo ""
