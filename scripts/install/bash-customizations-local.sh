#!/bin/bash

# Bash Customizations (Local/Dev machines only)
# Adds work project aliases and clones repositories

set -e  # Exit on error

echo "========================================"
echo "Bash Customizations (Dev)"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}→${NC} Setting up work project environment..."
echo ""

# Create ~/code directory if it doesn't exist
if [ ! -d ~/code ]; then
    mkdir -p ~/code
    echo -e "${GREEN}✓${NC} Created ~/code directory"
fi

# Clone work repositories
echo -e "${BLUE}→${NC} Cloning work project repositories..."
echo ""

# Flush
if [ -d ~/code/flush ]; then
    echo -e "${YELLOW}→${NC} flush (already exists, skipping clone)"
else
    echo -e "${BLUE}→${NC} Cloning flush repository..."
    echo -e "${YELLOW}NOTE: Update this URL with your actual repository${NC}"
    # git clone https://github.com/yourusername/flush.git ~/code/flush
    mkdir -p ~/code/flush
    echo -e "${YELLOW}→${NC} Created ~/code/flush directory (update clone URL in script)"
fi

# Chimaro
if [ -d ~/code/chimaro ]; then
    echo -e "${YELLOW}→${NC} chimaro (already exists, skipping clone)"
else
    echo -e "${BLUE}→${NC} Cloning chimaro repository..."
    echo -e "${YELLOW}NOTE: Update this URL with your actual repository${NC}"
    # git clone https://github.com/yourusername/chimaro.git ~/code/chimaro
    mkdir -p ~/code/chimaro
    echo -e "${YELLOW}→${NC} Created ~/code/chimaro directory (update clone URL in script)"
fi

# Steelbridge
if [ -d ~/code/steelbridge ]; then
    echo -e "${YELLOW}→${NC} steelbridge (already exists, skipping clone)"
else
    echo -e "${BLUE}→${NC} Cloning steelbridge repository..."
    echo -e "${YELLOW}NOTE: Update this URL with your actual repository${NC}"
    # git clone https://github.com/yourusername/steelbridge.git ~/code/steelbridge
    mkdir -p ~/code/steelbridge
    echo -e "${YELLOW}→${NC} Created ~/code/steelbridge directory (update clone URL in script)"
fi

echo ""

# Add work project aliases to .bashrc
echo -e "${BLUE}→${NC} Adding work project aliases to ~/.bashrc..."

BASHRC=~/.bashrc

# Check if aliases already exist
if grep -q "# Work Project Aliases" "$BASHRC" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} Work aliases already exist in .bashrc"
else
    cat >> "$BASHRC" << 'EOF'

# Work Project Aliases
# Flush project
alias cf='cd ~/code/flush && claude --dangerously-skip-permissions'

# Chimaro project
alias cc='cd ~/code/chimaro && claude --dangerously-skip-permissions'

# Steelbridge project
alias cs='cd ~/code/steelbridge && claude --dangerously-skip-permissions'
EOF
    echo -e "${GREEN}✓${NC} Work aliases added to .bashrc"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bash Customizations Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Added aliases:"
echo "  cf - Claude in ~/code/flush"
echo "  cc - Claude in ~/code/chimaro"
echo "  cs - Claude in ~/code/steelbridge"
echo ""

echo "Created directories:"
echo "  ~/code/flush"
echo "  ~/code/chimaro"
echo "  ~/code/steelbridge"
echo ""

echo "IMPORTANT: Update repository URLs in this script!"
echo "Edit: scripts/install/bash-customizations-local.sh"
echo "Uncomment and update the git clone commands with your actual repo URLs"
echo ""

echo "Restart your shell to use the new aliases:"
echo "  source ~/.bashrc"
echo ""
