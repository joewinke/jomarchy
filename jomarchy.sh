#!/bin/bash

# Jomarchy - Unified Installer and Management Tool
#
# Bootstrap Mode (fresh install):
#   bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)
#
# Management Mode (after install):
#   jomarchy                  # Interactive menu
#   jomarchy --profiles       # Web app profile manager
#   jomarchy --install        # Install additional profiles
#   jomarchy --update         # Update jomarchy
#   jomarchy --status         # Show installed profiles
#   jomarchy --help           # Show help

set -e  # Exit on error

# Determine script directory (handles both direct execution and symlink)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common library if available
if [[ -f "$SCRIPT_DIR/scripts/lib/common.sh" ]]; then
    source "$SCRIPT_DIR/scripts/lib/common.sh"
else
    # Fallback color codes if common.sh not found
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'

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
fi

# Mode detection functions
is_bootstrap_mode() {
    # Bootstrap only if installation marker doesn't exist
    [[ ! -f "$HOME/.config/jomarchy/installed" ]]
}

# Management menu functions
show_management_menu() {
    show_jomarchy_banner

    while true; do
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}Jomarchy Management${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        local choice
        choice=$(gum choose \
            "Install Additional Profiles" \
            "Manage Web App Profiles" \
            "Update Jomarchy" \
            "View Installation Summary" \
            "View Documentation" \
            "Exit")

        case "$choice" in
            "Install Additional Profiles")
                run_profile_installer
                ;;
            "Manage Web App Profiles")
                run_webapp_profile_manager
                ;;
            "Update Jomarchy")
                update_jomarchy
                ;;
            "View Installation Summary")
                show_installation_summary
                ;;
            "View Documentation")
                show_documentation
                ;;
            "Exit")
                echo ""
                echo -e "${GREEN}Thanks for using Jomarchy!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run profile installer
run_profile_installer() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Install Additional Profiles${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    local profiles
    profiles=$(gum choose --no-limit \
        "BASE - Core system" \
        "DEV - Software development" \
        "MEDIA - Creative tools" \
        "FINANCE - Banking/accounting web apps" \
        "COMMUNICATIONS - Messaging apps")

    if [[ -z "$profiles" ]]; then
        echo -e "${YELLOW}No profiles selected${NC}"
        return
    fi

    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            profile=$(echo "$line" | cut -d'-' -f1 | xargs)
            case "$profile" in
                "BASE")
                    bash "$SCRIPT_DIR/scripts/install/install-jomarchy.sh"
                    ;;
                "DEV")
                    bash "$SCRIPT_DIR/scripts/install/install-jomarchy-dev.sh"
                    ;;
                "MEDIA")
                    bash "$SCRIPT_DIR/scripts/install/install-jomarchy-media.sh"
                    ;;
                "FINANCE")
                    bash "$SCRIPT_DIR/scripts/install/install-jomarchy-finance.sh"
                    ;;
                "COMMUNICATIONS")
                    bash "$SCRIPT_DIR/scripts/install/install-jomarchy-communications.sh"
                    ;;
            esac
        fi
    done <<< "$profiles"
}

# Run webapp profile manager
run_webapp_profile_manager() {
    if [[ -f "$SCRIPT_DIR/scripts/lib/webapp-profile-manager-lib.sh" ]]; then
        source "$SCRIPT_DIR/scripts/lib/webapp-profile-manager-lib.sh"
        webapp_profile_manager_run
    else
        echo -e "${RED}Error: Web app profile manager not found${NC}"
        echo "Please ensure jomarchy is properly installed"
    fi
}

# Update jomarchy
update_jomarchy() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Updating Jomarchy${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    cd "$SCRIPT_DIR"
    echo -e "${BLUE}→${NC} Pulling latest changes..."
    git pull origin master
    echo -e "${GREEN}✓${NC} Jomarchy updated"
}

