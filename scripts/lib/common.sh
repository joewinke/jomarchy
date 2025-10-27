# Common Functions and Variables for Jomarchy
# Shared utilities used across jomarchy scripts

# Color codes
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Jomarchy paths
readonly JOMARCHY_DIR="$HOME/code/jomarchy"
readonly JOMARCHY_SCRIPT="$JOMARCHY_DIR/jomarchy.sh"
readonly INSTALL_MARKER="$HOME/.config/jomarchy/installed"

# Check if jomarchy is installed
is_jomarchy_installed() {
    [[ -d "$JOMARCHY_DIR" ]] && [[ -f "$INSTALL_MARKER" ]]
}

# Mark jomarchy as installed
mark_installed() {
    mkdir -p "$(dirname "$INSTALL_MARKER")"
    touch "$INSTALL_MARKER"
    echo "$(date +%s)" > "$INSTALL_MARKER"
}

# Get installed profiles
get_installed_profiles() {
    local profiles_file="$HOME/.config/jomarchy/installed_profiles"
    if [[ -f "$profiles_file" ]]; then
        cat "$profiles_file"
    fi
}

# Add installed profile
add_installed_profile() {
    local profile="$1"
    local profiles_file="$HOME/.config/jomarchy/installed_profiles"
    mkdir -p "$(dirname "$profiles_file")"

    # Add profile if not already listed
    if ! grep -q "^${profile}$" "$profiles_file" 2>/dev/null; then
        echo "$profile" >> "$profiles_file"
    fi
}

# Check if running in bootstrap mode (fresh install)
is_bootstrap_mode() {
    # Bootstrap mode if jomarchy dir doesn't exist or not marked as installed
    ! is_jomarchy_installed
}

# Display jomarchy ASCII art
show_jomarchy_banner() {
    cat << 'EOF'
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
    echo ""
    echo -e "${CYAN}${BOLD}Joe's complete Omarchy configuration system${NC}"
    echo ""
}

# Check for required dependencies
check_dependency() {
    local cmd="$1"
    local package="${2:-$cmd}"

    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${YELLOW}→${NC} $cmd not found, installing..."
        sudo pacman -S --noconfirm "$package"
        echo -e "${GREEN}✓${NC} $cmd installed"
    else
        echo -e "${GREEN}✓${NC} $cmd found"
    fi
}
