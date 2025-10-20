#!/bin/bash

# Development Tools Installation (Local/Dev machines only)
# Installs additional dev tools for development workstations

set -e  # Exit on error

echo "========================================"
echo "Development Tools Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

echo -e "${BLUE}→${NC} Installing development tools..."
echo ""

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo -e "${RED}ERROR: yay (AUR helper) is not installed${NC}"
    echo "Please install yay first: https://github.com/Jguer/yay"
    echo ""
    echo "Quick install:"
    echo "  cd /tmp"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay"
    echo "  makepkg -si"
    exit 1
fi

# Function to install AUR package
install_aur_package() {
    local package=$1

    if pacman -Qi "$package" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $package (already installed)"
    else
        echo -e "${BLUE}→${NC} Installing $package..."
        if yay -S --noconfirm "$package"; then
            echo -e "${GREEN}✓${NC} $package installed successfully"
        else
            echo -e "${RED}✗${NC} $package failed to install (skipping)"
        fi
    fi
}

# Install Stripe CLI
echo -e "${BLUE}[1/2] Stripe CLI${NC}"
install_aur_package "stripe-cli"
echo ""

# Install Supabase CLI
echo -e "${BLUE}[2/2] Supabase CLI${NC}"
install_aur_package "supabase-bin"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Development Tools Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed tools:"
echo "  ✓ stripe-cli - Stripe API CLI tool"
echo "  ✓ supabase-bin - Supabase CLI"
echo ""

echo "Verify installations:"
echo "  stripe --version"
echo "  supabase --version"
echo ""
