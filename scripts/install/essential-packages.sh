#!/bin/bash

# Essential Packages Installation Script
# Installs core development tools and utilities for all Omarchy systems

set -e  # Exit on error

echo "================================"
echo "Essential Packages Installation"
echo "================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

# Function to install pacman packages
install_pacman() {
    local packages=("$@")
    echo -e "${BLUE}Installing pacman packages...${NC}"

    for package in "${packages[@]}"; do
        if pacman -Qi "$package" &> /dev/null; then
            echo -e "${GREEN}✓${NC} $package (already installed)"
        else
            echo -e "${BLUE}→${NC} Installing $package..."
            if sudo pacman -S --noconfirm "$package"; then
                echo -e "${GREEN}✓${NC} $package installed successfully"
            else
                echo -e "${RED}✗${NC} $package failed to install (skipping)"
            fi
        fi
    done
}

# Function to install AUR packages
install_aur() {
    local packages=("$@")
    echo -e "${BLUE}Installing AUR packages...${NC}"

    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo -e "${RED}WARNING: yay is not installed${NC}"
        echo "Skipping AUR packages. Install yay first: https://github.com/Jguer/yay"
        return 1
    fi

    for package in "${packages[@]}"; do
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
    done
}

echo "Starting installation..."
echo ""

# Development Tools (pacman)
echo -e "${BLUE}[1/4] Development Tools${NC}"
install_pacman \
    code \
    nodejs \
    npm

echo ""

# Browsers (pacman)
echo -e "${BLUE}[2/4] Browsers${NC}"
install_pacman \
    firefox

# Note: chromium is pre-installed by Omarchy (omarchy-chromium package)
echo -e "${GREEN}✓${NC} chromium (pre-installed by Omarchy)"

echo ""

# Utilities (pacman)
echo -e "${BLUE}[3/5] Utilities${NC}"
install_pacman \
    ydotool \
    yt-dlp \
    tailscale \
    nwg-displays \
    ttf-jetbrains-mono

echo ""

# Graphics & Design (pacman)
echo -e "${BLUE}[4/5] Graphics & Design Tools${NC}"
install_pacman \
    inkscape \
    gimp

echo ""

# AUR Packages
echo -e "${BLUE}[5/5] AUR Packages${NC}"
install_aur \
    sublime-text-4 \
    claude-code

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Post-installation notes
echo "Post-installation notes:"
echo ""
echo "1. Tailscale: Enable and start the service:"
echo "   sudo systemctl enable --now tailscaled"
echo ""
echo "2. ydotool: Required for ChezWizper (voice transcription)"
echo "   Service will be configured during ChezWizper installation"
echo ""
echo "3. JetBrains Mono font: Run fonts.sh to set as default"
echo ""
echo "4. Claude Code: Run 'claude --version' to verify installation"
echo ""
echo "5. VS Code: Launch with 'code' command"
echo ""
