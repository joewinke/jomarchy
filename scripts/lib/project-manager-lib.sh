#!/bin/bash
# Project Manager Library for Jomarchy
# Manage project configurations (colors, paths, ports) and auto-generate
# bash launcher functions and Hyprland window rules
# This is a library file meant to be sourced, not executed directly
# Assumes common.sh has been sourced for color variables

# ============================================================================
# CORE CONFIGURATION
# ============================================================================

readonly PROJECTS_CONFIG="${HOME}/.config/jomarchy/projects.conf"
readonly PROJECTS_SECRETS="${HOME}/.config/jomarchy/secrets.env"
readonly GENERATED_DIR="${HOME}/.local/share/jomarchy/generated"
readonly GENERATED_BASH="${GENERATED_DIR}/project-functions.bash"
readonly GENERATED_HYPR="${GENERATED_DIR}/project-rules.hypr"

# Config file format:
# KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR
# Example: chimaro|CHIMARO|~/code/chimaro|3500|DATABASE_URL|00d4aa|00a080

# Color palette for new projects (hex colors without #)
# Format: ACTIVE|INACTIVE|NAME
readonly -a COLOR_PALETTE=(
    "00d4aa|00a080|Cyan (Teal)"
    "bb66ff|9944dd|Purple"
    "ff9933|dd7711|Orange"
    "44ff44|22cc22|Green"
    "ff5555|cc3333|Red"
    "ffdd00|ccaa00|Yellow"
    "5588ff|3366dd|Blue"
    "ff6699|cc4477|Pink"
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Ensure config directory exists
_ensure_config_dirs() {
    mkdir -p "$(dirname "$PROJECTS_CONFIG")"
    mkdir -p "$GENERATED_DIR"
}

# Check if projects config exists
_config_exists() {
    [[ -f "$PROJECTS_CONFIG" ]]
}

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

# Get all projects from config file
# Output: pipe-delimited project entries, one per line
# Format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR
get_projects() {
    if ! _config_exists; then
        return 1
    fi

    # Skip comments and empty lines
    grep -v '^#' "$PROJECTS_CONFIG" | grep -v '^[[:space:]]*$'
}

# Get a specific project by key
# $1: project key (e.g., "chimaro")
# Output: pipe-delimited project entry
get_project() {
    local key="$1"
    if ! _config_exists; then
        return 1
    fi

    grep "^${key}|" "$PROJECTS_CONFIG"
}

# Count total projects
count_projects() {
    if ! _config_exists; then
        echo "0"
        return
    fi

    get_projects | wc -l
}

# Show projects in a formatted table with colors
show_projects_list() {
    if ! _config_exists; then
        echo -e "${YELLOW}No projects configured yet.${NC}"
        echo -e "${CYAN}Run 'jomarchy --projects' to set up projects.${NC}"
        return 1
    fi

    local project_count
    project_count=$(count_projects)

    if [[ "$project_count" -eq 0 ]]; then
        echo -e "${YELLOW}No projects configured yet.${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=== Project Configuration (${project_count} projects) ===${NC}\n"

    # Header
    printf "%-12s %-12s %-30s %-6s %-10s %s\n" \
        "KEY" "NAME" "PATH" "PORT" "DB_VAR" "COLORS"
    printf "%-12s %-12s %-30s %-6s %-10s %s\n" \
        "───────────" "───────────" "─────────────────────────────" "─────" "─────────" "───────────────"

    # Projects
    while IFS='|' read -r key name path port db_var active_color inactive_color; do
        [[ -z "$key" ]] && continue

        # Truncate path if too long
        local display_path="$path"
        if [[ ${#display_path} -gt 28 ]]; then
            display_path="${display_path:0:25}..."
        fi

        # Show color swatches using ANSI escape sequences
        # Use printf with escape sequences for colored blocks
        local color_display
        color_display=$(printf "\e[48;2;%d;%d;%dm  \e[0m/\e[48;2;%d;%d;%dm  \e[0m" \
            "$((16#${active_color:0:2}))" "$((16#${active_color:2:2}))" "$((16#${active_color:4:2}))" \
            "$((16#${inactive_color:0:2}))" "$((16#${inactive_color:2:2}))" "$((16#${inactive_color:4:2}))")

        printf "%-12s %-12s %-30s %-6s %-10s %b\n" \
            "$key" "$name" "$display_path" "${port:-─}" "${db_var:-─}" "$color_display"
    done < <(get_projects)

    echo
}

# Interactive color picker using gum
# Output: ACTIVE_COLOR|INACTIVE_COLOR (hex without #)
pick_color() {
    local current_active="${1:-}"
    local current_inactive="${2:-}"

    echo -e "\n${CYAN}Select a color scheme:${NC}\n"

    # Build choices array
    local choices=()
    for color_entry in "${COLOR_PALETTE[@]}"; do
        IFS='|' read -r active inactive name <<< "$color_entry"
        choices+=("$name")
    done
    choices+=("Custom (enter hex)")

    # Show selection
    local selected
    selected=$(printf '%s\n' "${choices[@]}" | gum choose --header="Choose border color:")

    if [[ -z "$selected" ]]; then
        # User cancelled - return current or default
        if [[ -n "$current_active" && -n "$current_inactive" ]]; then
            echo "${current_active}|${current_inactive}"
        else
            echo "5588ff|3366dd"  # Default blue
        fi
        return
    fi

    if [[ "$selected" == "Custom (enter hex)" ]]; then
        # Custom color input
        local custom_active custom_inactive

        echo -e "\n${CYAN}Enter hex colors (without #):${NC}"
        custom_active=$(gum input --header="Active border color (e.g., 00d4aa):" --placeholder="${current_active:-00d4aa}")
        custom_inactive=$(gum input --header="Inactive border color (e.g., 00a080):" --placeholder="${current_inactive:-00a080}")

        # Validate hex format (6 characters, hex digits only)
        if [[ ! "$custom_active" =~ ^[0-9a-fA-F]{6}$ ]]; then
            echo -e "${RED}Invalid active color. Using default.${NC}" >&2
            custom_active="5588ff"
        fi
        if [[ ! "$custom_inactive" =~ ^[0-9a-fA-F]{6}$ ]]; then
            echo -e "${RED}Invalid inactive color. Using default.${NC}" >&2
            custom_inactive="3366dd"
        fi

        echo "${custom_active,,}|${custom_inactive,,}"  # lowercase
    else
        # Find matching palette entry
        for color_entry in "${COLOR_PALETTE[@]}"; do
            IFS='|' read -r active inactive name <<< "$color_entry"
            if [[ "$name" == "$selected" ]]; then
                echo "${active}|${inactive}"
                return
            fi
        done

        # Fallback
        echo "5588ff|3366dd"
    fi
}

# Scan ~/code directory for git repositories
# Output: repo_name|path for each found repo
scan_code_directory() {
    local code_dir="${1:-$HOME/code}"

    if [[ ! -d "$code_dir" ]]; then
        echo -e "${YELLOW}Directory $code_dir does not exist.${NC}" >&2
        return 1
    fi

    # Find directories with .git, max depth 2
    find "$code_dir" -maxdepth 2 -type d -name ".git" 2>/dev/null | while read -r git_dir; do
        local repo_path repo_name
        repo_path=$(dirname "$git_dir")
        repo_name=$(basename "$repo_path")

        # Skip if already configured
        if get_project "$repo_name" >/dev/null 2>&1; then
            continue
        fi

        echo "${repo_name}|${repo_path}"
    done | sort
}

# ============================================================================
# GENERATION FUNCTIONS
# ============================================================================

# Generate bash functions file (project-functions.bash)
generate_bash_functions() {
    _ensure_config_dirs

    if ! _config_exists; then
        echo -e "${RED}Error: No projects.conf found${NC}" >&2
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    cat > "$temp_file" << 'HEADER'
#!/bin/bash
# AUTO-GENERATED by jomarchy project manager
# DO NOT EDIT - changes will be overwritten
# Generated: TIMESTAMP

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

# Set terminal title and apply border colors
_jat_set_style() {
    local name="$1"
    local active_color="$2"
    local inactive_color="$3"

    # Set terminal title
    echo -ne "\033]0;${name}: $(pwd)\007"

    # Apply border color to current window
    local addr
    addr=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
    if [[ -n "$addr" ]]; then
        hyprctl dispatch setprop "address:$addr" activebordercolor "rgb($active_color)" &>/dev/null
        hyprctl dispatch setprop "address:$addr" inactivebordercolor "rgb($inactive_color)" &>/dev/null
    fi
}

# Apply colors to all windows matching a title prefix
_jat_apply_colors() {
    local title_prefix="$1"
    local active_color="$2"
    local inactive_color="$3"

    hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.title | startswith(\"$title_prefix\")) | .address" | while read -r addr; do
        [[ -z "$addr" ]] && continue
        hyprctl dispatch setprop "address:$addr" activebordercolor "rgb($active_color)" &>/dev/null
        hyprctl dispatch setprop "address:$addr" inactivebordercolor "rgb($inactive_color)" &>/dev/null
    done
}

# Core project launcher
# $1: project key
# $2: mode (all|code|claude|npm)
_jat_launch() {
    local project="$1"
    local mode="${2:-all}"

    case "$project" in
PROJECT_CASES
    esac
}

# Claude-only launcher
# $1: project key
_jat_claude() {
    _jat_launch "$1" "claude"
}

# Reapply all project colors
jcolors() {
    echo "Reapplying project colors..."
COLOR_APPLY_CALLS
    echo "Done!"
}

# Show help with current projects
jhelp() {
    echo -e "\n\e[1;34m=== Jomarchy Project Launchers ===\e[0m\n"
    echo -e "Usage: j<key> [mode]  or  cc<key>\n"
    echo -e "Modes:"
    echo -e "  all     - Open code editor + Claude + npm dev server (default)"
    echo -e "  code    - Open code editor only"
    echo -e "  claude  - Open Claude Code only"
    echo -e "  npm     - Start npm dev server only\n"
    echo -e "Available projects:"
PROJECT_HELP_LIST
    echo -e "\nOther commands:"
    echo -e "  jcolors  - Reapply all border colors"
    echo -e "  jhelp    - Show this help\n"
}

# ============================================================================
# PROJECT ALIASES
# ============================================================================

PROJECT_ALIASES
HEADER

    # Replace timestamp
    sed -i "s/TIMESTAMP/$(date '+%Y-%m-%d %H:%M:%S')/" "$temp_file"

    # Build project cases, color apply calls, help list, and aliases
    local project_cases=""
    local color_apply_calls=""
    local project_help_list=""
    local project_aliases=""

    while IFS='|' read -r key name path port db_var active_color inactive_color; do
        [[ -z "$key" ]] && continue

        # Expand ~ in path
        local expanded_path="${path/#\~/$HOME}"

        # Project case entry
        project_cases+="        ${key})
            local name=\"${name}\"
            local path=\"${expanded_path}\"
            local port=\"${port}\"
            local db_var=\"${db_var}\"
            local active=\"${active_color}\"
            local inactive=\"${inactive_color}\"

            _jat_set_style \"\$name\" \"\$active\" \"\$inactive\"

            case \"\$mode\" in
                all)
                    cd \"\$path\" || return 1
                    code .
                    [[ -n \"\$port\" ]] && npm run dev &
                    claude
                    ;;
                code)
                    cd \"\$path\" || return 1
                    code .
                    ;;
                claude)
                    cd \"\$path\" || return 1
                    claude
                    ;;
                npm)
                    cd \"\$path\" || return 1
                    [[ -n \"\$port\" ]] && npm run dev
                    ;;
            esac
            ;;
"

        # Color apply call
        color_apply_calls+="    _jat_apply_colors \"${name}:\" \"${active_color}\" \"${inactive_color}\"\n"

        # Help list entry
        project_help_list+="    printf \"  %-8s %-12s %s\\\\n\" \"j${key}\" \"(${name})\" \"${path}\"\n"

        # Aliases
        project_aliases+="# ${name}
j${key}() { _jat_launch \"${key}\" \"\${1:-all}\"; }
cc${key}() { _jat_claude \"${key}\"; }
"
    done < <(get_projects)

    # Add default case
    project_cases+="        *)
            echo \"Unknown project: \$project\"
            echo \"Use 'jhelp' to see available projects\"
            return 1
            ;;
"

    # Replace placeholders
    sed -i "s|PROJECT_CASES|${project_cases}|" "$temp_file"

    # For multi-line replacements, use awk or a different approach
    # Using a temp file approach for color_apply_calls
    local apply_file help_file alias_file
    apply_file=$(mktemp)
    help_file=$(mktemp)
    alias_file=$(mktemp)

    echo -e "$color_apply_calls" > "$apply_file"
    echo -e "$project_help_list" > "$help_file"
    echo -e "$project_aliases" > "$alias_file"

    # Use sed with file reads
    sed -i "/COLOR_APPLY_CALLS/r $apply_file" "$temp_file"
    sed -i "/COLOR_APPLY_CALLS/d" "$temp_file"

    sed -i "/PROJECT_HELP_LIST/r $help_file" "$temp_file"
    sed -i "/PROJECT_HELP_LIST/d" "$temp_file"

    sed -i "/PROJECT_ALIASES/r $alias_file" "$temp_file"
    sed -i "/PROJECT_ALIASES/d" "$temp_file"

    # Cleanup temp files
    rm -f "$apply_file" "$help_file" "$alias_file"

    # Move to final location
    mv "$temp_file" "$GENERATED_BASH"
    chmod +x "$GENERATED_BASH"

    echo -e "${GREEN}✓ Generated: $GENERATED_BASH${NC}"
}

# Generate Hyprland rules file (project-rules.hypr)
generate_hyprland_rules() {
    _ensure_config_dirs

    if ! _config_exists; then
        echo -e "${RED}Error: No projects.conf found${NC}" >&2
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    # Header
    cat > "$temp_file" << HEADER
# AUTO-GENERATED by jomarchy project manager
# DO NOT EDIT - changes will be overwritten
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
#
# Window border color rules for project windows
# Colors are applied based on window title prefix

HEADER

    # Collect all project name prefixes for the combined border size rule
    local all_prefixes=""

    # Generate rules for each project
    while IFS='|' read -r key name path port db_var active_color inactive_color; do
        [[ -z "$key" ]] && continue

        # Border color rule
        echo "# ${name}" >> "$temp_file"
        echo "windowrulev2 = bordercolor rgb(${active_color}) rgb(${inactive_color}), title:^(${name}:)" >> "$temp_file"
        echo "" >> "$temp_file"

        # Collect prefix for combined rule
        if [[ -n "$all_prefixes" ]]; then
            all_prefixes="${all_prefixes}|${name}:"
        else
            all_prefixes="${name}:"
        fi
    done < <(get_projects)

    # Combined border size rule
    if [[ -n "$all_prefixes" ]]; then
        echo "# Apply thicker borders to all project windows" >> "$temp_file"
        echo "windowrulev2 = bordersize 3, title:^(${all_prefixes})" >> "$temp_file"
    fi

    # Move to final location
    mv "$temp_file" "$GENERATED_HYPR"

    echo -e "${GREEN}✓ Generated: $GENERATED_HYPR${NC}"
}

# Regenerate all files and reload Hyprland
regenerate_all() {
    echo -e "\n${CYAN}Regenerating project configurations...${NC}\n"

    # Generate bash functions
    if generate_bash_functions; then
        echo -e "  ${GREEN}✓${NC} Bash functions generated"
    else
        echo -e "  ${RED}✗${NC} Failed to generate bash functions"
        return 1
    fi

    # Generate Hyprland rules
    if generate_hyprland_rules; then
        echo -e "  ${GREEN}✓${NC} Hyprland rules generated"
    else
        echo -e "  ${RED}✗${NC} Failed to generate Hyprland rules"
        return 1
    fi

    # Reload Hyprland config
    if command -v hyprctl &>/dev/null; then
        if hyprctl reload &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Hyprland config reloaded"
        else
            echo -e "  ${YELLOW}⚠${NC} Could not reload Hyprland (may need manual reload)"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} Hyprland not found (skipping reload)"
    fi

    # Source new bash functions in current shell
    echo -e "\n${CYAN}To apply bash functions in current shell:${NC}"
    echo -e "  source ${GENERATED_BASH}"
    echo
}

# ============================================================================
# MAIN MENU (called by jomarchy.sh)
# ============================================================================

# Main entry point for project manager
project_manager_run() {
    # Check dependencies
    local missing_deps=()
    for cmd in gum jq; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "Install with: ${CYAN}sudo pacman -S ${missing_deps[*]}${NC}"
        return 1
    fi

    _ensure_config_dirs

    while true; do
        echo -e "\n${BLUE}=== Project Manager ===${NC}"

        local choice
        choice=$(echo -e "View Projects\nAdd Project\nEdit Project\nRemove Project\nRegenerate All\nImport from .bashrc\nExit" | \
            gum choose --header="What would you like to do?")

        case "$choice" in
            "View Projects")
                show_projects_list
                ;;
            "Add Project")
                # Placeholder for add_project (will be in CRUD task)
                echo -e "${YELLOW}Add project functionality coming in next update.${NC}"
                ;;
            "Edit Project")
                # Placeholder for edit_project (will be in CRUD task)
                echo -e "${YELLOW}Edit project functionality coming in next update.${NC}"
                ;;
            "Remove Project")
                # Placeholder for remove_project (will be in CRUD task)
                echo -e "${YELLOW}Remove project functionality coming in next update.${NC}"
                ;;
            "Regenerate All")
                regenerate_all
                ;;
            "Import from .bashrc")
                # Placeholder for import_from_bashrc (will be in migration task)
                echo -e "${YELLOW}Import functionality coming in next update.${NC}"
                ;;
            "Exit")
                echo -e "\n${GREEN}Thanks for using Project Manager!${NC}"
                return 0
                ;;
            *)
                # User cancelled
                return 0
                ;;
        esac
    done
}
