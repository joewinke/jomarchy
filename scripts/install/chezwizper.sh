#!/bin/bash

# ChezWizper Voice Transcription Installation
# Installs ChezWizper with Waybar integration for voice-to-text via Super+R

set -e  # Exit on error

echo "========================================"
echo "ChezWizper Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if ChezWizper is already installed
if [ -f /usr/local/bin/chezwizper ]; then
    echo -e "${YELLOW}→${NC} ChezWizper already installed at /usr/local/bin/chezwizper"
    echo ""
    read -p "Reinstall/update ChezWizper? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→${NC} Skipping ChezWizper installation"
        exit 0
    fi
    echo ""
fi

# Check for required dependencies
echo -e "${BLUE}→${NC} Checking dependencies..."

if ! command -v git &> /dev/null; then
    echo -e "${RED}ERROR: git is not installed${NC}"
    echo "Please run: sudo pacman -S git"
    exit 1
fi

if ! command -v make &> /dev/null; then
    echo -e "${RED}ERROR: make is not installed${NC}"
    echo "Please run: sudo pacman -S base-devel"
    exit 1
fi

if ! command -v ydotool &> /dev/null; then
    echo -e "${YELLOW}WARNING: ydotool not found${NC}"
    echo "ydotool should be installed by essential-packages.sh"
    echo "ChezWizper requires ydotool for text injection"
    echo ""
fi

echo -e "${GREEN}✓${NC} Dependencies check complete"
echo ""

# Clone ChezWizper repository to /tmp
REPO_URL="https://github.com/joewinke/ChezWizper.git"
BRANCH="add-waybar-integration"
CLONE_DIR="/tmp/ChezWizper-install-$$"

echo -e "${BLUE}→${NC} Cloning ChezWizper repository..."
echo "  Repository: $REPO_URL"
echo "  Branch: $BRANCH"
echo ""

if ! git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$CLONE_DIR" 2>&1; then
    echo -e "${RED}ERROR: Failed to clone ChezWizper repository${NC}"
    echo "Please check your internet connection and try again"
    exit 1
fi

echo -e "${GREEN}✓${NC} Repository cloned successfully"
echo ""

# Run make install
echo -e "${BLUE}→${NC} Building and installing ChezWizper..."
echo "  This will install:"
echo "    • Binary: /usr/local/bin/chezwizper"
echo "    • systemd services: chezwizper.service, chezwizper-waybar.service"
echo "    • Waybar integration scripts"
echo "    • Hyprland keybinding: Super+R"
echo ""

cd "$CLONE_DIR"

if ! make install 2>&1; then
    echo -e "${RED}ERROR: ChezWizper installation failed${NC}"
    echo "Check the error messages above for details"
    cd -
    rm -rf "$CLONE_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} ChezWizper installed successfully"
echo ""

# Clean up
cd -
rm -rf "$CLONE_DIR"
echo -e "${GREEN}✓${NC} Cleaned up temporary files"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ChezWizper Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "What was installed:"
echo "  ✓ ChezWizper binary at /usr/local/bin/chezwizper"
echo "  ✓ systemd services (chezwizper.service, chezwizper-waybar.service)"
echo "  ✓ Waybar integration (6 scripts + CSS animations)"
echo "  ✓ Hyprland keybinding: Super+R"
echo ""

echo "Next steps:"
echo ""
echo "1. Start ChezWizper services:"
echo "   systemctl --user start chezwizper.service"
echo "   systemctl --user start chezwizper-waybar.service"
echo ""
echo "2. Enable auto-start on login:"
echo "   systemctl --user enable chezwizper.service"
echo "   systemctl --user enable chezwizper-waybar.service"
echo ""
echo "3. Reload Hyprland config to activate Super+R keybinding:"
echo "   Press Super+Shift+R or restart Hyprland"
echo ""
echo "4. Test voice transcription:"
echo "   Press Super+R to start recording"
echo "   Speak your text"
echo "   Press Super+R again to stop and transcribe"
echo ""

echo "Troubleshooting:"
echo "  • Check service status: systemctl --user status chezwizper.service"
echo "  • View logs: journalctl --user -u chezwizper.service -f"
echo "  • Configuration: ~/.config/chezwizper/config.toml"
echo ""
