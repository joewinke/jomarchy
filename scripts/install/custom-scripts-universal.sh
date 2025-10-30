#!/bin/bash

# Custom Scripts Installation (Universal)
# Installs custom utility scripts for all Omarchy systems

set -e  # Exit on error

echo "========================================"
echo "Custom Scripts Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}→${NC} Installing custom utility scripts..."

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

# 1. Toggle Zoom Script
echo -e "${BLUE}→${NC} Installing toggle-zoom script..."
cat > ~/.local/bin/toggle-zoom << 'EOF'
#!/bin/bash
# Toggle Hyprland cursor zoom between 1x and 2x

current=$(hyprctl getoption cursor:zoom_factor | grep "float:" | awk '{print int($2)}')

if [[ "$current" == "1" ]]; then
    hyprctl keyword cursor:zoom_rigid true
    hyprctl keyword cursor:zoom_factor 2.0
else
    hyprctl keyword cursor:zoom_factor 1.0
    hyprctl keyword cursor:zoom_rigid false
fi
EOF

chmod +x ~/.local/bin/toggle-zoom
echo -e "${GREEN}✓${NC} toggle-zoom installed"

# 2. File Search Script
echo -e "${BLUE}→${NC} Installing file-search script..."

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo -e "${YELLOW}WARNING: fzf not found${NC}"
    echo "Installing fzf for file search functionality..."
    sudo pacman -S --noconfirm fzf
fi

cat > ~/.local/bin/file-search << 'EOF'
#!/bin/bash

# System-wide file search using fzf
# Searches from home directory, excludes common dirs to ignore

cd ~
selected=$(find . -type f \
  -not -path "*/\.git/*" \
  -not -path "*/\.cache/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/\.local/share/Trash/*" \
  2>/dev/null | fzf --prompt="Search files: " --preview 'head -50 {}')

if [ -n "$selected" ]; then
  # Open the file with appropriate program
  xdg-open "$selected" 2>/dev/null || \
  nvim "$selected" 2>/dev/null || \
  echo "Selected: $selected"
fi
EOF

chmod +x ~/.local/bin/file-search
echo -e "${GREEN}✓${NC} file-search installed"

# 3. Configure Hyprland keybindings
echo -e "${BLUE}→${NC} Configuring Hyprland keybindings..."

BINDINGS_FILE=~/.config/hypr/bindings.conf

# Check if bindings already exist
if grep -q "toggle-zoom" "$BINDINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} Super+Z (toggle-zoom) binding already exists"
else
    echo -e "${BLUE}→${NC} Adding Super+Z binding for toggle-zoom..."
    echo "" >> "$BINDINGS_FILE"
    echo "# Screen zoom/magnification binding (Super+Z)" >> "$BINDINGS_FILE"
    echo "bindd = SUPER, Z, Toggle Zoom, exec, ~/.local/bin/toggle-zoom" >> "$BINDINGS_FILE"
    echo -e "${GREEN}✓${NC} Super+Z binding added"
fi

if grep -q "file-search" "$BINDINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} F4 (file-search) binding already exists"
else
    echo -e "${BLUE}→${NC} Adding F4 binding for file-search..."
    echo "" >> "$BINDINGS_FILE"
    echo "# File search with F4" >> "$BINDINGS_FILE"
    echo "bindd = , F4, File Search, exec, alacritty -e ~/.local/bin/file-search" >> "$BINDINGS_FILE"
    echo "bindd = , XF86LaunchB, File Search, exec, alacritty -e ~/.local/bin/file-search" >> "$BINDINGS_FILE"
    echo -e "${GREEN}✓${NC} F4 binding added"
fi

# 4. Enable and start Hyprsunset (blue light filter)
echo -e "${BLUE}→${NC} Enabling Hyprsunset blue light filter..."

if systemctl --user is-active --quiet hyprsunset.service; then
    echo -e "${YELLOW}→${NC} Hyprsunset already running"
else
    systemctl --user start hyprsunset.service
    echo -e "${GREEN}✓${NC} Hyprsunset started"
fi

if systemctl --user is-enabled --quiet hyprsunset.service; then
    echo -e "${YELLOW}→${NC} Hyprsunset already enabled"
else
    systemctl --user enable hyprsunset.service
    echo -e "${GREEN}✓${NC} Hyprsunset enabled for auto-start"
fi

# 5. Configure Jomarchy screensaver branding
echo -e "${BLUE}→${NC} Configuring Jomarchy screensaver branding..."

# Create branding directory if it doesn't exist
mkdir -p ~/.config/omarchy/branding

# Create jomarchy.txt ASCII art
cat > ~/.config/omarchy/branding/jomarchy.txt << 'EOF'
.·:''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''':·.
: :                                                                                               : :
: :         _____   ______   __       __   ______   _______    ______   __    __  __      __      : :
: :        |     \ /      \ |  \     /  \ /      \ |       \  /      \ |  \  |  \|  \    /  \     : :
: :         \$$$$$|  $$$$$$\| $$\   /  $$|  $$$$$$\| $$$$$$$\|  $$$$$$\| $$  | $$ \$$\  /  $$     : :
: :           | $$| $$  | $$| $$$\ /  $$$| $$__| $$| $$__| $$| $$   \$$| $$__| $$  \$$\/  $$      : :
: :      __   | $$| $$  | $$| $$$$\  $$$$| $$    $$| $$    $$| $$      | $$    $$   \$$  $$       : :
: :     |  \  | $$| $$  | $$| $$\$$ $$ $$| $$$$$$$$| $$$$$$$\| $$   __ | $$$$$$$$    \$$$$        : :
: :     | $$__| $$| $$__/ $$| $$ \$$$| $$| $$  | $$| $$  | $$| $$__/  \| $$  | $$    | $$         : :
: :      \$$    $$ \$$    $$| $$  \$ | $$| $$  | $$| $$  | $$ \$$    $$| $$  | $$    | $$         : :
: :       \$$$$$$   \$$$$$$  \$$      \$$ \$$   \$$ \$$   \$$  \$$$$$$  \$$   \$$     \$$         : :
: :                                                                                               : :
'·:...............................................................................................:·'
EOF

# Copy jomarchy.txt to screensaver.txt
cp ~/.config/omarchy/branding/jomarchy.txt ~/.config/omarchy/branding/screensaver.txt
echo -e "${GREEN}✓${NC} Jomarchy screensaver branding configured"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Custom Scripts Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed scripts:"
echo "  ✓ toggle-zoom - Super+Z for 2x screen magnification"
echo "  ✓ file-search - F4 for fuzzy file finder"
echo "  ✓ Hyprsunset - Blue light filter (auto-adjusts by time)"
echo "  ✓ Jomarchy screensaver - Super+L to activate"
echo ""

echo "Hyprsunset schedule:"
echo "  6:30 AM - Normal daylight (6500K)"
echo "  7:00 PM - Sunset warmth (5000K)"
echo "  9:00 PM - Bedtime mode (3400K)"
echo ""

echo "Note: Reload Hyprland config to activate keybindings:"
echo "  Press Super+Shift+R or restart Hyprland"
echo ""
