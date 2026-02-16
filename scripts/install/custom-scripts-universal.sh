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
  2>/dev/null | fzf --prompt="Search files (Enter=open, Ctrl+O=folder): " \
  --bind 'ctrl-o:execute-silent(uwsm app -- nautilus "$(dirname {})")' \
  --preview 'head -50 {}')

if [ -n "$selected" ]; then
  # Open the file with appropriate program
  xdg-open "$selected" 2>/dev/null || \
  nvim "$selected" 2>/dev/null || \
  echo "Selected: $selected"
fi
EOF

chmod +x ~/.local/bin/file-search
echo -e "${GREEN}✓${NC} file-search installed"

# 3. Multi-Monitor Workspace Navigation Scripts
echo -e "${BLUE}→${NC} Installing multi-monitor workspace scripts..."

# workspace-prev: Navigate to previous workspace on current monitor
cat > ~/.local/bin/workspace-prev << 'EOF'
#!/bin/bash
# Navigate to previous workspace on current monitor (with wraparound)
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 1 ] && new_ws=10
elif [ $current_ws -le 20 ]; then
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 11 ] && new_ws=20
else
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 21 ] && new_ws=30
fi

hyprctl dispatch workspace $new_ws
EOF
chmod +x ~/.local/bin/workspace-prev

# workspace-next: Navigate to next workspace on current monitor
cat > ~/.local/bin/workspace-next << 'EOF'
#!/bin/bash
# Navigate to next workspace on current monitor (with wraparound)
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 10 ] && new_ws=1
elif [ $current_ws -le 20 ]; then
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 20 ] && new_ws=11
else
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 30 ] && new_ws=21
fi

hyprctl dispatch workspace $new_ws
EOF
chmod +x ~/.local/bin/workspace-next

# switch-monitor-workspace: Switch current monitor to workspace N (with offset)
cat > ~/.local/bin/switch-monitor-workspace << 'EOF'
#!/bin/bash
# Switch only the current monitor to workspace N (with offset)
# If on left monitor: switch to N, center: N+10, right: N+20
target=$1
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$target
elif [ $current_ws -le 20 ]; then
  new_ws=$((target + 10))
else
  new_ws=$((target + 20))
fi

hyprctl dispatch workspace $new_ws
EOF
chmod +x ~/.local/bin/switch-monitor-workspace

# move-to-monitor-workspace: Move window to workspace N on current monitor
cat > ~/.local/bin/move-to-monitor-workspace << 'EOF'
#!/bin/bash
# Move window to workspace N on current monitor (with offset)
# If on left monitor: move to N, center: N+10, right: N+20
target=$1
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$target
elif [ $current_ws -le 20 ]; then
  new_ws=$((target + 10))
else
  new_ws=$((target + 20))
fi

hyprctl dispatch movetoworkspace $new_ws
EOF
chmod +x ~/.local/bin/move-to-monitor-workspace

# move-window-prev: Move window to previous workspace on current monitor
cat > ~/.local/bin/move-window-prev << 'EOF'
#!/bin/bash
# Move window to previous workspace on current monitor (with wraparound)
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 1 ] && new_ws=10
elif [ $current_ws -le 20 ]; then
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 11 ] && new_ws=20
else
  new_ws=$((current_ws - 1))
  [ $new_ws -lt 21 ] && new_ws=30
fi

hyprctl dispatch movetoworkspace $new_ws
EOF
chmod +x ~/.local/bin/move-window-prev

# move-window-next: Move window to next workspace on current monitor
cat > ~/.local/bin/move-window-next << 'EOF'
#!/bin/bash
# Move window to next workspace on current monitor (with wraparound)
current_ws=$(hyprctl activeworkspace -j | jq -r '.id')

if [ $current_ws -le 10 ]; then
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 10 ] && new_ws=1
elif [ $current_ws -le 20 ]; then
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 20 ] && new_ws=11
else
  new_ws=$((current_ws + 1))
  [ $new_ws -gt 30 ] && new_ws=21
fi

hyprctl dispatch movetoworkspace $new_ws
EOF
chmod +x ~/.local/bin/move-window-next

echo -e "${GREEN}✓${NC} Multi-monitor workspace scripts installed"

# 4. Screen OCR Script (TRex-like text extraction)
echo -e "${BLUE}→${NC} Installing screen-ocr script..."
cat > ~/.local/bin/screen-ocr << 'SCREEN_OCR_EOF'
#!/bin/bash
# Screen OCR - Select area, extract text, copy to clipboard
# Dependencies: grim, slurp, tesseract, wl-clipboard

tmpfile=$(mktemp /tmp/screen-ocr-XXXXXX.png)
trap "rm -f '$tmpfile'" EXIT

