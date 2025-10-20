#!/bin/bash

# Omarchy Bootstrap Installer
# One-command installation for fresh Omarchy systems
#
# Usage:
#   bash <(curl -sL https://raw.githubusercontent.com/joewinke/omarchy-install/main/bootstrap-omarchy.sh)

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}${BOLD}  Omarchy Bootstrap Installer${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "This will install a complete Omarchy configuration."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

# Check for git, install if missing
echo -e "${BLUE}→${NC} Checking dependencies..."
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}→${NC} git not found, installing..."
    sudo pacman -S --noconfirm git
    echo -e "${GREEN}✓${NC} git installed"
else
    echo -e "${GREEN}✓${NC} git found"
fi

# Clone repository
REPO_URL="https://github.com/joewinke/omarchy-install.git"
REPO_DIR="$HOME/code/omarchy-install"

if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}→${NC} Repository already exists at $REPO_DIR"
    read -p "Update existing repository? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→${NC} Updating repository..."
        cd "$REPO_DIR"
        git pull origin main
        echo -e "${GREEN}✓${NC} Repository updated"
    fi
else
    echo -e "${BLUE}→${NC} Cloning repository to $REPO_DIR..."
    mkdir -p "$HOME/code"
    git clone "$REPO_URL" "$REPO_DIR"
    echo -e "${GREEN}✓${NC} Repository cloned"
fi

cd "$REPO_DIR"

# Interactive menu
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Select Installation Tier:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  [A] OMARCHY-ALL     - Base system (any machine)"
echo "      → Core packages, ChezWizper, 10 web apps, cl/cp aliases"
echo ""
echo "  [D] OMARCHY-DEV     - Development workstation (includes ALL)"
echo "      → + Dev tools, work projects, 15 work web apps"
echo ""
echo "  [B] OMARCHY-BEELINK - This specific hardware (includes ALL + DEV)"
echo "      → + 3-monitor config, printer, camera, virtual webcam"
echo ""
echo "  [Q] Quit            - Exit without installing"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

while true; do
    read -p "Select tier [A/D/B/Q]: " -n 1 -r choice
    echo ""

    case $choice in
        [Aa])
            echo ""
            echo -e "${GREEN}→${NC} Installing OMARCHY-ALL (Base System)..."
            echo ""
            bash scripts/install/install-omarchy-all.sh
            break
            ;;
        [Dd])
            echo ""
            echo -e "${GREEN}→${NC} Installing OMARCHY-DEV (Development Environment)..."
            echo ""
            bash scripts/install/install-omarchy-dev.sh
            break
            ;;
        [Bb])
            echo ""
            echo -e "${GREEN}→${NC} Installing OMARCHY-BEELINK (Hardware-Specific)..."
            echo ""
            bash scripts/install/install-omarchy-beelink.sh
            break
            ;;
        [Qq])
            echo ""
            echo -e "${YELLOW}→${NC} Installation cancelled"
            exit 0
            ;;
        *)
            echo -e "${RED}→${NC} Invalid choice. Please select A, D, B, or Q."
            ;;
    esac
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Bootstrap Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Documentation:"
echo "  • Base system: cat ~/code/linux/OMARCHY-ALL.md"
echo "  • Development: cat ~/code/linux/OMARCHY-DEV.md"
echo "  • Hardware: cat ~/code/linux/OMARCHY-BEELINK.md"
echo ""
echo "Next steps:"
echo "  1. Restart your shell: source ~/.bashrc"
echo "  2. Test ChezWizper: Press Super+R"
echo "  3. Launch apps: Super+Space"
echo ""
