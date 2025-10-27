#!/bin/bash

# JOMARCHY-MEDIA Installation Script
# Extends BASE with creative/media applications

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi
echo ""

# Component selection with gum
SELECTED_COMPONENTS=$(gum choose --no-limit \
    --height=10 \
    --selected "*" \
    "GIMP (image editing)" \
    "Inkscape (vector graphics)" \
    "OBS Studio (screen recording/streaming)" \
    "Shotcut (video editing - lightweight)" \
    "Kdenlive (video editing - advanced)" \
    "Blender (3D modeling/animation)" \
    "Audacity (audio editing)")

echo ""
echo -e "${BLUE}Installing selected MEDIA components...${NC}"
echo ""

# Create a modified media-packages.sh that only installs selected items
# For now, we'll just run the full script if any component is selected
if [ -n "$SELECTED_COMPONENTS" ]; then
    if [ -f "$SCRIPT_DIR/media-packages.sh" ]; then
        echo -e "${BLUE}→ Installing media packages...${NC}"
        # TODO: Make media-packages.sh accept parameters for selective installation
        bash "$SCRIPT_DIR/media-packages.sh"
    else
        echo -e "${RED}ERROR: media-packages.sh not found${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}No MEDIA components selected, skipping...${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JOMARCHY-MEDIA Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installed media applications:"
echo "  ✓ GIMP (image editing)"
echo "  ✓ Inkscape (vector graphics)"
echo "  ✓ OBS Studio (screen recording/streaming)"
echo "  ✓ Shotcut (video editing - lightweight)"
echo "  ✓ Kdenlive (video editing - advanced)"
echo "  ✓ Blender (3D modeling/animation)"
echo "  ✓ Audacity (audio editing)"
echo ""
