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

# Create the expected workspace config
# NOTE: We do NOT use persistent-workspaces because it causes a bug where
# all workspaces show on every monitor. Instead, we rely on Hyprland's
# workspace-to-monitor bindings and let waybar only show active workspaces.
cat > /tmp/waybar_workspace_update.json << EOF
  "hyprland/workspaces": {
    "on-click": "activate",
    "format": "{id}",
    "all-outputs": false,
    "sort-by-number": true
  },
EOF

# Check if current config matches what we'd generate
# Extract the hyprland/workspaces section including nested braces
CURRENT_WORKSPACE_SECTION=$(perl -0777 -ne 'print $& if /"hyprland\/workspaces":\s*\{(?:[^{}]|\{[^}]*\})*\},/s' "$WAYBAR_CONFIG" 2>/dev/null || echo "")
EXPECTED_WORKSPACE_SECTION=$(cat /tmp/waybar_workspace_update.json)

# Normalize whitespace for comparison
CURRENT_NORMALIZED=$(echo "$CURRENT_WORKSPACE_SECTION" | tr -d ' \n\t')
EXPECTED_NORMALIZED=$(echo "$EXPECTED_WORKSPACE_SECTION" | tr -d ' \n\t')

if [ "$CURRENT_NORMALIZED" = "$EXPECTED_NORMALIZED" ]; then
    echo "  ⊘ Workspace config already correct, no changes needed"
else
    # Backup before making changes
    cp "$WAYBAR_CONFIG" "${WAYBAR_CONFIG}.bak.$(date +%s)"
    echo "  ✓ Backed up existing config"

    # Replace the hyprland/workspaces section
    perl -i -0777 -pe 's/"hyprland\/workspaces":\s*\{(?:[^{}]|\{[^}]*\})*\},/`cat \/tmp\/waybar_workspace_update.json`/se' "$WAYBAR_CONFIG"

    echo "  ✓ Waybar config updated"
fi

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

# Generate expected workspace bindings
EXPECTED_BINDINGS=$(mktemp)
echo "" >> "$EXPECTED_BINDINGS"
echo "# Workspace-to-monitor bindings (auto-generated)" >> "$EXPECTED_BINDINGS"

case $MONITOR_COUNT in
    1)
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$EXPECTED_BINDINGS"
        done
        ;;
    2)
        echo "# Monitor 1: workspaces 1-10" >> "$EXPECTED_BINDINGS"
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$EXPECTED_BINDINGS"
        done
        echo "" >> "$EXPECTED_BINDINGS"
        echo "# Monitor 2: workspaces 11-20" >> "$EXPECTED_BINDINGS"
        for i in {11..20}; do
            echo "workspace = $i, monitor:${MONITORS[1]}" >> "$EXPECTED_BINDINGS"
        done
        ;;
    *)
        echo "# Monitor 1: workspaces 1-10" >> "$EXPECTED_BINDINGS"
        for i in {1..10}; do
            echo "workspace = $i, monitor:${MONITORS[0]}" >> "$EXPECTED_BINDINGS"
        done
        echo "" >> "$EXPECTED_BINDINGS"
        echo "# Monitor 2: workspaces 11-20" >> "$EXPECTED_BINDINGS"
        for i in {11..20}; do
            echo "workspace = $i, monitor:${MONITORS[1]}" >> "$EXPECTED_BINDINGS"
        done
        echo "" >> "$EXPECTED_BINDINGS"
        echo "# Monitor 3: workspaces 21-30" >> "$EXPECTED_BINDINGS"
        for i in {21..30}; do
            echo "workspace = $i, monitor:${MONITORS[2]}" >> "$EXPECTED_BINDINGS"
        done
        ;;
esac

# Extract current workspace bindings
CURRENT_BINDINGS=$(grep -E '^(workspace = |# (Monitor|Workspace-to-monitor))' "$HYPR_MONITORS" 2>/dev/null || echo "")

# Compare current and expected bindings
if [ "$(echo "$CURRENT_BINDINGS" | tr -d ' \n\t')" = "$(cat "$EXPECTED_BINDINGS" | tr -d ' \n\t')" ]; then
    echo "  ⊘ Workspace bindings already correct, no changes needed"
else
    # Backup before making changes
    cp "$HYPR_MONITORS" "${HYPR_MONITORS}.bak.$(date +%s)"
    echo "  ✓ Backed up existing monitors.conf"

    # Remove old workspace bindings
    sed -i '/^workspace = /d' "$HYPR_MONITORS"
    sed -i '/# Monitor [0-9]: workspaces/d' "$HYPR_MONITORS"
    sed -i '/# Workspace-to-monitor bindings/d' "$HYPR_MONITORS"

    # Add new bindings
    cat "$EXPECTED_BINDINGS" >> "$HYPR_MONITORS"

    echo "  ✓ Hyprland workspace bindings updated"