# Capture selected area
grim -g "$(slurp)" "$tmpfile" 2>/dev/null || exit 1

# OCR and copy to clipboard
text=$(tesseract "$tmpfile" stdout 2>/dev/null)

if [[ -n "$text" ]]; then
    printf '%s' "$text" | wl-copy
    notify-send "Screen OCR" "${text:0:100}$([ ${#text} -gt 100 ] && echo '...')" -t 3000
else
    notify-send "Screen OCR" "No text detected" -t 2000
fi
SCREEN_OCR_EOF

chmod +x ~/.local/bin/screen-ocr
echo -e "${GREEN}✓${NC} screen-ocr installed"

# 5. Configure Hyprland keybindings
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

if grep -q "screen-ocr" "$BINDINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} Ctrl+Shift+Print (screen-ocr) binding already exists"
else
    echo -e "${BLUE}→${NC} Adding Ctrl+Shift+Print binding for screen-ocr..."
    echo "" >> "$BINDINGS_FILE"
    echo "# Screen OCR - select area, extract text to clipboard (Ctrl+Shift+Print)" >> "$BINDINGS_FILE"
    echo "bindd = CTRL SHIFT, Print, Screen OCR, exec, ~/.local/bin/screen-ocr" >> "$BINDINGS_FILE"
    echo -e "${GREEN}✓${NC} Ctrl+Shift+Print binding added"
fi

if grep -q "omarchy-launch-screensaver" "$BINDINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} Super+Shift+L (screensaver) binding already exists"
else
    echo -e "${BLUE}→${NC} Adding Super+Shift+L binding for screensaver..."
    echo "" >> "$BINDINGS_FILE"
    echo "# Screensaver binding (Super+Shift+L)" >> "$BINDINGS_FILE"
    echo "bindd = SUPER SHIFT, L, Screensaver, exec, ~/.local/share/omarchy/bin/omarchy-launch-screensaver" >> "$BINDINGS_FILE"
    echo -e "${GREEN}✓${NC} Super+Shift+L binding added"
fi

# Multi-monitor workspace bindings
if grep -q "workspace-prev" "$BINDINGS_FILE" 2>/dev/null; then
    echo -e "${YELLOW}→${NC} Workspace navigation bindings already exist"
else
    echo -e "${BLUE}→${NC} Adding multi-monitor workspace bindings..."
    cat >> "$BINDINGS_FILE" << 'EOF'

# Navigate workspaces on current monitor (Ctrl+Alt+Arrow)
bindd = CTRL ALT, left, Previous Workspace, exec, ~/.local/bin/workspace-prev
bindd = CTRL ALT, right, Next Workspace, exec, ~/.local/bin/workspace-next

# Move windows between monitors (Ctrl+Super+Shift+Arrow)
bindd = CTRL SUPER SHIFT, left, Move Window to Left Monitor, movewindow, mon:l
bindd = CTRL SUPER SHIFT, right, Move Window to Right Monitor, movewindow, mon:r

# Move window to prev/next workspace on current monitor (Ctrl+Shift+Arrow)
bindd = CTRL SHIFT, left, Move Window to Previous Workspace, exec, ~/.local/bin/move-window-prev
bindd = CTRL SHIFT, right, Move Window to Next Workspace, exec, ~/.local/bin/move-window-next

# Switch current monitor to workspace (Ctrl+number) - monitor-aware
bindd = CTRL, 1, Switch to Workspace 1, exec, ~/.local/bin/switch-monitor-workspace 1
bindd = CTRL, 2, Switch to Workspace 2, exec, ~/.local/bin/switch-monitor-workspace 2
bindd = CTRL, 3, Switch to Workspace 3, exec, ~/.local/bin/switch-monitor-workspace 3
bindd = CTRL, 4, Switch to Workspace 4, exec, ~/.local/bin/switch-monitor-workspace 4
bindd = CTRL, 5, Switch to Workspace 5, exec, ~/.local/bin/switch-monitor-workspace 5
bindd = CTRL, 6, Switch to Workspace 6, exec, ~/.local/bin/switch-monitor-workspace 6
bindd = CTRL, 7, Switch to Workspace 7, exec, ~/.local/bin/switch-monitor-workspace 7
bindd = CTRL, 8, Switch to Workspace 8, exec, ~/.local/bin/switch-monitor-workspace 8
bindd = CTRL, 9, Switch to Workspace 9, exec, ~/.local/bin/switch-monitor-workspace 9
bindd = CTRL, 0, Switch to Workspace 10, exec, ~/.local/bin/switch-monitor-workspace 10

