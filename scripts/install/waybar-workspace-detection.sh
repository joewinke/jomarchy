#!/bin/bash
#
# waybar-workspace-detection.sh - Intelligent workspace configuration
#
# Automatically configures Waybar workspaces based on number of monitors:
# - 1 monitor: workspaces 1-10
# - 2 monitors: 1-10 (left), 11-20 (right)
# - 3 monitors: 1-10 (left), 11-20 (center), 21-30 (right)
#
# Also adds color coding and updates Hyprland workspace bindings

set -e

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
HYPR_MONITORS="$HOME/.config/hypr/monitors.conf"
HYPR_LAYOUTS="$HOME/.config/hypr/workspace-layouts.conf"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Intelligent Workspace Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# Detect monitors
# ============================================================================

echo "Detecting monitors..."

# Get list of connected monitors sorted by X position (left to right)
MONITORS=($(hyprctl monitors -j | jq -r 'sort_by(.x) | .[].name'))
MONITOR_COUNT=${#MONITORS[@]}

echo "  Found $MONITOR_COUNT monitor(s): ${MONITORS[*]}"
echo ""

if [ $MONITOR_COUNT -eq 0 ]; then
    echo "ERROR: No monitors detected!"
    exit 1
fi

# ============================================================================
# Generate workspace configuration based on monitor count
# ============================================================================

echo "Generating workspace configuration..."

# Build the persistent-workspaces JSON object
WORKSPACE_CONFIG=""

case $MONITOR_COUNT in
    1)
        echo "  Single monitor: configuring workspaces 1-10"
        WORKSPACE_CONFIG="\"${MONITORS[0]}\": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"
        MAX_WORKSPACE=10
        ;;
    2)
        echo "  Dual monitor: configuring workspaces 1-10 and 11-20"
        WORKSPACE_CONFIG="\"${MONITORS[0]}\": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      \"${MONITORS[1]}\": [11, 12, 13, 14, 15, 16, 17, 18, 19, 20]"
        MAX_WORKSPACE=20
        ;;
    *)
        echo "  Triple monitor: configuring workspaces 1-10, 11-20, and 21-30"
        WORKSPACE_CONFIG="\"${MONITORS[0]}\": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      \"${MONITORS[1]}\": [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
      \"${MONITORS[2]}\": [21, 22, 23, 24, 25, 26, 27, 28, 29, 30]"
        MAX_WORKSPACE=30
        ;;
esac

echo "✓ Workspace configuration generated"
echo ""

# ============================================================================
# Update Waybar config.jsonc
# ============================================================================

echo "Updating Waybar config..."

# Backup existing config
cp "$WAYBAR_CONFIG" "${WAYBAR_CONFIG}.bak.$(date +%s)"

# Create a temporary file with the new workspace config
cat > /tmp/waybar_workspace_update.json << EOF
  "hyprland/workspaces": {
    "on-click": "activate",
    "format": "{id}",
    "all-outputs": false,
    "persistent-workspaces": {
      $WORKSPACE_CONFIG
    }
  },
EOF

# Replace the hyprland/workspaces section
# Use perl for multi-line replacement
perl -i -0pe 's/"hyprland\/workspaces":\s*\{[^}]*"persistent-workspaces":\s*\{[^}]*\}\s*\},/`cat \/tmp\/waybar_workspace_update.json`/se' "$WAYBAR_CONFIG"

echo "✓ Waybar config updated"
echo ""

# ============================================================================
# Update Hyprland workspace bindings in monitors.conf
# ============================================================================

echo "Updating Hyprland workspace-to-monitor bindings..."

# Check if monitors.conf exists
if [ ! -f "$HYPR_MONITORS" ]; then
    echo "  Creating $HYPR_MONITORS..."
    touch "$HYPR_MONITORS"
fi

# Remove old workspace bindings
sed -i '/^workspace = /d' "$HYPR_MONITORS"

# Add workspace bindings based on monitor count
echo "" >> "$HYPR_MONITORS"
echo "# Workspace-to-monitor bindings (auto-generated)" >> "$HYPR_MONITORS"

case $MONITOR_COUNT in
    1)
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$HYPR_MONITORS"
        done
        ;;
    2)
        echo "# Monitor 1: workspaces 1-10" >> "$HYPR_MONITORS"
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$HYPR_MONITORS"
        done
        echo "" >> "$HYPR_MONITORS"
        echo "# Monitor 2: workspaces 11-20" >> "$HYPR_MONITORS"
        for i in {11..20}; do
            echo "workspace = $i, monitor:${MONITORS[1]}" >> "$HYPR_MONITORS"
        done
        ;;
    *)
        echo "# Monitor 1: workspaces 1-10" >> "$HYPR_MONITORS"
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$HYPR_MONITORS"
        done
        echo "" >> "$HYPR_MONITORS"
        echo "# Monitor 2: workspaces 11-20" >> "$HYPR_MONITORS"
        for i in {11..20}; do
            echo "workspace = $i, monitor:${MONITORS[1]}" >> "$HYPR_MONITORS"
        done
        echo "" >> "$HYPR_MONITORS"
        echo "# Monitor 3: workspaces 21-30" >> "$HYPR_MONITORS"
        for i in {21..30}; do
            echo "workspace = $i, monitor:${MONITORS[2]}" >> "$HYPR_MONITORS"
        done
        ;;
