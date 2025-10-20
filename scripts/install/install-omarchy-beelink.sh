#!/bin/bash

# OMARCHY-BEELINK Installation Script
# Installs hardware-specific configuration (includes OMARCHY-ALL + OMARCHY-DEV)

set -e  # Exit on error

echo "=========================================="
echo "OMARCHY-BEELINK: Hardware Configuration"
echo "=========================================="
echo ""
echo "This will install base + dev + Beelink-specific config."
echo "See OMARCHY-BEELINK.md for details."
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

# First, install OMARCHY-DEV (which includes OMARCHY-ALL)
echo -e "${BLUE}Step 1: Ensuring base + dev environment is installed...${NC}"
echo ""

if [ -f "$SCRIPT_DIR/install-omarchy-dev.sh" ]; then
    read -p "Run OMARCHY-DEV installation? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPT_DIR/install-omarchy-dev.sh"
    else
        echo -e "${YELLOW}→${NC} Skipping dev installation (assuming already installed)"
    fi
else
    echo -e "${RED}ERROR: install-omarchy-dev.sh not found${NC}"
    echo "Cannot proceed without dev environment installation"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 2: Installing Beelink-specific hardware config...${NC}"
echo ""

# 30-workspace configuration + Waybar monitor colors
if [ -f "$SCRIPT_DIR/hyprland-workspace-config-local.sh" ]; then
    echo -e "${GREEN}→${NC} Running hyprland-workspace-config-local.sh..."
    bash "$SCRIPT_DIR/hyprland-workspace-config-local.sh"
else
    echo -e "${YELLOW}⚠${NC} hyprland-workspace-config-local.sh not found, skipping"
fi

# Hardware drivers (printer + camera)
if [ -f "$SCRIPT_DIR/hardware-specific.sh" ]; then
    echo -e "${GREEN}→${NC} Running hardware-specific.sh..."
    bash "$SCRIPT_DIR/hardware-specific.sh"
else
    echo -e "${YELLOW}⚠${NC} hardware-specific.sh not found, skipping"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}OMARCHY-BEELINK Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo "What was installed:"
echo ""
echo "BASE (OMARCHY-ALL):"
echo "  ✓ Core packages, ChezWizper, universal web apps, etc."
echo ""
echo "DEV (OMARCHY-DEV):"
echo "  ✓ Dev tools, work projects, work web apps, etc."
echo ""
echo "BEELINK (Hardware-Specific):"
echo "  ✓ 30-workspace configuration (3 monitors)"
echo "  ✓ Waybar monitor color coding (green/cyan/magenta)"
echo "  ✓ Brother HL2270DW printer driver"
echo "  ✓ gphoto2 camera support"
echo "  ✓ Monitor hardware config (3x 3440x1440)"
echo ""

echo "Hardware Details:"
echo "  • Left (DP-2): 3440x1440 @ 120Hz - Workspaces 1-10 (green)"
echo "  • Center (HDMI-A-1): 3440x1440 @ 100Hz - Workspaces 11-20 (cyan)"
echo "  • Right (DP-1): 3440x1440 @ 120Hz - Workspaces 21-30 (magenta)"
echo ""

echo "Next steps:"
echo ""
echo "1. Restart Hyprland to apply workspace config"
echo "2. Test printer: Brother HL2270DW should be available"
echo "3. Review: cat ~/code/linux/OMARCHY-BEELINK.md"
echo ""
echo "Monitor troubleshooting:"
echo "  If a monitor won't wake, run:"
echo "  hyprctl keyword monitor DP-2,3440x1440@120,0x0,1"
echo ""
