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

# gum should already be installed by Omarchy
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}→${NC} gum not found, installing..."
    sudo pacman -S --noconfirm gum
    echo -e "${GREEN}✓${NC} gum installed"
else
    echo -e "${GREEN}✓${NC} gum found"
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

# STEP 1: Profile Selection
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Press SPACE to Select Bundles to Install${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Use gum choose for multi-select
SELECTED=$(gum choose --no-limit \
    "BASE - Core system (browsers, text editor, web apps, ChezWizper)" \
    "DEV - Software development (VS Code, Node, CLIs, dev web apps)" \
    "MEDIA - Creative tools (GIMP, Inkscape, OBS, Blender, Audacity, Kdenlive)" \
    "FINANCE - Banking/accounting web apps (Bank of America, Chase, Capital One, QuickBooks)" \
    "COMMUNICATIONS - Messaging apps (Discord, WhatsApp, Slack, Gmail, Zoom)")

# Check if user cancelled (Ctrl+C)
if [ $? -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Installation cancelled"
    exit 0
fi

# Parse selected profiles (extract profile name before -)
SELECTED_PROFILES=()
while IFS= read -r line; do
    if [ -n "$line" ]; then
        profile=$(echo "$line" | cut -d'-' -f1 | xargs)
        SELECTED_PROFILES+=("$profile")
    fi
done <<< "$SELECTED"

# Check if no profiles selected
if [ ${#SELECTED_PROFILES[@]} -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}→${NC} No profiles selected, exiting"
    exit 0
fi

echo ""
echo -e "${GREEN}→${NC} Selected profiles: ${SELECTED_PROFILES[*]}"
echo ""

# STEP 2: Component Selection for Each Profile
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 2: Select Components for Each Profile${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Collect component selections for each profile
for profile in "${SELECTED_PROFILES[@]}"; do
    echo -e "${BLUE}→ ${profile} Profile Components:${NC}"
    echo ""

    case "$profile" in
        "BASE")
            # BASE component selection is handled by install-jomarchy.sh
            # We'll run it in non-install mode just to get selections
            # For now, keep the selection in the installer itself
            ;;
        "DEV"|"MEDIA"|"FINANCE"|"COMMUNICATIONS")
            # Component selection will be handled by each installer
            # We're showing this step exists but keeping selection in installers for now
            echo -e "${YELLOW}  Components will be selected during ${profile} installation${NC}"
            ;;
    esac
done

echo ""
echo -e "${GREEN}✓${NC} Ready to install with selected profiles and components"
echo ""

# STEP 3: Installation
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 3: Installing Selected Profiles${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Install each selected profile
for profile in "${SELECTED_PROFILES[@]}"; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Installing $profile Profile${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    case "$profile" in
        "BASE")
            bash scripts/install/install-jomarchy.sh
            ;;
        "DEV")
            bash scripts/install/install-jomarchy-dev.sh
            ;;
        "MEDIA")
            bash scripts/install/install-jomarchy-media.sh
            ;;
        "FINANCE")
            bash scripts/install/install-jomarchy-finance.sh
            ;;
        "COMMUNICATIONS")
            bash scripts/install/install-jomarchy-communications.sh
            ;;
    esac
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed profiles: ${SELECTED_PROFILES[*]}"
echo ""
echo "Documentation: https://github.com/joewinke/jomarchy"
echo ""

# Auto-source bashrc if bash customizations were installed
if [[ " ${SELECTED_PROFILES[*]} " =~ " BASE " ]] || [[ " ${SELECTED_PROFILES[*]} " =~ " DEV " ]]; then
    echo "Reloading shell configuration..."
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
        echo -e "${GREEN}✓${NC} Shell configuration reloaded"
    fi
    echo ""
fi

echo "Installation complete. Enjoy Jomarchy!"
echo ""