esac

echo "✓ Hyprland workspace bindings updated"
echo ""

# ============================================================================
# Update workspace-layouts.conf to make workspaces persistent
# ============================================================================

echo "Updating workspace persistence..."

# Backup and create new file
if [ -f "$HYPR_LAYOUTS" ]; then
    cp "$HYPR_LAYOUTS" "${HYPR_LAYOUTS}.bak.$(date +%s)"
fi

cat > "$HYPR_LAYOUTS" << EOF
# Workspace persistence configuration (auto-generated)

EOF

for i in $(seq 1 $MAX_WORKSPACE); do
    echo "workspace = $i, persistent:true" >> "$HYPR_LAYOUTS"
done

echo "✓ Workspace persistence configured (workspaces 1-$MAX_WORKSPACE)"
echo ""

# ============================================================================
# Add CSS color coding to style.css
# ============================================================================

echo "Adding CSS color coding..."

# Remove old custom CSS if it exists
if [ -f "$WAYBAR_STYLE" ]; then
    # Backup
    cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak.$(date +%s)"

    # Remove old custom section
    sed -i '/\/\* ============================================================================/,/^EOF$/d' "$WAYBAR_STYLE"
    sed -i '/Color coding for different monitor ranges/,/^}/d' "$WAYBAR_STYLE"
fi

# Add new CSS based on monitor count
cat >> "$WAYBAR_STYLE" << 'CSSEOF'

/* ============================================================================
   CUSTOM: Workspace Color Coding (Auto-generated)
   ============================================================================ */

CSSEOF

case $MONITOR_COUNT in
    1)
        cat >> "$WAYBAR_STYLE" << 'CSSEOF'
/* Single monitor: green for all workspaces */
#workspaces button.persistent:nth-child(n+1):nth-child(-n+10) {
  color: #99d9ab;
}
CSSEOF
        ;;
    2)
        cat >> "$WAYBAR_STYLE" << 'CSSEOF'
/* Dual monitor setup */
#workspaces button.persistent:nth-child(n+1):nth-child(-n+10) {
  /* Monitor 1: workspaces 1-10 */
  color: #99d9ab; /* Green */
}

#workspaces button.persistent:nth-child(n+11):nth-child(-n+20) {
  /* Monitor 2: workspaces 11-20 */
  color: #00ffcc; /* Cyan */
}
CSSEOF
        ;;
    *)
        cat >> "$WAYBAR_STYLE" << 'CSSEOF'
/* Triple monitor setup */
#workspaces button.persistent:nth-child(n+1):nth-child(-n+10) {
  /* Monitor 1: workspaces 1-10 */
  color: #99d9ab; /* Green */
}

#workspaces button.persistent:nth-child(n+11):nth-child(-n+20) {
  /* Monitor 2: workspaces 11-20 */
  color: #00ffcc; /* Cyan */
}

#workspaces button.persistent:nth-child(n+21):nth-child(-n+30) {
  /* Monitor 3: workspaces 21-30 */
  color: #ff00ff; /* Magenta */
}
CSSEOF
        ;;
esac

# Add visual separator
cat >> "$WAYBAR_STYLE" << 'CSSEOF'

/* Visual separator between workspace ranges */
#workspaces button.persistent:nth-child(10n+1) {
  margin-left: 8px;
}
CSSEOF

echo "✓ CSS color coding added"
echo ""

# ============================================================================
# Clean up
# ============================================================================

rm -f /tmp/waybar_workspace_update.json

# ============================================================================
# Summary
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ Workspace Configuration Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration summary:"
echo "  • Monitors detected: $MONITOR_COUNT"
echo "  • Workspaces configured: 1-$MAX_WORKSPACE"

case $MONITOR_COUNT in
    1)
        echo "  • ${MONITORS[0]}: workspaces 1-10 (green)"
        ;;
    2)
        echo "  • ${MONITORS[0]}: workspaces 1-10 (green)"
        echo "  • ${MONITORS[1]}: workspaces 11-20 (cyan)"
        ;;
    *)
        echo "  • ${MONITORS[0]}: workspaces 1-10 (green)"
        echo "  • ${MONITORS[1]}: workspaces 11-20 (cyan)"
        echo "  • ${MONITORS[2]}: workspaces 21-30 (magenta)"
        ;;
esac

echo ""
echo "Files updated:"
echo "  • $WAYBAR_CONFIG"
echo "  • $WAYBAR_STYLE"
echo "  • $HYPR_MONITORS"
echo "  • $HYPR_LAYOUTS"
echo ""
echo "Backups created with .bak.<timestamp> extension"
echo ""
echo "To apply changes:"
echo "  1. Reload Waybar: pkill waybar && waybar &"
echo "  2. Reload Hyprland: hyprctl reload"
echo ""