# Move window to workspace on current monitor (Super+Shift+number) - enhanced Omarchy
# First unbind Omarchy defaults, then add monitor-aware versions
# Monitor-aware: left=N, center=N+10, right=N+20
unbind = SUPER SHIFT, code:10
unbind = SUPER SHIFT, code:11
unbind = SUPER SHIFT, code:12
unbind = SUPER SHIFT, code:13
unbind = SUPER SHIFT, code:14
unbind = SUPER SHIFT, code:15
unbind = SUPER SHIFT, code:16
unbind = SUPER SHIFT, code:17
unbind = SUPER SHIFT, code:18
unbind = SUPER SHIFT, code:19
bindd = SUPER SHIFT, code:10, Move to Workspace 1, exec, ~/.local/bin/move-to-monitor-workspace 1
bindd = SUPER SHIFT, code:11, Move to Workspace 2, exec, ~/.local/bin/move-to-monitor-workspace 2
bindd = SUPER SHIFT, code:12, Move to Workspace 3, exec, ~/.local/bin/move-to-monitor-workspace 3
bindd = SUPER SHIFT, code:13, Move to Workspace 4, exec, ~/.local/bin/move-to-monitor-workspace 4
bindd = SUPER SHIFT, code:14, Move to Workspace 5, exec, ~/.local/bin/move-to-monitor-workspace 5
bindd = SUPER SHIFT, code:15, Move to Workspace 6, exec, ~/.local/bin/move-to-monitor-workspace 6
bindd = SUPER SHIFT, code:16, Move to Workspace 7, exec, ~/.local/bin/move-to-monitor-workspace 7
bindd = SUPER SHIFT, code:17, Move to Workspace 8, exec, ~/.local/bin/move-to-monitor-workspace 8
bindd = SUPER SHIFT, code:18, Move to Workspace 9, exec, ~/.local/bin/move-to-monitor-workspace 9
bindd = SUPER SHIFT, code:19, Move to Workspace 10, exec, ~/.local/bin/move-to-monitor-workspace 10
EOF
    echo -e "${GREEN}✓${NC} Multi-monitor workspace bindings added"
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

# 6. Install Supabase MCP Configuration Helper
echo -e "${BLUE}→${NC} Installing supabase-mcp-config helper..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPT_DIR/configure-supabase-mcp.sh" ]; then
    # Create a symlink or wrapper in ~/.local/bin
    cat > ~/.local/bin/supabase-mcp-config << 'EOF'
#!/bin/bash
# Wrapper for Supabase MCP configuration script
JOMARCHY_SCRIPTS="$HOME/code/jomarchy/scripts/install"

if [ -f "$JOMARCHY_SCRIPTS/configure-supabase-mcp.sh" ]; then
    bash "$JOMARCHY_SCRIPTS/configure-supabase-mcp.sh" "$@"
else
    echo "ERROR: Jomarchy scripts not found"
    echo "Expected location: $JOMARCHY_SCRIPTS"
    exit 1
fi
EOF
    chmod +x ~/.local/bin/supabase-mcp-config
    echo -e "${GREEN}✓${NC} supabase-mcp-config installed"
else
    echo -e "${YELLOW}→${NC} configure-supabase-mcp.sh not found, skipping"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Custom Scripts Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Installed scripts:"
echo "  ✓ toggle-zoom - Super+Z for 2x screen magnification"
echo "  ✓ file-search - F4 for fuzzy file finder"
echo "  ✓ screen-ocr - Ctrl+Shift+Print to OCR selected area to clipboard"
echo "  ✓ Multi-monitor workspace navigation (30 workspaces across 3 monitors)"
echo "  ✓ Hyprsunset - Blue light filter (auto-adjusts by time)"
echo "  ✓ Jomarchy screensaver - Super+Shift+L to activate"
echo "  ✓ supabase-mcp-config - Interactive Supabase MCP setup"
echo ""

echo "Workspace keybindings (multi-monitor aware):"
echo "  Ctrl+1-0              - Switch current monitor to workspace"
echo "  Ctrl+Alt+Arrow        - Navigate prev/next workspace on current monitor"
echo "  Super+Shift+1-0       - Move window to workspace (enhanced Omarchy)"
echo "  Ctrl+Shift+Arrow      - Move window to prev/next workspace"
echo "  Ctrl+Super+Shift+Arrow - Move window to left/right monitor"
echo ""

echo "Hyprsunset schedule:"
echo "  6:30 AM - Normal daylight (6500K)"
echo "  7:00 PM - Sunset warmth (5000K)"
echo "  9:00 PM - Bedtime mode (3400K)"
echo ""

echo "Note: Reload Hyprland config to activate keybindings:"
echo "  Press Super+Shift+R or restart Hyprland"
echo ""
