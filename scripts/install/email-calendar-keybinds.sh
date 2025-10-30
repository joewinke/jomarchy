#!/bin/bash

# Email/Calendar/Drive Keybinds Configuration
# Configures Super+Shift+E/C/D keybinds based on user's email provider preference

set -e  # Exit on error

echo "========================================"
echo "Email/Calendar/Drive Keybinds Setup"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if gum is available
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}WARNING: gum not found${NC}"
    echo "Installing gum for interactive menus..."
    sudo pacman -S --noconfirm gum
fi

echo "Select your primary email provider to configure keybinds:"
echo ""
echo "This will set up:"
echo "  • Super+Shift+E → Email"
echo "  • Super+Shift+C → Calendar"
echo "  • Super+Shift+D → Drive (when available)"
echo ""

# Present provider options
PROVIDER=$(gum choose \
    "Proton Mail" \
    "Gmail / Google" \
    "Hey" \
    "Outlook / Microsoft" \
    "Yahoo" \
    "Skip - Don't configure email keybinds" \
    --header "Choose your email provider:")

echo ""
echo -e "${BLUE}→${NC} Selected: $PROVIDER"

# Exit if user chose to skip
if [[ "$PROVIDER" == "Skip - Don't configure email keybinds" ]]; then
    echo -e "${YELLOW}→${NC} Skipping email/calendar keybind configuration"
    echo ""
    exit 0
fi

# Configuration file
BINDINGS_FILE=~/.config/hypr/bindings.conf

# Ensure bindings file exists
if [[ ! -f "$BINDINGS_FILE" ]]; then
    echo -e "${YELLOW}WARNING: $BINDINGS_FILE not found${NC}"
    echo "Creating bindings.conf file..."
    touch "$BINDINGS_FILE"
fi

# Function to remove existing keybinds
remove_existing_keybinds() {
    echo -e "${BLUE}→${NC} Removing any existing email/calendar/drive keybinds..."

    # Remove lines containing Super+Shift+E, C, or D for Email, Calendar, or Drive
    sed -i '/bindd = SUPER SHIFT, E, Email,/d' "$BINDINGS_FILE"
    sed -i '/bindd = SUPER SHIFT, C, Calendar,/d' "$BINDINGS_FILE"
    sed -i '/bindd = SUPER SHIFT, D, Drive,/d' "$BINDINGS_FILE"

    # Also remove any comment lines about email/calendar/drive keybinds
    sed -i '/# Email\/Calendar\/Drive keybinds/d' "$BINDINGS_FILE"

    echo -e "${GREEN}✓${NC} Existing keybinds removed"
}

# Function to add keybinds
add_keybinds() {
    local provider="$1"
    local email_url="$2"
    local calendar_url="$3"
    local drive_url="$4"

    echo -e "${BLUE}→${NC} Adding keybinds for $provider..."

    # Add header comment
    echo "" >> "$BINDINGS_FILE"
    echo "# Email/Calendar/Drive keybinds ($provider)" >> "$BINDINGS_FILE"

    # Add email keybind
    echo "bindd = SUPER SHIFT, E, Email, exec, omarchy-launch-webapp \"$email_url\"" >> "$BINDINGS_FILE"

    # Add calendar keybind
    echo "bindd = SUPER SHIFT, C, Calendar, exec, omarchy-launch-webapp \"$calendar_url\"" >> "$BINDINGS_FILE"

    # Add drive keybind if available
    if [[ -n "$drive_url" ]]; then
        echo "bindd = SUPER SHIFT, D, Drive, exec, omarchy-launch-webapp \"$drive_url\"" >> "$BINDINGS_FILE"
    fi

    echo -e "${GREEN}✓${NC} Keybinds added successfully"
}

# Remove existing keybinds first (idempotent)
remove_existing_keybinds

# Configure based on provider selection
case "$PROVIDER" in
    "Proton Mail")
        add_keybinds "Proton Mail" \
            "https://mail.proton.me" \
            "https://calendar.proton.me" \
            "https://drive.proton.me"
        ;;
    "Gmail / Google")
        add_keybinds "Gmail / Google" \
            "https://mail.google.com" \
            "https://calendar.google.com" \
            "https://drive.google.com"
        ;;
    "Hey")
        add_keybinds "Hey" \
            "https://app.hey.com" \
            "https://app.hey.com/calendar/weeks/" \
            ""  # Hey doesn't have a drive
        ;;
    "Outlook / Microsoft")
        add_keybinds "Outlook / Microsoft" \
            "https://outlook.com" \
            "https://outlook.com/calendar" \
            "https://onedrive.live.com"
        ;;
    "Yahoo")
        add_keybinds "Yahoo" \
            "https://mail.yahoo.com" \
            "https://calendar.yahoo.com" \
            ""  # Yahoo doesn't have a modern drive service
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Email/Calendar Keybinds Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Configured keybinds for: $PROVIDER"
echo ""
echo "Your keybinds:"
echo "  • Super+Shift+E → Email"
echo "  • Super+Shift+C → Calendar"
if [[ "$PROVIDER" != "Hey" ]] && [[ "$PROVIDER" != "Yahoo" ]]; then
    echo "  • Super+Shift+D → Drive"
fi
echo ""
echo "Note: Reload Hyprland config to activate keybinds:"
echo "  Press Super+Shift+R or restart Hyprland"
echo ""
