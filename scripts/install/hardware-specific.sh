#!/bin/bash

# Hardware-Specific Installation (Beelink SER9 Pro)
# Installs drivers and hardware-specific configurations

set -e  # Exit on error

echo "========================================"
echo "Hardware-Specific Installation"
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

echo -e "${BLUE}→${NC} Installing hardware-specific drivers and tools..."
echo ""

# Check if yay is installed (for AUR packages)
if ! command -v yay &> /dev/null; then
    echo -e "${RED}ERROR: yay (AUR helper) is not installed${NC}"
    echo "Please install yay first: https://github.com/Jguer/yay"
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

# Install Brother printer driver
echo -e "${BLUE}[1/3] Brother Printer Driver${NC}"
install_aur_package "brother-mfc-l2750dw"
echo ""

# Install camera support (v4l2loopback for virtual webcam)
echo -e "${BLUE}[2/3] Virtual Webcam Driver${NC}"
install_aur_package "v4l2loopback-dkms"
echo ""

# Install nwg-displays (already in ALL, but confirm)
echo -e "${BLUE}[3/3] Display Configuration Tool${NC}"
if pacman -Qi nwg-displays &> /dev/null; then
    echo -e "${GREEN}✓${NC} nwg-displays (already installed)"
else
    echo -e "${BLUE}→${NC} Installing nwg-displays..."
    sudo pacman -S --noconfirm nwg-displays
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Hardware Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed hardware support:"
echo "  ✓ Brother MFC-L2750DW printer driver"
echo "  ✓ v4l2loopback virtual webcam (for OBS, etc.)"
echo "  ✓ nwg-displays (monitor configuration)"
echo ""

echo "Post-installation notes:"
echo ""
echo "1. Brother Printer:"
echo "   - Add printer via system settings"
echo "   - Driver should now be available"
echo ""
echo "2. Virtual Webcam:"
echo "   - Load module: sudo modprobe v4l2loopback"
echo "   - Auto-load: echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf"
echo ""
echo "3. Monitor Configuration:"
echo "   - Run: nwg-displays"
echo "   - Configure your 3-monitor setup"
echo ""
