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
    if git clone git@github.com:joewinke/flush.git ~/code/flush 2>/dev/null; then
        echo -e "${GREEN}✓${NC} flush repository cloned"
    else
        echo -e "${YELLOW}→${NC} Could not clone flush (check SSH key or network)"
        mkdir -p ~/code/flush
        echo -e "${YELLOW}→${NC} Created ~/code/flush directory"
    fi
fi

# Chimaro
if [ -d ~/code/chimaro ]; then
    echo -e "${YELLOW}→${NC} chimaro (already exists, skipping clone)"
else
    echo -e "${BLUE}→${NC} Cloning chimaro repository..."
    if git clone git@github.com:joewinke/chimaro.git ~/code/chimaro 2>/dev/null; then
        echo -e "${GREEN}✓${NC} chimaro repository cloned"
    else
        echo -e "${YELLOW}→${NC} Could not clone chimaro (check SSH key or network)"
        mkdir -p ~/code/chimaro
        echo -e "${YELLOW}→${NC} Created ~/code/chimaro directory"
    fi
fi

# Steelbridge
if [ -d ~/code/steelbridge ]; then
    echo -e "${YELLOW}→${NC} steelbridge (already exists, skipping clone)"
else
    echo -e "${BLUE}→${NC} Checking for steelbridge repository..."
    # Try to clone, but steelbridge may not exist yet
    if git clone git@github.com:joewinke/steelbridge.git ~/code/steelbridge 2>/dev/null; then
        echo -e "${GREEN}✓${NC} steelbridge repository cloned"
    else
        echo -e "${YELLOW}→${NC} steelbridge repo not found (may not exist yet)"
        mkdir -p ~/code/steelbridge
        echo -e "${YELLOW}→${NC} Created ~/code/steelbridge directory"
    fi
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

echo "Work project directories:"
echo "  ~/code/flush"
echo "  ~/code/chimaro"
echo "  ~/code/steelbridge"
echo ""

echo "Note: Repositories are cloned via SSH (git@github.com)"
echo "If cloning failed, ensure your SSH key is added to GitHub:"
echo "  ssh-keygen -t ed25519 -C \"your_email@example.com\""
echo "  cat ~/.ssh/id_ed25519.pub  # Add to GitHub settings"
echo ""

echo "Restart your shell to use the new aliases:"
echo "  source ~/.bashrc"
echo ""
