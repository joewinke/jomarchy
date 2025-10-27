#!/bin/bash

# Bash Customizations - Universal
# Sets up standard directory structure and Claude alias for all systems

set -e  # Exit on error

echo "========================================"
echo "Bash Customizations - Universal Install"
echo "========================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create standard directories
echo -e "${BLUE}Creating standard directory structure...${NC}"
mkdir -p ~/code/linux
mkdir -p ~/code/personal
echo -e "${GREEN}✓${NC} Created ~/code/linux"
echo -e "${GREEN}✓${NC} Created ~/code/personal"
echo ""

# Check if .bashrc exists
if [ ! -f ~/.bashrc ]; then
    echo -e "${YELLOW}Warning: ~/.bashrc not found, creating it${NC}"
    touch ~/.bashrc
fi

# Add Claude aliases to .bashrc
echo -e "${BLUE}Adding Claude aliases to ~/.bashrc...${NC}"

# Check if aliases already exist
CL_EXISTS=$(grep -q "^alias cl=" ~/.bashrc && echo "yes" || echo "no")
CP_EXISTS=$(grep -q "^alias cp=" ~/.bashrc && echo "yes" || echo "no")

if [ "$CL_EXISTS" = "yes" ] || [ "$CP_EXISTS" = "yes" ]; then
    echo -e "${YELLOW}→${NC} Claude aliases already exist in ~/.bashrc"
    [ "$CL_EXISTS" = "yes" ] && grep "^alias cl=" ~/.bashrc | sed 's/^/   /'
    [ "$CP_EXISTS" = "yes" ] && grep "^alias cp=" ~/.bashrc | sed 's/^/   /'
    echo ""
    read -p "   Replace with new definitions? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove old definitions
        sed -i '/^alias cl=/d' ~/.bashrc
        sed -i '/^alias cp=/d' ~/.bashrc
        echo -e "${BLUE}→${NC} Removed old definitions"
    else
        echo -e "${YELLOW}→${NC} Keeping existing definitions"
        echo ""
        echo -e "${GREEN}Setup complete!${NC}"
        exit 0
    fi
fi

# Add the aliases
echo "" >> ~/.bashrc
echo "# Claude Code - Universal projects" >> ~/.bashrc
echo "alias cl='cd ~/code/linux && claude --dangerously-skip-permissions'" >> ~/.bashrc
echo "alias cp='cd ~/code/personal && claude --dangerously-skip-permissions'" >> ~/.bashrc

echo -e "${GREEN}✓${NC} Added cl and cp aliases to ~/.bashrc"
echo ""

# Add tget alias for Tailscale (if installed)
if command -v tailscale &> /dev/null; then
    echo -e "${BLUE}Adding Tailscale file download alias...${NC}"

    if grep -q "^alias tget=" ~/.bashrc; then
        echo -e "${YELLOW}→${NC} tget alias already exists"
    else
        echo "" >> ~/.bashrc
        echo "# Tailscale file download shortcut" >> ~/.bashrc
        echo "alias tget='sudo tailscale file get -wait ~/Downloads/'" >> ~/.bashrc
        echo -e "${GREEN}✓${NC} Added tget alias to ~/.bashrc"
    fi
    echo ""
else
    echo -e "${YELLOW}Note: Tailscale not installed, skipping tget alias${NC}"
    echo ""
fi

# Install jomarchy management command
echo -e "${BLUE}Installing jomarchy management command...${NC}"

# Get the jomarchy.sh location (two directories up from scripts/install/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JOMARCHY_SCRIPT="$SCRIPT_DIR/../../jomarchy.sh"

if [ -f "$JOMARCHY_SCRIPT" ]; then
    # Create symlink in ~/.local/bin
    mkdir -p ~/.local/bin

    if [ -L ~/.local/bin/jomarchy ] || [ -f ~/.local/bin/jomarchy ]; then
        echo -e "${YELLOW}→${NC} jomarchy command already exists"
    else
        ln -sf "$JOMARCHY_SCRIPT" ~/.local/bin/jomarchy
        echo -e "${GREEN}✓${NC} Installed jomarchy command to ~/.local/bin"
    fi
else
    echo -e "${YELLOW}⚠${NC} jomarchy.sh not found, skipping"
fi
echo ""

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""

echo "What was installed:"
echo ""
echo "1. Directory: ~/code/linux"
echo "2. Directory: ~/code/personal"
echo "3. Alias: cl (cd to ~/code/linux + launch Claude with YOLO mode)"
echo "4. Alias: cp (cd to ~/code/personal + launch Claude with YOLO mode)"
if command -v tailscale &> /dev/null; then
    echo "5. Alias: tget (Tailscale file download to ~/Downloads/)"
fi
if [ -L ~/.local/bin/jomarchy ] || [ -f ~/.local/bin/jomarchy ]; then
    echo "6. Command: jomarchy (interactive management menu)"
fi
echo ""
echo "To use immediately, run: source ~/.bashrc"
echo "Or simply start a new terminal session"
echo ""
echo "Management:"
echo "  Run 'jomarchy' to access the interactive management menu"
echo ""
