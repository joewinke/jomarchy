#!/bin/bash

# Development Packages Installation Script
# Installs core development tools: VSCodium, Node.js, npm

set -e  # Exit on error

echo "========================================"
echo "Development Packages Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Track installed packages
installed_packages=()

# Function to check if package is installed
is_installed() {
    pacman -Q "$1" &> /dev/null
}

# Function to install pacman package
install_package() {
    local package="$1"
    local description="$2"

    echo -e "${BLUE}→${NC} Installing $description..."

    if is_installed "$package"; then
        echo -e "${YELLOW}⚠${NC} $package already installed, skipping"
    else
        if sudo pacman -S --noconfirm "$package"; then
            echo -e "${GREEN}✓${NC} $package installed"
            installed_packages+=("$package")
        else
            echo -e "${YELLOW}⚠${NC} Failed to install $package, continuing..."
        fi
    fi
}

# Function to install AUR package
install_aur_package() {
    local package="$1"
    local description="$2"

    echo -e "${BLUE}→${NC} Installing $description..."

    if is_installed "$package"; then
        echo -e "${YELLOW}⚠${NC} $package already installed, skipping"
    else
        # Check if yay is installed
        if ! command -v yay &> /dev/null; then
            echo -e "${RED}✗${NC} yay is not installed, cannot install $package from AUR"
            echo -e "${YELLOW}⚠${NC} Install yay first: https://github.com/Jguer/yay"
            return 1
        fi

        if yay -S --noconfirm "$package"; then
            echo -e "${GREEN}✓${NC} $package installed"
            installed_packages+=("$package")
        else
            echo -e "${YELLOW}⚠${NC} Failed to install $package, continuing..."
        fi
    fi
}

echo "Installing development packages..."
echo ""

# Development Tools
install_aur_package "vscodium-bin" "VSCodium (de-Microsoft-ified VS Code)"
install_package "nodejs" "Node.js (JavaScript runtime)"
install_package "npm" "npm (Node package manager)"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Development Packages Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ ${#installed_packages[@]} -gt 0 ]; then
    echo "Newly installed packages:"
    for pkg in "${installed_packages[@]}"; do
        echo "  ✓ $pkg"
    done
else
    echo "All packages were already installed."
fi

echo ""
