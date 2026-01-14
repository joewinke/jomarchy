#!/bin/bash

# Theme Template Fixes
# Fixes omarchy theme template processing to work without Python yq
# and adds proper accent color support for waybar

set -e

echo "========================================"
echo "Theme Template Fixes"
echo "========================================"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
JOMARCHY_ROOT="$SCRIPT_DIR/../.."

# ============================================================================
# 1. Install patched omarchy-theme-set-templates script
# ============================================================================

echo -e "${BLUE}Installing patched theme template processor...${NC}"

TEMPLATE_SCRIPT="$JOMARCHY_ROOT/files/omarchy-theme-set-templates"
TARGET_LOCAL="$HOME/.local/bin/omarchy-theme-set-templates"
TARGET_OMARCHY="$HOME/.local/share/omarchy/bin/omarchy-theme-set-templates"

if [[ -f "$TEMPLATE_SCRIPT" ]]; then
    # Install to ~/.local/bin
    mkdir -p "$HOME/.local/bin"
    cp "$TEMPLATE_SCRIPT" "$TARGET_LOCAL"
    chmod +x "$TARGET_LOCAL"
    echo -e "${GREEN}✓${NC} Installed to ~/.local/bin/"

    # Also install to omarchy bin (used when called from UI)
    if [[ -d "$HOME/.local/share/omarchy/bin" ]]; then
        cp "$TEMPLATE_SCRIPT" "$TARGET_OMARCHY"
        chmod +x "$TARGET_OMARCHY"
        echo -e "${GREEN}✓${NC} Installed to ~/.local/share/omarchy/bin/"
    fi
else
    echo -e "${YELLOW}⚠${NC} Template script not found in jomarchy, skipping"
fi
echo ""

# ============================================================================
# 2. Install user waybar.css.tpl template (adds accent color support)
# ============================================================================

echo -e "${BLUE}Installing waybar accent color template...${NC}"

USER_TEMPLATES_DIR="$HOME/.config/omarchy/themed"
mkdir -p "$USER_TEMPLATES_DIR"

WAYBAR_TPL="$JOMARCHY_ROOT/files/waybar.css.tpl"
if [[ -f "$WAYBAR_TPL" ]]; then
    cp "$WAYBAR_TPL" "$USER_TEMPLATES_DIR/waybar.css.tpl"
    echo -e "${GREEN}✓${NC} Installed waybar.css.tpl to ~/.config/omarchy/themed/"
else
    # Create inline if file doesn't exist
    cat > "$USER_TEMPLATES_DIR/waybar.css.tpl" << 'EOF'
@define-color foreground {{ foreground }};
@define-color background {{ background }};
@define-color selected-text {{ accent }};
EOF
    echo -e "${GREEN}✓${NC} Created waybar.css.tpl in ~/.config/omarchy/themed/"
fi
echo ""

# ============================================================================
# 3. Remove hardcoded fallback from waybar style.css (if present)
# ============================================================================

echo -e "${BLUE}Checking waybar style.css for hardcoded fallback...${NC}"

WAYBAR_STYLE="$HOME/.config/waybar/style.css"
if [[ -f "$WAYBAR_STYLE" ]]; then
    if grep -q "@define-color selected-text #7dcfff" "$WAYBAR_STYLE" 2>/dev/null; then
        # Remove the fallback lines
        sed -i '/\/\* Fallback accent color if theme.*\*\//d' "$WAYBAR_STYLE"
        sed -i '/@define-color selected-text #7dcfff/d' "$WAYBAR_STYLE"
        # Clean up extra blank lines
        sed -i '/^$/N;/^\n$/d' "$WAYBAR_STYLE"
        echo -e "${GREEN}✓${NC} Removed hardcoded fallback color"
    else
        echo -e "  ${YELLOW}→${NC} No hardcoded fallback found, skipping"
    fi
else
    echo -e "  ${YELLOW}→${NC} waybar style.css not found, skipping"
fi
echo ""

# ============================================================================
# 4. Reapply current theme to fix any existing issues
# ============================================================================

echo -e "${BLUE}Reapplying current theme...${NC}"

CURRENT_THEME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ -n "$CURRENT_THEME" ]]; then
    if command -v omarchy-theme-set &> /dev/null; then
        omarchy-theme-set "$CURRENT_THEME" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Reapplied theme: $CURRENT_THEME"
    else
        echo -e "  ${YELLOW}→${NC} omarchy-theme-set not found, skipping"
    fi
else
    echo -e "  ${YELLOW}→${NC} No current theme found, skipping"
fi
echo ""

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}Theme Template Fixes Complete!${NC}"
echo -e "${GREEN}=======================================${NC}"
echo ""
echo "What was installed:"
echo ""
echo "1. Patched omarchy-theme-set-templates (no Python yq required)"
echo "2. User waybar.css.tpl with accent color support"
echo "3. Cleaned up waybar style.css fallback (if present)"
echo ""
echo "Theme switching should now work correctly with proper"
echo "accent colors in waybar and no Hyprland config errors."
echo ""
