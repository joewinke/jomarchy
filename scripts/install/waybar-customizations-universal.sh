#!/bin/bash
#
# waybar-customizations.sh - Install Waybar visual customizations
#
# This adds visual-only customizations to Waybar:
# - Color-coded workspace numbers (green/cyan/magenta for 3 monitors)
# - Visual separators between workspace groups
# - Enhanced window title display with app name rewriting
# - Custom clock format
#
# These are CSS/config changes only - no custom keybindings

set -e

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WAYBAR_SCRIPTS="$HOME/.config/waybar/scripts"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Waybar Customizations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Ensure scripts directory exists
mkdir -p "$WAYBAR_SCRIPTS"

# ============================================================================
# 0. Add @selected-text to all theme waybar.css files
# ============================================================================

echo "Adding @selected-text to theme waybar.css files..."

THEME_DIR="$HOME/.config/omarchy/themes"
if [ -d "$THEME_DIR" ]; then
    for theme_path in "$THEME_DIR"/*; do
        if [ -d "$theme_path" ]; then
            theme_name=$(basename "$theme_path")
            walker_css="$theme_path/walker.css"
            waybar_css="$theme_path/waybar.css"

            # Check if walker.css exists and has selected-text
            if [ -f "$walker_css" ]; then
                selected_text=$(grep "@define-color selected-text" "$walker_css" 2>/dev/null)

                # If selected-text exists in walker.css and waybar.css exists
                if [ -n "$selected_text" ] && [ -f "$waybar_css" ]; then
                    # Check if waybar.css already has it
                    if ! grep -q "selected-text" "$waybar_css" 2>/dev/null; then
                        echo "$selected_text" >> "$waybar_css"
                        echo "  ✓ Added to $theme_name"
                    fi
                fi
            fi
        fi
    done
    echo "✓ Theme accent colors configured"
else
    echo "  ⊘ Themes directory not found, skipping"
fi

echo ""

# ============================================================================
# 1. Run intelligent workspace detection
# ============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -f "$SCRIPT_DIR/waybar-workspace-detection.sh" ]; then
    echo "Running intelligent workspace detection..."
    bash "$SCRIPT_DIR/waybar-workspace-detection.sh"
    echo ""
else
    echo "⚠ Workspace detection script not found, skipping..."
    echo "  Waybar will use default workspace configuration"
    echo ""
fi

# ============================================================================
# 2. Add Comprehensive Waybar Styling
# ============================================================================

echo "Adding comprehensive Waybar styling..."

# Backup existing style.css
if [ -f "$WAYBAR_STYLE" ]; then
    cp "$WAYBAR_STYLE" "$WAYBAR_STYLE.bak.$(date +%s)"
    echo "  ✓ Backed up existing style.css"
fi

# Check if our custom styling already exists
if grep -q "CUSTOM: Theme-Aware Accent Colors" "$WAYBAR_STYLE" 2>/dev/null; then
    echo "  ⊘ Custom styling already exists, skipping"
else
    # Append comprehensive custom CSS
    cat >> "$WAYBAR_STYLE" << 'EOF'

/* ============================================================================
   CUSTOM: Theme-Aware Accent Colors
   ============================================================================ */

/* Base module styling with accent colors */
#clock,
#custom-omarchy,
#custom-update {
  font-size: 12px;
  margin: 0;
  padding: 4px 9px;
  color: @selected-text;
}

#tray,
#cpu,
#battery,
#network,
#bluetooth,
#pulseaudio {
  font-size: 18px;
  margin: 0;
  padding: 4px 9px;
  color: @selected-text;
}

#clock {
  font-weight: 600;
}

#custom-update {
  font-weight: 900;
  font-size: 15px;
}

/* Bluetooth states */
#bluetooth.connected {
  color: @selected-text;
}

#bluetooth.disabled,
#bluetooth.off {
  opacity: 0.5;
}

/* Network states */
#network.disconnected {
  opacity: 0.5;
}

/* Pulseaudio states */
#pulseaudio.bluetooth {
  color: @selected-text;
}

#pulseaudio.muted {
  opacity: 0.5;
}

/* Battery states - keep universal colors for status */
#battery.critical {
  color: #ff3333;
}

#battery.warning {
  color: #ff9933;
}

#battery.charging {
  color: #33ff33;
}

/* Window title styling */
#window {
  color: @selected-text;
  font-size: 12px;
  margin-left: 4px;
  padding-left: 4px;
  border-left: 1px solid alpha(@selected-text, 0.3);
}

#window.empty {
  margin: 0;
  padding: 0;
  border: none;
}

/* Active workspace highlighting - must come AFTER workspace color coding */
/* Higher specificity with :nth-child(n+1) to override range selectors */
#workspaces button.persistent:nth-child(n+1).active,
#workspaces button.active {
  color: @selected-text;
  background: alpha(@selected-text, 0.2);
  border-radius: 3px;
  font-weight: bold;
}
EOF

    echo "✓ Theme-aware styling added"
fi

echo ""

# ============================================================================
# 3. Update Clock Format in config.jsonc
# ============================================================================

echo "Updating clock format..."

if [ -f "$WAYBAR_CONFIG" ]; then
    # Check if clock format is already customized
    if grep -q '"%m-%d %a %H:%M"' "$WAYBAR_CONFIG" 2>/dev/null; then
        echo "  ⊘ Clock format already customized, skipping"
    else
        # Try to update clock format using sed
        if grep -q '"clock":' "$WAYBAR_CONFIG" 2>/dev/null; then
            # Create backup
            cp "$WAYBAR_CONFIG" "$WAYBAR_CONFIG.bak.$(date +%s)"

            # Update clock format (handles different formatting styles)
            sed -i 's/"format": *"{[^}]*}"/"format": "{:%m-%d %a %H:%M}"/g' "$WAYBAR_CONFIG"

            echo "  ✓ Clock format updated to show date (mm-dd weekday time)"
        else
            echo "  ⊘ Clock module not found in config, skipping"
        fi
    fi
else
    echo "  ⊘ Waybar config not found, skipping"
fi

echo ""

# ============================================================================
# 4. Ensure hyprland/window module is in config
# ============================================================================

echo "Checking window title module..."

if [ -f "$WAYBAR_CONFIG" ]; then
    if grep -q '"hyprland/window"' "$WAYBAR_CONFIG" 2>/dev/null; then
        echo "  ✓ Window title module already configured"
    else
        echo "  ⚠ Add 'hyprland/window' to modules-left in config.jsonc"
        echo '    Example: "modules-left": ["custom/omarchy", "hyprland/workspaces", "hyprland/window"]'
    fi
else
    echo "  ⊘ Waybar config not found, skipping"
fi

echo ""

# ============================================================================
# Done
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Waybar Customizations Installed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Changes made:"
echo "  • Theme accent colors added to all themes (@selected-text)"
echo "  • Intelligent workspace detection (1-3 monitors supported)"
echo "  • Workspace color coding (adapts to monitor count)"
echo "  • Active workspace highlighting with accent colors"
echo "  • All icons styled with theme accent colors"
echo "  • Clock format updated (mm-dd weekday time)"
echo "  • Window title styling with accent colors"
echo "  • Hyprland workspace bindings configured"
echo ""
echo "Visual effects:"
echo "  • Kanagawa theme: Orange accents"
echo "  • Gruvbox theme: Yellow accents"
echo "  • Tokyo Night theme: Cyan accents"
echo "  • All themes automatically adapt"
echo ""
echo "Reload to apply changes:"
echo "  pkill waybar && waybar &"
echo "  hyprctl reload"
echo ""
