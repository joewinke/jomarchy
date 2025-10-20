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
# 1. Install Custom Clock Script
# ============================================================================

echo "Installing custom clock script..."

cat > "$WAYBAR_SCRIPTS/custom-clock.sh" << 'EOF'
#!/bin/bash

# Get date components
month=$(date +%m)
day=$(date +%d)
weekday=$(date +%a)
time=$(date +%H:%M)

# Format: 01-08 Wed 14:28
echo "$month-$day $weekday $time"
EOF

chmod +x "$WAYBAR_SCRIPTS/custom-clock.sh"

echo "✓ Custom clock script installed"
echo ""

# ============================================================================
# 2. Add Custom CSS to style.css
# ============================================================================

echo "Adding custom CSS to Waybar style..."

# Check if custom CSS already exists
if grep -q "Color coding for different monitor ranges" "$WAYBAR_STYLE" 2>/dev/null; then
    echo "  ⊘ Custom CSS already exists, skipping"
else
    # Backup existing style.css
    cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak.$(date +%s)"

    # Append custom CSS
    cat >> "$WAYBAR_STYLE" << 'EOF'

/* ============================================================================
   CUSTOM: Monitor Color Coding & Visual Enhancements
   ============================================================================ */

/* Visual separator between workspace ranges */
#workspaces button.persistent:nth-child(10n+1) {
  margin-left: 8px;
}

/* Color coding for different monitor ranges */
#workspaces button.persistent:nth-child(n+1):nth-child(-n+10) {
  /* Left monitor workspaces 1-10 */
  color: #99d9ab;
}

#workspaces button.persistent:nth-child(n+11):nth-child(-n+20) {
  /* Center monitor workspaces 11-20 */
  color: #00ffcc;
}

#workspaces button.persistent:nth-child(n+21):nth-child(-n+30) {
  /* Right monitor workspaces 21-30 */
  color: #ff00ff;
}

/* Window title styling - integrated with workspaces */
#window {
  color: rgba(255, 255, 255, 0.9);
  font-size: 12px;
  margin-left: 4px;
  padding-left: 4px;
  border-left: 1px solid rgba(255, 255, 255, 0.2);
}

#window.empty {
  margin: 0;
  padding: 0;
  border: none;
}
EOF

    echo "✓ Custom CSS added to style.css"
    echo "  Backup created: ${WAYBAR_STYLE}.bak.$(date +%s)"
fi

echo ""

# ============================================================================
# 3. Add Custom Clock Module to config.jsonc
# ============================================================================

echo "Configuring custom clock module..."

# Check if custom clock module already exists
if grep -q '"custom/clock"' "$WAYBAR_CONFIG" 2>/dev/null; then
    echo "  ⊘ Custom clock module already exists, skipping"
else
    echo "  ⚠ Custom clock module not found - you may need to add it manually"
    echo "    Add this to your config.jsonc modules-center:"
    echo '    "custom/clock",'
    echo ""
    echo "    And add this module definition:"
    cat << 'EOF'
    "custom/clock": {
      "exec": "~/.config/waybar/scripts/custom-clock.sh",
      "interval": 10,
      "format": "{}",
      "tooltip": false,
      "on-click-right": "~/.local/share/omarchy/bin/omarchy-cmd-tzupdate"
    }
EOF
fi

echo ""

# ============================================================================
# 4. Window Title Rewrite Rules (informational)
# ============================================================================

echo "Window title rewrite rules..."
echo "  ℹ These should already exist in Omarchy's default config"
echo "  If window titles look ugly, add rewrite rules to hyprland/window module"
echo ""

# ============================================================================
# Done
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Waybar Customizations Installed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Changes made:"
echo "  • Custom clock script installed"
echo "  • Monitor color coding added (green/cyan/magenta)"
echo "  • Visual separators between workspace groups"
echo "  • Window title styling enhanced"
echo ""
echo "Reload Waybar to see changes:"
echo "  pkill -SIGUSR2 waybar"
echo ""
