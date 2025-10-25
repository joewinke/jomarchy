#!/bin/bash

# Media Packages Installation Script
# Installs creative applications: GIMP, Inkscape, OBS, Shotcut, Kdenlive, Blender, Audacity

set -e  # Exit on error

echo "========================================"
echo "Media Packages Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Track installed packages
installed_packages=()

# Function to check if package is installed
is_installed() {
    pacman -Q "$1" &> /dev/null
}

# Function to install package
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

echo "Installing media packages..."
echo ""

# Graphics
echo -e "${BLUE}=== Graphics ===${NC}"
install_package "gimp" "GIMP (image editing)"
install_package "inkscape" "Inkscape (vector graphics)"
echo ""

# Video
echo -e "${BLUE}=== Video ===${NC}"
install_package "obs-studio" "OBS Studio (screen recording/streaming)"
install_package "shotcut" "Shotcut (video editing - lightweight)"
install_package "kdenlive" "Kdenlive (video editing - advanced)"
echo ""

# 3D
echo -e "${BLUE}=== 3D Modeling ===${NC}"
install_package "blender" "Blender (3D modeling/animation)"
echo ""

# Audio
echo -e "${BLUE}=== Audio ===${NC}"
install_package "audacity" "Audacity (audio editing)"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Media Packages Installation Complete!${NC}"
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
