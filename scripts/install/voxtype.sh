#!/bin/bash

# Voxtype Voice Dictation Installation
# Installs Voxtype with GPU acceleration, large-v3-turbo model, and toggle keybinding
# Omarchy 3.3+ ships Voxtype as the official dictation tool (Super+Ctrl+X)

set -e  # Exit on error

echo "========================================"
echo "Voxtype Dictation Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Voxtype is already installed
if command -v voxtype &> /dev/null; then
    echo -e "${YELLOW}→${NC} Voxtype already installed: $(voxtype --version 2>/dev/null || echo 'unknown version')"
    echo ""
    read -p "Reinstall/reconfigure Voxtype? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→${NC} Skipping Voxtype installation"
        exit 0
    fi
    echo ""
fi

# Step 1: Install packages
echo -e "${BLUE}→${NC} Installing packages..."

# voxtype-bin: the dictation tool
# vulkan-radeon: AMD GPU Vulkan driver for GPU-accelerated transcription
# wtype: Wayland typing tool (usually already installed)
sudo pacman -S --noconfirm --needed voxtype-bin vulkan-radeon wtype

echo -e "${GREEN}✓${NC} Packages installed"
echo ""

# Step 2: Setup config and download model
echo -e "${BLUE}→${NC} Setting up Voxtype config..."

mkdir -p ~/.config/voxtype
OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
if [ -f "$OMARCHY_PATH/default/voxtype/config.toml" ]; then
    cp "$OMARCHY_PATH/default/voxtype/config.toml" ~/.config/voxtype/
    echo -e "${GREEN}✓${NC} Config copied from omarchy defaults"
else
    echo -e "${YELLOW}→${NC} No omarchy default config found, voxtype setup will create one"
fi

echo ""
echo -e "${BLUE}→${NC} Downloading large-v3-turbo model (~1.5GB)..."
echo "  This is the most accurate fast model, optimized for GPU acceleration"
echo ""

voxtype setup --download --model large-v3-turbo --no-post-install

echo -e "${GREEN}✓${NC} Model downloaded"
echo ""

# Step 3: Enable GPU acceleration
echo -e "${BLUE}→${NC} Enabling GPU acceleration (Vulkan)..."

sudo voxtype setup gpu --enable

echo -e "${GREEN}✓${NC} GPU acceleration enabled"
echo ""

# Step 4: Setup systemd service
echo -e "${BLUE}→${NC} Setting up systemd service..."

voxtype setup systemd

echo -e "${GREEN}✓${NC} Systemd service installed and started"
echo ""

# Step 5: Override keybinding to toggle mode
# Omarchy defaults use push-to-talk (hold key) which has unreliable key-release
# detection in Hyprland with modifier combos. Toggle mode is more reliable.
echo -e "${BLUE}→${NC} Configuring toggle keybinding..."

BINDINGS_FILE="$HOME/.config/hypr/bindings.conf"

if [ -f "$BINDINGS_FILE" ]; then
    # Check if override already exists
    if grep -q "voxtype record toggle" "$BINDINGS_FILE"; then
        echo -e "${YELLOW}→${NC} Toggle keybinding already configured"
    else
        # Add unbind + toggle at the top of the file
        TMPFILE=$(mktemp)
        cat > "$TMPFILE" << 'EOF'
# Override default Voxtype push-to-talk with toggle mode
unbind = SUPER CTRL, X
bindd = SUPER CTRL, X, Toggle dictation, exec, voxtype record toggle

EOF
        cat "$BINDINGS_FILE" >> "$TMPFILE"
        mv "$TMPFILE" "$BINDINGS_FILE"
        echo -e "${GREEN}✓${NC} Toggle keybinding added to bindings.conf"
    fi
else
    echo -e "${YELLOW}→${NC} No bindings.conf found, skipping keybinding override"
    echo "  You can manually add to your Hyprland config:"
    echo "  unbind = SUPER CTRL, X"
    echo "  bindd = SUPER CTRL, X, Toggle dictation, exec, voxtype record toggle"
fi

echo ""

# Step 6: Reload Hyprland
if command -v hyprctl &> /dev/null; then
    hyprctl reload &> /dev/null && echo -e "${GREEN}✓${NC} Hyprland reloaded" || true
fi

# Restart waybar to pick up voxtype status module
if command -v omarchy-restart-waybar &> /dev/null; then
    omarchy-restart-waybar &> /dev/null && echo -e "${GREEN}✓${NC} Waybar restarted" || true
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Voxtype Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "What was installed:"
echo "  ✓ Voxtype binary (voxtype-bin)"
echo "  ✓ Vulkan GPU driver (vulkan-radeon) for fast transcription"
echo "  ✓ Whisper large-v3-turbo model (~1.5GB, best speed/accuracy)"
echo "  ✓ GPU acceleration enabled (Vulkan on AMD Radeon)"
echo "  ✓ systemd service (voxtype.service, auto-starts at login)"
echo "  ✓ Toggle keybinding: Super+Ctrl+X (press to start/stop)"
echo "  ✓ Waybar status indicator (from omarchy defaults)"
echo ""

echo "Usage:"
echo "  Press Super+Ctrl+X to start recording"
echo "  Press Super+Ctrl+X again to stop and transcribe"
echo "  Text is automatically typed at cursor position"
echo ""

echo "Useful commands:"
echo "  systemctl --user status voxtype    # Check service status"
echo "  journalctl --user -u voxtype -f    # View logs"
echo "  voxtype setup model                # Change whisper model"
echo "  voxtype setup gpu                  # Check GPU status"
echo ""
