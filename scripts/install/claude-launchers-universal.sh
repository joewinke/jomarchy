#!/bin/bash

# Claude Desktop Launchers - Universal
# Creates Claude Linux and Claude Personal desktop launchers

set -e  # Exit on error

echo "========================================"
echo "Claude Desktop Launchers (Universal)"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

APPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/applications/icons"

# Ensure directories exist
mkdir -p "$APPS_DIR"
mkdir -p "$ICONS_DIR"

# Function to create Claude launcher
create_claude_launcher() {
    local name="$1"
    local directory="$2"
    local desktop_file="$APPS_DIR/Claude-${name}.desktop"

    echo -e "${BLUE}→${NC} Creating Claude $name launcher..."

    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Name=Claude $name
Comment=Claude in /code/$directory
Exec=alacritty -T "Claude $name" --working-directory /home/$USER/code/$directory -e bash -ic "claude --dangerously-skip-permissions; exec bash"
Terminal=false
Type=Application
Icon=$ICONS_DIR/Claude.png
StartupNotify=true
StartupWMClass=Alacritty
EOF

    chmod +x "$desktop_file"
    echo -e "${GREEN}✓${NC} Claude $name launcher created"
}

# Check if Claude icon exists, if not create a generic one
if [ ! -f "$ICONS_DIR/Claude.png" ]; then
    echo -e "${YELLOW}→${NC} Claude icon not found, downloading..."

    # Try to download Claude icon
    if curl -sL "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/claude-ai.png" \
        -o "$ICONS_DIR/Claude.png" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Claude icon downloaded"
    else
        # Fallback: copy chromium icon
        if [ -f "/usr/share/pixmaps/chromium.png" ]; then
            cp "/usr/share/pixmaps/chromium.png" "$ICONS_DIR/Claude.png"
            echo -e "${YELLOW}→${NC} Using chromium icon as fallback"
        fi
    fi
fi

echo ""
echo "Creating universal Claude launchers..."
echo ""

# Create launchers
create_claude_launcher "Linux" "linux"
create_claude_launcher "Personal" "personal"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Claude Launchers Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Created launchers:"
echo ""
echo "  ✓ Claude Linux (cl) → ~/code/linux"
echo "  ✓ Claude Personal (cp) → ~/code/personal"
echo ""
echo "These launchers match your bash aliases:"
echo "  - cl: cd ~/code/linux && claude --dangerously-skip-permissions"
echo "  - cp: cd ~/code/personal && claude --dangerously-skip-permissions"
echo ""
echo "Access via: Super + Space (app launcher)"
echo ""