# Show installation summary
show_installation_summary() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Installation Summary${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ -f "$HOME/.config/jomarchy/installed_profiles" ]]; then
        echo -e "${GREEN}Installed Profiles:${NC}"
        while read -r profile; do
            echo "  ✓ $profile"
        done < "$HOME/.config/jomarchy/installed_profiles"
    else
        echo -e "${YELLOW}No installation information found${NC}"
    fi

    echo ""
    echo -e "${BLUE}Repository:${NC} $SCRIPT_DIR"
    echo -e "${BLUE}Installed:${NC} $(date -r "$HOME/.config/jomarchy/installed" 2>/dev/null || echo "Unknown")"
}

# Show documentation
show_documentation() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Documentation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${YELLOW}Available Documentation:${NC}"
    echo ""
    echo "  • JOMARCHY.md      - Complete installation guide"
    echo "  • JOMARCHY-DEV.md  - Development add-on guide"
    echo "  • README.md        - Project overview"
    echo ""
    echo -e "${BLUE}View with:${NC}"
    echo "  cat $SCRIPT_DIR/JOMARCHY.md | less"
    echo ""
    echo -e "${BLUE}Online:${NC}"
    echo "  https://github.com/joewinke/jomarchy"
}

# CLI flag handling
handle_cli_flags() {
    case "$1" in
        --profiles)
            run_webapp_profile_manager
            ;;
        --install)
            run_profile_installer
            ;;
        --update)
            update_jomarchy
            ;;
        --status)
            show_installation_summary
            ;;
        --help|-h)
            show_jomarchy_banner
            echo "Jomarchy - Unified Installer and Management Tool"
            echo ""
            echo "Usage:"
            echo "  jomarchy               # Interactive management menu"
            echo "  jomarchy --profiles    # Web app profile manager"
            echo "  jomarchy --install     # Install additional profiles"
            echo "  jomarchy --update      # Update jomarchy"
            echo "  jomarchy --status      # Show installation summary"
            echo "  jomarchy --help        # Show this help"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Bootstrap installation function
run_bootstrap_install() {
show_jomarchy_banner

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

# Check for git, install if missing
echo -e "${BLUE}→${NC} Checking dependencies..."
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}→${NC} git not found, installing..."
    sudo pacman -S --noconfirm git
    echo -e "${GREEN}✓${NC} git installed"
else
    echo -e "${GREEN}✓${NC} git found"
fi

# gum should already be installed by Omarchy
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}→${NC} gum not found, installing..."
    sudo pacman -S --noconfirm gum
    echo -e "${GREEN}✓${NC} gum installed"
else
    echo -e "${GREEN}✓${NC} gum found"
fi

# Clone repository
REPO_URL="https://github.com/joewinke/jomarchy.git"
REPO_DIR="$HOME/code/jomarchy"

if [ -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}→${NC} Repository already exists at $REPO_DIR"
    read -p "Update existing repository? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→${NC} Updating repository..."
        cd "$REPO_DIR"
        git pull origin master
        echo -e "${GREEN}✓${NC} Repository updated"
    fi
else
    echo -e "${BLUE}→${NC} Cloning repository to $REPO_DIR..."
    mkdir -p "$HOME/code"
    git clone "$REPO_URL" "$REPO_DIR"
    echo -e "${GREEN}✓${NC} Repository cloned"
fi

cd "$REPO_DIR"