fi

rm -f "$EXPECTED_BINDINGS"
echo ""

# ============================================================================
# Update workspace-layouts.conf to make workspaces persistent
# ============================================================================

echo "Updating workspace persistence..."

# Generate expected content
EXPECTED_LAYOUTS=$(mktemp)
cat > "$EXPECTED_LAYOUTS" << EOF
# Workspace persistence configuration (auto-generated)

EOF

for i in $(seq 1 $MAX_WORKSPACE); do
    echo "workspace = $i, persistent:true" >> "$EXPECTED_LAYOUTS"
done

# Check if current config matches expected
if [ -f "$HYPR_LAYOUTS" ]; then
    if diff -q "$HYPR_LAYOUTS" "$EXPECTED_LAYOUTS" > /dev/null 2>&1; then
        echo "  ⊘ Workspace persistence already correct, no changes needed"
    else
        # Backup before making changes
        cp "$HYPR_LAYOUTS" "${HYPR_LAYOUTS}.bak.$(date +%s)"
        echo "  ✓ Backed up existing workspace-layouts.conf"

        # Replace with new content
        cat "$EXPECTED_LAYOUTS" > "$HYPR_LAYOUTS"

        echo "  ✓ Workspace persistence configured (workspaces 1-$MAX_WORKSPACE)"
    fi
else
    # Create new file
    cat "$EXPECTED_LAYOUTS" > "$HYPR_LAYOUTS"
    echo "  ✓ Created workspace-layouts.conf (workspaces 1-$MAX_WORKSPACE)"
fi

rm -f "$EXPECTED_LAYOUTS"
echo ""

# ============================================================================
# Add CSS color coding to style.css
# ============================================================================

echo "Adding CSS color coding..."

# Generate expected CSS based on monitor count
# NOTE: Without persistent-workspaces, each monitor shows only its 10 workspaces
# So we can't use nth-child selectors to color by workspace ID since position != ID
# For now, we use uniform theme colors for all workspaces
EXPECTED_CSS='/* Workspace styling - using theme colors */
#workspaces button {
  color: @foreground;
}

/* Visual separator - first workspace on each monitor */
#workspaces button:first-child {
  margin-left: 8px;
}'

# Check if CSS already contains the expected workspace color coding
if [ -f "$WAYBAR_STYLE" ]; then
    # Extract current workspace color coding (between the custom marker and visual separator)
    CURRENT_CSS=$(sed -n '/CUSTOM: Workspace Color Coding/,/Visual separator between workspace ranges/p' "$WAYBAR_STYLE" 2>/dev/null | head -n -2 | tail -n +4)

    # Normalize whitespace for comparison
    CURRENT_NORMALIZED=$(echo "$CURRENT_CSS" | tr -d ' \n\t')
    EXPECTED_NORMALIZED=$(echo "$EXPECTED_CSS" | tr -d ' \n\t')

    if [ "$CURRENT_NORMALIZED" = "$EXPECTED_NORMALIZED" ]; then
        echo "  ⊘ CSS color coding already correct, no changes needed"
    else
        # Backup before making changes
        cp "$WAYBAR_STYLE" "${WAYBAR_STYLE}.bak.$(date +%s)"
        echo "  ✓ Backed up existing style.css"

        # Remove old custom section
        sed -i '/\/\* ============================================================================/,/^EOF$/d' "$WAYBAR_STYLE"
        sed -i '/Color coding for different monitor ranges/,/^}/d' "$WAYBAR_STYLE"

        # Add new CSS
        cat >> "$WAYBAR_STYLE" << 'CSSEOF'

/* ============================================================================
   CUSTOM: Workspace Color Coding (Auto-generated)
   ============================================================================ */

CSSEOF
        echo "$EXPECTED_CSS" >> "$WAYBAR_STYLE"

        echo "  ✓ CSS color coding updated"
    fi
else
    echo "  ⚠ style.css not found, skipping"
fi

echo "✓ CSS workspace styling added"
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
        echo "  • ${MONITORS[0]}: workspaces 1-10"
        ;;
    2)
        echo "  • ${MONITORS[0]}: workspaces 1-10"
        echo "  • ${MONITORS[1]}: workspaces 11-20"
        ;;
    *)
        echo "  • ${MONITORS[0]}: workspaces 1-10"
        echo "  • ${MONITORS[1]}: workspaces 11-20"
        echo "  • ${MONITORS[2]}: workspaces 21-30"
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
