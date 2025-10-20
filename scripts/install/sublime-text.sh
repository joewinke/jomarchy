#!/bin/bash
#
# sublime-text.sh - Install Sublime Text 4 from AUR
#
# Installs Sublime Text 4 using the AUR package

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Installing Sublime Text 4${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if Sublime Text is already installed
if command -v subl &> /dev/null; then
    echo -e "${YELLOW}  Sublime Text is already installed${NC}"
    subl --version
    echo ""
    exit 0
fi

# Install using omarchy-pkg-aur-install (Omarchy's AUR helper)
if command -v omarchy-pkg-aur-install &> /dev/null; then
    echo -e "  📦 Installing from AUR using Omarchy helper..."
    omarchy-pkg-aur-install sublime-text-4
else
    echo -e "${RED}  Error: omarchy-pkg-aur-install not found${NC}"
    echo -e "${YELLOW}  Falling back to manual AUR installation...${NC}"
    echo ""

    # Manual AUR installation
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"

    echo -e "  📥 Cloning AUR package..."
    git clone https://aur.archlinux.org/sublime-text-4.git

    cd sublime-text-4
    echo -e "  🔨 Building package..."
    makepkg -si --noconfirm

    cd ~
    rm -rf "$TMP_DIR"
fi

echo ""
echo -e "${GREEN}✓ Sublime Text 4 installed successfully!${NC}"
echo -e "  Run with: ${CYAN}subl${NC}"
echo ""