# STEP 1: Profile Selection
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Press SPACE to Select Bundles to Install${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Use gum choose for multi-select
SELECTED=$(gum choose --no-limit \
    "BASE - Core system (browsers, text editor, web apps, ChezWizper)" \
    "DEV - Software development (VS Code, Node, CLIs, dev web apps)" \
    "MEDIA - Creative tools (GIMP, Inkscape, OBS, Blender, Audacity, Kdenlive)" \
    "FINANCE - Banking/accounting web apps (Bank of America, Chase, Capital One, QuickBooks)" \
    "COMMUNICATIONS - Messaging apps (Discord, WhatsApp, Slack, Gmail, Zoom)")

# Check if user cancelled (Ctrl+C)
if [ $? -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}→${NC} Installation cancelled"
    exit 0
fi

# Parse selected profiles (extract profile name before -)
SELECTED_PROFILES=()
while IFS= read -r line; do
    if [ -n "$line" ]; then
        profile=$(echo "$line" | cut -d'-' -f1 | xargs)
        SELECTED_PROFILES+=("$profile")
    fi
done <<< "$SELECTED"

# Check if no profiles selected
if [ ${#SELECTED_PROFILES[@]} -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}→${NC} No profiles selected, exiting"
    exit 0
fi

echo ""
echo -e "${GREEN}→${NC} Selected profiles: ${SELECTED_PROFILES[*]}"
echo ""

# STEP 2: Component Selection for Each Profile
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 2: Select Components for Each Profile${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Collect component selections for each profile
for profile in "${SELECTED_PROFILES[@]}"; do
    echo -e "${BLUE}→ ${profile} Profile Components:${NC}"
    echo ""

    case "$profile" in
        "BASE")
            # BASE component selection is handled by install-jomarchy.sh
            # We'll run it in non-install mode just to get selections
            # For now, keep the selection in the installer itself
            ;;
        "DEV"|"MEDIA"|"FINANCE"|"COMMUNICATIONS")
            # Component selection will be handled by each installer
            # We're showing this step exists but keeping selection in installers for now
            echo -e "${YELLOW}  Components will be selected during ${profile} installation${NC}"
            ;;
    esac
done

echo ""
echo -e "${GREEN}✓${NC} Ready to install with selected profiles and components"
echo ""

# STEP 3: Installation
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Step 3: Installing Selected Profiles${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Install each selected profile
for profile in "${SELECTED_PROFILES[@]}"; do
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Installing $profile Profile${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    case "$profile" in
        "BASE")
            bash scripts/install/install-jomarchy.sh
            ;;
        "DEV")
            bash scripts/install/install-jomarchy-dev.sh
            ;;
        "MEDIA")
            bash scripts/install/install-jomarchy-media.sh
            ;;
        "FINANCE")
            bash scripts/install/install-jomarchy-finance.sh
            ;;
        "COMMUNICATIONS")
            bash scripts/install/install-jomarchy-communications.sh
            ;;
    esac
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  Installation Complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installed profiles: ${SELECTED_PROFILES[*]}"
echo ""
echo "Documentation: https://github.com/joewinke/jomarchy"
echo ""

# Auto-source bashrc if bash customizations were installed
if [[ " ${SELECTED_PROFILES[*]} " =~ " BASE " ]] || [[ " ${SELECTED_PROFILES[*]} " =~ " DEV " ]]; then
    echo "Reloading shell configuration..."
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
        echo -e "${GREEN}✓${NC} Shell configuration reloaded"
    fi
    echo ""
fi

echo "Installation complete. Enjoy Jomarchy!"
echo ""

# Mark as installed and create symlink
mkdir -p "$HOME/.config/jomarchy"
touch "$HOME/.config/jomarchy/installed"
echo "$(date +%s)" > "$HOME/.config/jomarchy/installed"

# Create symlink if it doesn't exist
if [[ ! -f "$HOME/.local/bin/jomarchy" ]]; then
    echo -e "${BLUE}→${NC} Creating jomarchy command symlink..."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$REPO_DIR/jomarchy.sh" "$HOME/.local/bin/jomarchy"
    echo -e "${GREEN}✓${NC} You can now run 'jomarchy' from anywhere"
    echo ""
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Manage your installation:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  • Run ${CYAN}jomarchy${NC} for management menu"
echo "  • Run ${CYAN}jomarchy --profiles${NC} to organize web apps by Chrome profile"
echo "  • Run ${CYAN}jomarchy --help${NC} for all options"
echo ""

}  # End of run_bootstrap_install()

# ============================================================================
# MAIN EXECUTION
# ============================================================================

# Detect mode and run appropriate function
if [[ $# -gt 0 ]]; then
    # CLI flags provided
    handle_cli_flags "$1"
elif is_bootstrap_mode; then
    # Bootstrap mode - fresh installation
    run_bootstrap_install
else
    # Management mode - show interactive menu
    show_management_menu
fi
