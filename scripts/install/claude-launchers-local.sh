#!/bin/bash

# Claude Desktop Launchers - Work Projects
# Creates Claude Chimaro, Claude Flush, and Claude Steelbridge launchers

set -e  # Exit on error

echo "========================================"
echo "Claude Desktop Launchers (Work Projects)"
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

# Check if Claude icon exists
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
echo "Creating work project Claude launchers..."
echo ""

# Create launchers
create_claude_launcher "Chimaro" "chimaro"
create_claude_launcher "Flush" "flush"
create_claude_launcher "Steelbridge" "steelbridge"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Claude Launchers Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Created launchers:"
echo ""
echo "  ✓ Claude Chimaro (cc) → ~/code/chimaro"
echo "  ✓ Claude Flush (cf) → ~/code/flush"
echo "  ✓ Claude Steelbridge (cs) → ~/code/steelbridge"
echo ""
echo "These launchers match your bash aliases:"
echo "  - cc: cd ~/code/chimaro && claude --dangerously-skip-permissions"
echo "  - cf: cd ~/code/flush && claude --dangerously-skip-permissions"
echo "  - cs: cd ~/code/steelbridge && claude --dangerously-skip-permissions"
echo ""
echo "Access via: Super + Space (app launcher)"
echo ""
