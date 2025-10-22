#!/bin/bash

# Jomarchy Bootstrap Installer
# One-command installation for fresh Omarchy systems
#
# Usage:
#   bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Display Jomarchy ASCII art
cat << 'EOF'
.·:''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''':·.
: :                                                                                                                 : :
: :      oooo   .oooooo.   ooo        ooooo       .o.       ooooooooo.     .oooooo.   ooooo   ooooo oooooo   oooo   : :
: :      `888  d8P'  `Y8b  `88.       .888'      .888.      `888   `Y88.  d8P'  `Y8b  `888'   `888'  `888.   .8'    : :
: :       888 888      888  888b     d'888      .8"888.      888   .d88' 888           888     888    `888. .8'     : :
: :       888 888      888  8 Y88. .P  888     .8' `888.     888ooo88P'  888           888ooooo888     `888.8'      : :
: :       888 888      888  8  `888'   888    .88ooo8888.    888`88b.    888           888     888      `888'       : :
: :       888 `88b    d88'  8    Y     888   .8'     `888.   888  `88b.  `88b    ooo   888     888       888        : :
: :   .o. 88P  `Y8bood8P'  o8o        o888o o88o     o8888o o888o  o888o  `Y8bood8P'  o888o   o888o     o888o       : :
: :   `Y888P                                                                                                        : :
: :                                                                                                                 : :
'·:.................................................................................................................:·'
EOF

echo ""
echo -e "${CYAN}${BOLD}Joe's complete Omarchy configuration system${NC}"
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
REPO_URL="https://github.com/joewinke/jomarchy.git"
REPO_DIR="$HOME/code/jomarchy"

if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}→${NC} Repository already exists at $REPO_DIR"
    read -p "Update existing repository? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→${NC} Updating repository..."
        cd "$REPO_DIR"
        git pull origin master
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
echo -e "${BOLD}Select Installation:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  [J] JOMARCHY (Default) ⭐"
echo "      → Complete configuration for any Omarchy system"
echo "      → ChezWizper, dev tools, web apps, custom scripts"
echo ""
echo "  [D] JOMARCHY + DEV"
echo "      → Everything in JOMARCHY plus work-specific tools"
echo "      → GitHub repo selection, dev aliases, work projects"
echo ""
echo "  [Q] Quit"
echo "      → Exit without installing"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

while true; do
    read -p "Select installation [J/D/Q]: " -n 1 -r choice
    echo ""

    case $choice in
        [Jj])
            echo ""
            echo -e "${GREEN}→${NC} Installing JOMARCHY (Default Configuration)..."
            echo ""
            bash scripts/install/install-jomarchy.sh
            break
            ;;
        [Dd])
            echo ""
            echo -e "${GREEN}→${NC} Installing JOMARCHY + DEV (With Work Tools)..."
            echo ""
            bash scripts/install/install-jomarchy-dev.sh
            break
            ;;
        [Qq])
            echo ""
            echo -e "${YELLOW}→${NC} Installation cancelled"
            exit 0
            ;;
        *)
            echo -e "${RED}→${NC} Invalid choice. Please select J, D, or Q."
            ;;
    esac
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Documentation:"
echo "  • Default system: cat ~/code/jomarchy/JOMARCHY.md"
echo "  • Development: cat ~/code/jomarchy/JOMARCHY-DEV.md"
echo ""
echo "Next steps:"
echo "  1. Restart your shell: source ~/.bashrc"
echo "  2. Test ChezWizper: Press Super+R"
echo "  3. Test file search: Press F4"
echo "  4. Launch apps: Super+Space"
echo ""
echo "Hardware-specific configurations:"
echo "  For Beelink SER9 Pro, see: https://github.com/joewinke/jomarchy-beelink"
echo ""
