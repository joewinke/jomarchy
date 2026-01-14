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
# KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR|SHORT_ALIAS
# Example: chimaro|CHIMARO|~/code/chimaro|3500|DATABASE_URL|00d4aa|00a080|c
# SHORT_ALIAS is optional - if empty, uses first letter of key (first-come-first-served)

# Color palette for new projects (hex colors without #)
# Format: ACTIVE|INACTIVE|NAME|VSCODE_THEME
readonly -a COLOR_PALETTE=(
    "00d4aa|00a080|Cyan (Teal)|Monokai Dimmed"
    "bb66ff|9944dd|Purple|Dracula"
    "ff9933|dd7711|Orange|Kimbie Dark"
    "44ff44|22cc22|Green|Monokai"
    "ff5555|cc3333|Red|Tomorrow Night Red"
    "ffdd00|ccaa00|Yellow|Solarized Light"
    "5588ff|3366dd|Blue|One Dark Pro"
    "ff6699|cc4477|Pink|SynthWave '84"
)

# Get VS Code theme for a given active color
_get_vscode_theme_for_color() {
    local active_color="$1"
    for entry in "${COLOR_PALETTE[@]}"; do
        IFS='|' read -r active inactive name theme <<< "$entry"
        if [[ "$active" == "$active_color" ]]; then
            echo "$theme"
            return
        fi
    done
    # Default theme if color not found
    echo "Default Dark+"
}

# Update VS Code settings.json with the theme for a project
_update_vscode_theme() {
    local project_path="$1"
    local active_color="$2"

    local theme
    theme=$(_get_vscode_theme_for_color "$active_color")

    local vscode_dir="${project_path}/.vscode"
    local settings_file="${vscode_dir}/settings.json"

    # Create .vscode directory if needed
    mkdir -p "$vscode_dir"

    if [[ -f "$settings_file" ]]; then
        # Update existing settings.json
        if grep -q '"workbench.colorTheme"' "$settings_file"; then
            # Replace existing theme
            sed -i "s/\"workbench.colorTheme\": *\"[^\"]*\"/\"workbench.colorTheme\": \"$theme\"/" "$settings_file"
        else
            # Add theme to existing settings (after first {)
            sed -i "s/{/{\\n  \"workbench.colorTheme\": \"$theme\",/" "$settings_file"
        fi
    else
        # Create new settings.json
        cat > "$settings_file" << EOF
{
  "workbench.colorTheme": "$theme"
}
EOF
    fi

    echo -e "${GREEN}✓${NC} Set VS Code theme to: $theme"
}

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

    # Pre-compute short alias assignments (first-come-first-served)
    # Store as: key=short_alias (one per line) in temp file
    local short_alias_file
    short_alias_file=$(mktemp)

    local -A used_shorts=()

    while IFS='|' read -r key name path port db_var active_color inactive_color custom_short; do
        [[ -z "$key" ]] && continue

        local assigned=""

        # Check for user-specified custom short alias (8th field)
        if [[ -n "$custom_short" && -z "${used_shorts[$custom_short]}" ]]; then
            assigned="$custom_short"
            used_shorts["$custom_short"]=1
        fi

        # If no custom short or it was taken, try first letter
        if [[ -z "$assigned" ]]; then
            local first="${key:0:1}"
            if [[ -z "${used_shorts[$first]}" ]]; then
                assigned="$first"
                used_shorts["$first"]=1
            fi
        fi

        # Write assignment to file (empty if collision)
        echo "${key}=${assigned}" >> "$short_alias_file"
    done < <(get_projects)

    # Helper function to get short alias for a key
    _get_short() {
        local key="$1"
        grep "^${key}=" "$short_alias_file" | cut -d'=' -f2
    }

    # Write directly to output file, building content as we go
    {
        # Header
        cat << 'HEADER'
#!/bin/bash
# AUTO-GENERATED by jomarchy project manager
# DO NOT EDIT - changes will be overwritten
HEADER
        echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        # Core functions
        cat << 'CORE'

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

# Apply colors to windows whose title contains a path substring (case-insensitive)
_jat_apply_colors_by_path() {
    local path_substring="$1"
    local active_color="$2"
    local inactive_color="$3"

    # Use ascii_downcase for case-insensitive matching
    hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.title | ascii_downcase | contains(\"${path_substring,,}\")) | .address" | while read -r addr; do
        [[ -z "$addr" ]] && continue
        hyprctl dispatch setprop "address:$addr" activebordercolor "rgb($active_color)" &>/dev/null
        hyprctl dispatch setprop "address:$addr" inactivebordercolor "rgb($inactive_color)" &>/dev/null
    done
}

# Apply colors to the most recently opened window of a given class
_jat_apply_colors_by_class() {
    local window_class="$1"
    local active_color="$2"
    local inactive_color="$3"

    hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.class == \"$window_class\") | .address" | while read -r addr; do
        [[ -z "$addr" ]] && continue
        hyprctl dispatch setprop "address:$addr" activebordercolor "rgb($active_color)" &>/dev/null
        hyprctl dispatch setprop "address:$addr" inactivebordercolor "rgb($inactive_color)" &>/dev/null
    done
}

# Wait for VS Code window to appear, then apply colors (runs in background)
# $1: project key (for path matching)
# $2: active color
# $3: inactive color
# $4: max wait time in seconds (default 10)
_jat_wait_for_vscode_and_apply() {
    local project_key="$1"
    local active_color="$2"
    local inactive_color="$3"
    local max_wait="${4:-10}"
    local waited=0
    local interval=0.5

    # Run in background subshell
    (
        while (( waited < max_wait )); do
            # Check if any code-oss/Code/vscodium window exists with the project path in title
            local found
            found=$(hyprctl clients -j 2>/dev/null | jq -r ".[] | select((.class == \"code-oss\" or .class == \"Code\" or .class == \"vscodium\") and (.title | ascii_downcase | contains(\"${project_key,,}\"))) | .address" | head -1)

            if [[ -n "$found" ]]; then
                # Found the window, apply colors to all matching
                hyprctl clients -j 2>/dev/null | jq -r ".[] | select((.class == \"code-oss\" or .class == \"Code\" or .class == \"vscodium\") and (.title | ascii_downcase | contains(\"${project_key,,}\"))) | .address" | while read -r addr; do
                    [[ -z "$addr" ]] && continue
                    hyprctl dispatch setprop "address:$addr" activebordercolor "rgb($active_color)" &>/dev/null
                    hyprctl dispatch setprop "address:$addr" inactivebordercolor "rgb($inactive_color)" &>/dev/null
                done
                break
            fi

            sleep "$interval"
            waited=$(echo "$waited + $interval" | bc)
        done
    ) &
}

# Core project launcher
# $1: project key
# $2: mode (all|code|claude|npm)
_jat_launch() {
    local project="$1"
    local mode="${2:-all}"

    case "$project" in
CORE

        # Generate case entries for each project
        while IFS='|' read -r key name path port db_var active_color inactive_color custom_short; do
            [[ -z "$key" ]] && continue

            # Expand ~ in path
            local expanded_path="${path/#\~/$HOME}"

            cat << CASE_ENTRY
        ${key})
            _jat_set_style "${name}" "${active_color}" "${inactive_color}"
            cd "${expanded_path}" || return 1
            case "\$mode" in
                all)
                    code . &
                    ${port:+npm run dev &}
                    # Apply colors to terminal windows immediately
                    _jat_apply_colors "${name}:" "${active_color}" "${inactive_color}"
                    # Wait for VS Code in background and apply colors when it appears
                    _jat_wait_for_vscode_and_apply "${key}" "${active_color}" "${inactive_color}"
                    claude
                    ;;
                code)
                    code . &
                    # Wait for VS Code in background and apply colors when it appears
                    _jat_wait_for_vscode_and_apply "${key}" "${active_color}" "${inactive_color}"
                    ;;
                claude) claude ;;
                npm) ${port:+npm run dev} ;;
            esac
            ;;
CASE_ENTRY
        done < <(get_projects)

        # Default case and close
        cat << 'DEFAULT_CASE'
        *)
            echo "Unknown project: $project"
            echo "Use 'jhelp' to see available projects"
            return 1
            ;;
    esac
}

# Claude-only launcher
_jat_claude() {
    _jat_launch "$1" "claude"
}

# Reapply all project colors
jcolors() {
    echo "Reapplying project colors..."
DEFAULT_CASE

        # Generate color apply calls
        while IFS='|' read -r key name path port db_var active_color inactive_color custom_short; do
            [[ -z "$key" ]] && continue
            echo "    _jat_apply_colors \"${name}:\" \"${active_color}\" \"${inactive_color}\""
        done < <(get_projects)

        cat << 'JCOLORS_END'
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
JCOLORS_END

        # Generate help list with short aliases only if assigned
        while IFS='|' read -r key name path port db_var active_color inactive_color custom_short; do
            [[ -z "$key" ]] && continue
            local short
            short=$(_get_short "$key")
            if [[ -n "$short" ]]; then
                echo "    printf \"  %-12s %-6s %-12s %s\\n\" \"j${key}\" \"(j${short})\" \"(${name})\" \"${path}\""
            else
                echo "    printf \"  %-12s %-6s %-12s %s\\n\" \"j${key}\" \"\" \"(${name})\" \"${path}\""
            fi
        done < <(get_projects)

        cat << 'HELP_END'
    echo -e "\nOther commands:"
    echo -e "  jcolors  - Reapply all border colors"
    echo -e "  jhelp    - Show this help\n"
}

# ============================================================================
# PROJECT ALIASES
# ============================================================================

HELP_END

        # Generate aliases with short alias from pre-computed file
        while IFS='|' read -r key name path port db_var active_color inactive_color custom_short; do
            [[ -z "$key" ]] && continue

            echo "# ${name}"
            echo "j${key}() { _jat_launch \"${key}\" \"\${1:-all}\"; }"
            echo "cc${key}() { _jat_claude \"${key}\"; }"

            # Get pre-computed short alias
            local short
            short=$(_get_short "$key")
            if [[ -n "$short" ]]; then
                echo "j${short}() { _jat_launch \"${key}\" \"\${1:-all}\"; }"
                echo "cc${short}() { _jat_claude \"${key}\"; }"
            fi
        done < <(get_projects)

    } > "$GENERATED_BASH"

    # Cleanup temp file
    rm -f "$short_alias_file"

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
# Syntax: Hyprland 0.53+ (windowrule with match:title)

HEADER

    # Collect all project name prefixes for the combined border size rule
    local all_prefixes=""

    # Generate rules for each project
    while IFS='|' read -r key name path port db_var active_color inactive_color; do
        [[ -z "$key" ]] && continue

        # Border color rule (Hyprland 0.53+ syntax)
        echo "# ${name}" >> "$temp_file"
        echo "windowrule = bordercolor rgb(${active_color}) rgb(${inactive_color}), match:title ^(${name}:)" >> "$temp_file"
        echo "" >> "$temp_file"

        # Collect prefix for combined rule
        if [[ -n "$all_prefixes" ]]; then
            all_prefixes="${all_prefixes}|${name}:"
        else
            all_prefixes="${name}:"
        fi
    done < <(get_projects)

    # Combined border size rule (Hyprland 0.53+ syntax)
    if [[ -n "$all_prefixes" ]]; then
        echo "# Apply thicker borders to all project windows" >> "$temp_file"
        echo "windowrule = bordersize 3, match:title ^(${all_prefixes})" >> "$temp_file"
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
# CRUD OPERATIONS
# ============================================================================

# Add a new project interactively
# Offers to scan ~/code for repos or manual entry
add_project() {
    echo -e "\n${BLUE}=== Add New Project ===${NC}\n"

    _ensure_config_dirs

    # Step 1: Choose how to add
    local add_method
    add_method=$(echo -e "Scan ~/code for repositories\nManual entry" | \
        gum choose --header="How would you like to add a project?")

    [[ -z "$add_method" ]] && return 1

    local key name path port db_var

    if [[ "$add_method" == "Scan ~/code for repositories" ]]; then
        # Scan for unconfigured repos
        local repos
        repos=$(scan_code_directory)

        if [[ -z "$repos" ]]; then
            echo -e "${YELLOW}No new repositories found in ~/code.${NC}"
            echo -e "${CYAN}All existing repos may already be configured.${NC}"
            return 1
        fi

        # Let user select from discovered repos
        local selected_repo
        selected_repo=$(echo "$repos" | cut -d'|' -f1 | \
            gum choose --header="Select a repository to add:")

        [[ -z "$selected_repo" ]] && return 1

        # Get path from scan results
        key="$selected_repo"
        path=$(echo "$repos" | grep "^${selected_repo}|" | cut -d'|' -f2)

        # Prompt for display name (default to key in uppercase)
        name=$(gum input --header="Display name:" --value="${key^^}" --placeholder="e.g., CHIMARO")
        [[ -z "$name" ]] && name="${key^^}"

    else
        # Manual entry
        key=$(gum input --header="Project key (lowercase, used for j<key> alias):" --placeholder="e.g., chimaro")
        [[ -z "$key" ]] && return 1

        # Validate key format
        if [[ ! "$key" =~ ^[a-z][a-z0-9_-]*$ ]]; then
            echo -e "${RED}Error: Key must start with lowercase letter and contain only a-z, 0-9, _, -${NC}"
            return 1
        fi

        # Check if key already exists
        if get_project "$key" &>/dev/null; then
            echo -e "${RED}Error: Project '$key' already exists. Use Edit to modify it.${NC}"
            return 1
        fi

        name=$(gum input --header="Display name:" --value="${key^^}" --placeholder="e.g., CHIMARO")
        [[ -z "$name" ]] && name="${key^^}"

        path=$(gum input --header="Project path:" --value="$HOME/code/$key" --placeholder="e.g., ~/code/chimaro")
        [[ -z "$path" ]] && return 1

        # Expand ~ to $HOME for storage
        path="${path/#\~/$HOME}"
    fi

    # Step 2: Optional port
    port=$(gum input --header="Dev server port (leave empty if none):" --placeholder="e.g., 3000")

    # Step 3: Optional database env var
    db_var=$(gum input --header="Database env var (leave empty if none):" --placeholder="e.g., DATABASE_URL")

    # Step 4: Pick colors
    echo -e "\n${CYAN}Choose border colors for this project:${NC}"
    local colors
    colors=$(pick_color)
    local active_color inactive_color
    IFS='|' read -r active_color inactive_color <<< "$colors"

    # Step 5: Optional custom short alias
    local short_alias
    local default_short="${key:0:1}"
    echo -e "\n${CYAN}Short alias (used for j${default_short}, cc${default_short}):${NC}"
    echo -e "${YELLOW}Default: ${default_short} (first letter). Leave empty for default, or enter custom.${NC}"
    echo -e "${YELLOW}Note: If another project uses that letter, you won't get a short alias.${NC}"
    short_alias=$(gum input --header="Custom short alias (single letter, or empty for default):" --placeholder="e.g., x")

    # Validate short alias if provided
    if [[ -n "$short_alias" ]]; then
        if [[ ! "$short_alias" =~ ^[a-z]$ ]]; then
            echo -e "${YELLOW}Invalid short alias (must be single lowercase letter). Using default.${NC}"
            short_alias=""
        fi
    fi

    # Step 6: Confirm
    echo -e "\n${BLUE}=== New Project Summary ===${NC}"
    echo -e "  Key:      ${GREEN}$key${NC}"
    echo -e "  Name:     ${GREEN}$name${NC}"
    echo -e "  Path:     ${GREEN}$path${NC}"
    echo -e "  Port:     ${GREEN}${port:-─}${NC}"
    echo -e "  DB Var:   ${GREEN}${db_var:-─}${NC}"
    printf "  Colors:   Active: \e[48;2;%d;%d;%dm    \e[0m  Inactive: \e[48;2;%d;%d;%dm    \e[0m\n" \
        "$((16#${active_color:0:2}))" "$((16#${active_color:2:2}))" "$((16#${active_color:4:2}))" \
        "$((16#${inactive_color:0:2}))" "$((16#${inactive_color:2:2}))" "$((16#${inactive_color:4:2}))"
    echo -e "  Short:    ${GREEN}${short_alias:-${default_short} (default)}${NC}"

    if ! gum confirm "Add this project?"; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return 1
    fi

    # Step 7: Save to config (8 fields, last is optional short alias)
    local config_line="${key}|${name}|${path}|${port}|${db_var}|${active_color}|${inactive_color}|${short_alias}"

    # Create config file with header if it doesn't exist
    if [[ ! -f "$PROJECTS_CONFIG" ]]; then
        cat > "$PROJECTS_CONFIG" << 'HEADER'
# Jomarchy Project Configuration
# Format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR|SHORT_ALIAS
# Example: chimaro|CHIMARO|~/code/chimaro|3500|DATABASE_URL|00d4aa|00a080|c
#
# Colors are hex without # (e.g., ff5555 for red)
# Leave PORT, DB_ENV_VAR, or SHORT_ALIAS empty if not needed
# SHORT_ALIAS: single letter for jX/ccX aliases (first-come-first-served if collision)

HEADER
    fi

    # Append project
    echo "$config_line" >> "$PROJECTS_CONFIG"

    echo -e "\n${GREEN}✓ Project '$key' added successfully!${NC}"

    # Step 7: Update VS Code theme
    _update_vscode_theme "$path" "$active_color"

    # Step 8: Regenerate
    if gum confirm "Regenerate bash functions and Hyprland rules now?"; then
        regenerate_all
    else
        echo -e "${YELLOW}Remember to run 'Regenerate All' to apply changes.${NC}"
    fi
}

# Edit an existing project
edit_project() {
    if ! _config_exists; then
        echo -e "${YELLOW}No projects configured yet.${NC}"
        return 1
    fi

    local project_count
    project_count=$(count_projects)

    if [[ "$project_count" -eq 0 ]]; then
        echo -e "${YELLOW}No projects to edit.${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=== Edit Project ===${NC}\n"

    # Step 1: Select project
    local keys=()
    while IFS='|' read -r key name _ _ _ _ _; do
        [[ -n "$key" ]] && keys+=("$key ($name)")
    done < <(get_projects)

    local selected
    selected=$(printf '%s\n' "${keys[@]}" | gum choose --header="Select project to edit:")
    [[ -z "$selected" ]] && return 1

    # Extract key from selection
    local edit_key
    edit_key=$(echo "$selected" | sed 's/ (.*$//')

    # Get current values (8 fields including optional short alias)
    local current_line
    current_line=$(get_project "$edit_key")

    local cur_key cur_name cur_path cur_port cur_db cur_active cur_inactive cur_short
    IFS='|' read -r cur_key cur_name cur_path cur_port cur_db cur_active cur_inactive cur_short <<< "$current_line"

    # Step 2: Select what to edit
    local edit_choice
    edit_choice=$(echo -e "Name ($cur_name)\nPath ($cur_path)\nPort (${cur_port:-none})\nDatabase var (${cur_db:-none})\nColors\nShort alias (${cur_short:-${cur_key:0:1}})\nAll fields" | \
        gum choose --header="What would you like to edit?")

    [[ -z "$edit_choice" ]] && return 1

    local new_name="$cur_name"
    local new_path="$cur_path"
    local new_port="$cur_port"
    local new_db="$cur_db"
    local new_active="$cur_active"
    local new_inactive="$cur_inactive"
    local new_short="$cur_short"

    case "$edit_choice" in
        "Name"*)
            new_name=$(gum input --header="New display name:" --value="$cur_name")
            [[ -z "$new_name" ]] && new_name="$cur_name"
            ;;
        "Path"*)
            new_path=$(gum input --header="New path:" --value="$cur_path")
            [[ -z "$new_path" ]] && new_path="$cur_path"
            new_path="${new_path/#\~/$HOME}"
            ;;
        "Port"*)
            new_port=$(gum input --header="New port (leave empty for none):" --value="$cur_port")
            ;;
        "Database"*)
            new_db=$(gum input --header="New database env var (leave empty for none):" --value="$cur_db")
            ;;
        "Colors")
            local colors
            colors=$(pick_color "$cur_active" "$cur_inactive")
            IFS='|' read -r new_active new_inactive <<< "$colors"
            ;;
        "Short alias"*)
            echo -e "\n${CYAN}Current short alias: ${cur_short:-${cur_key:0:1} (default)}${NC}"
            echo -e "${YELLOW}Enter single letter, or empty for default (first letter of key).${NC}"
            new_short=$(gum input --header="New short alias:" --value="$cur_short" --placeholder="e.g., x")
            # Validate
            if [[ -n "$new_short" && ! "$new_short" =~ ^[a-z]$ ]]; then
                echo -e "${YELLOW}Invalid short alias (must be single lowercase letter). Keeping current.${NC}"
                new_short="$cur_short"
            fi
            ;;
        "All fields")
            new_name=$(gum input --header="Display name:" --value="$cur_name")
            [[ -z "$new_name" ]] && new_name="$cur_name"

            new_path=$(gum input --header="Path:" --value="$cur_path")
            [[ -z "$new_path" ]] && new_path="$cur_path"
            new_path="${new_path/#\~/$HOME}"

            new_port=$(gum input --header="Port (leave empty for none):" --value="$cur_port")
            new_db=$(gum input --header="Database env var (leave empty for none):" --value="$cur_db")

            echo -e "\n${CYAN}Choose new colors:${NC}"
            local colors
            colors=$(pick_color "$cur_active" "$cur_inactive")
            IFS='|' read -r new_active new_inactive <<< "$colors"

            echo -e "\n${CYAN}Short alias (current: ${cur_short:-${cur_key:0:1}}):${NC}"
            new_short=$(gum input --header="Short alias (single letter or empty for default):" --value="$cur_short")
            if [[ -n "$new_short" && ! "$new_short" =~ ^[a-z]$ ]]; then
                echo -e "${YELLOW}Invalid short alias. Keeping current.${NC}"
                new_short="$cur_short"
            fi
            ;;
    esac

    # Step 3: Confirm changes
    echo -e "\n${BLUE}=== Changes for '$edit_key' ===${NC}"

    local changed=false
    [[ "$new_name" != "$cur_name" ]] && echo -e "  Name:   ${RED}$cur_name${NC} → ${GREEN}$new_name${NC}" && changed=true
    [[ "$new_path" != "$cur_path" ]] && echo -e "  Path:   ${RED}$cur_path${NC} → ${GREEN}$new_path${NC}" && changed=true
    [[ "$new_port" != "$cur_port" ]] && echo -e "  Port:   ${RED}${cur_port:-─}${NC} → ${GREEN}${new_port:-─}${NC}" && changed=true
    [[ "$new_db" != "$cur_db" ]] && echo -e "  DB Var: ${RED}${cur_db:-─}${NC} → ${GREEN}${new_db:-─}${NC}" && changed=true
    [[ "$new_active" != "$cur_active" || "$new_inactive" != "$cur_inactive" ]] && \
        echo -e "  Colors: Changed" && changed=true
    [[ "$new_short" != "$cur_short" ]] && echo -e "  Short:  ${RED}${cur_short:-─}${NC} → ${GREEN}${new_short:-─}${NC}" && changed=true

    if [[ "$changed" == "false" ]]; then
        echo -e "${YELLOW}No changes made.${NC}"
        return 0
    fi

    if ! gum confirm "Apply these changes?"; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return 1
    fi

    # Step 4: Update config file (8 fields)
    local new_line="${edit_key}|${new_name}|${new_path}|${new_port}|${new_db}|${new_active}|${new_inactive}|${new_short}"

    # Use sed to replace the line (escape pipe in pattern since it's a delimiter)
    sed -i "s|^${edit_key}\\|.*$|${new_line}|" "$PROJECTS_CONFIG"

    echo -e "\n${GREEN}✓ Project '$edit_key' updated successfully!${NC}"

    # Step 5: Update VS Code theme if colors changed
    if [[ "$new_active" != "$cur_active" ]]; then
        _update_vscode_theme "$new_path" "$new_active"
    fi

    # Step 6: Regenerate
    if gum confirm "Regenerate bash functions and Hyprland rules now?"; then
        regenerate_all
    else
        echo -e "${YELLOW}Remember to run 'Regenerate All' to apply changes.${NC}"
    fi
}

# Remove a project from configuration
remove_project() {
    if ! _config_exists; then
        echo -e "${YELLOW}No projects configured yet.${NC}"
        return 1
    fi

    local project_count
    project_count=$(count_projects)

    if [[ "$project_count" -eq 0 ]]; then
        echo -e "${YELLOW}No projects to remove.${NC}"
        return 1
    fi

    echo -e "\n${BLUE}=== Remove Project ===${NC}\n"

    # Step 1: Select project
    local keys=()
    while IFS='|' read -r key name _ _ _ _ _; do
        [[ -n "$key" ]] && keys+=("$key ($name)")
    done < <(get_projects)

    local selected
    selected=$(printf '%s\n' "${keys[@]}" | gum choose --header="Select project to remove:")
    [[ -z "$selected" ]] && return 1

    # Extract key from selection
    local remove_key
    remove_key=$(echo "$selected" | sed 's/ (.*$//')

    # Get project details for display
    local project_line
    project_line=$(get_project "$remove_key")

    local key name path port db_var active_color inactive_color
    IFS='|' read -r key name path port db_var active_color inactive_color <<< "$project_line"

    # Step 2: Show what will be removed
    echo -e "${RED}Warning: This will remove the following project:${NC}\n"
    echo -e "  Key:    ${GREEN}$key${NC}"
    echo -e "  Name:   ${GREEN}$name${NC}"
    echo -e "  Path:   ${GREEN}$path${NC}"
    echo -e ""
    echo -e "${YELLOW}Note: This only removes the configuration.${NC}"
    echo -e "${YELLOW}The actual project files at '$path' will NOT be deleted.${NC}"

    # Step 3: Require confirmation (strict)
    echo -e ""
    if ! gum confirm --default=false "Are you sure you want to remove '$key'?"; then
        echo -e "${GREEN}Cancelled. No changes made.${NC}"
        return 0
    fi

    # Step 4: Remove from config
    # Create temp file without the project
    local temp_file
    temp_file=$(mktemp)

    grep -v "^${remove_key}|" "$PROJECTS_CONFIG" > "$temp_file"
    mv "$temp_file" "$PROJECTS_CONFIG"

    echo -e "\n${GREEN}✓ Project '$remove_key' removed from configuration.${NC}"

    # Step 5: Regenerate
    if gum confirm "Regenerate bash functions and Hyprland rules now?"; then
        regenerate_all
    else
        echo -e "${YELLOW}Remember to run 'Regenerate All' to remove the aliases.${NC}"
    fi
}

# ============================================================================
# PROGRAMMATIC PROJECT ADDITION (for automation)
# ============================================================================

# Auto-add a project without interactive prompts
# Used by bash-customizations-local.sh during repo cloning
# $1: project key (lowercase repo name)
# $2: project path (full path, not ~)
# Returns: 0 on success, 1 on skip/error
auto_add_project() {
    local key="$1"
    local path="$2"

    # Validate inputs
    if [[ -z "$key" || -z "$path" ]]; then
        echo -e "${RED}Error: auto_add_project requires key and path${NC}" >&2
        return 1
    fi

    # Normalize key to lowercase
    key="${key,,}"

    # Skip if project already exists
    if get_project "$key" &>/dev/null; then
        echo -e "  ${YELLOW}⊘${NC} Project '$key' already configured, skipping"
        return 1
    fi

    # Validate key format
    if [[ ! "$key" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        echo -e "  ${RED}✗${NC} Invalid key format: $key" >&2
        return 1
    fi

    _ensure_config_dirs

    # Auto-detect port from package.json
    local port=""
    local package_json="${path}/package.json"
    if [[ -f "$package_json" ]]; then
        # Try to extract port from scripts.dev (e.g., "dev": "next dev -p 3500")
        port=$(grep -oP '(?<=-p\s)\d+' "$package_json" 2>/dev/null | head -1)
        # If not found, try VITE/Astro style (e.g., --port 3500)
        if [[ -z "$port" ]]; then
            port=$(grep -oP '(?<=--port\s)\d+' "$package_json" 2>/dev/null | head -1)
        fi
    fi

    # Auto-assign color from palette based on project count
    local project_count
    project_count=$(count_projects)
    local palette_index=$((project_count % ${#COLOR_PALETTE[@]}))
    local color_entry="${COLOR_PALETTE[$palette_index]}"
    local active_color inactive_color
    IFS='|' read -r active_color inactive_color _ _ <<< "$color_entry"

    # Generate display name (uppercase key)
    local name="${key^^}"

    # Database env var (assume DATABASE_URL if package.json exists with db-related deps)
    local db_var=""
    if [[ -f "$package_json" ]]; then
        if grep -qE '"(prisma|@prisma/client|drizzle|pg|postgres|supabase)"' "$package_json" 2>/dev/null; then
            db_var="DATABASE_URL"
        fi
    fi

    # Create config file with header if it doesn't exist
    if [[ ! -f "$PROJECTS_CONFIG" ]]; then
        cat > "$PROJECTS_CONFIG" << 'HEADER'
# Project Configuration for Jomarchy
# Format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR|SHORT_ALIAS
#
# KEY: lowercase identifier (used for j<key> and cc<key> aliases)
# NAME: display name (used in window titles, e.g., "CHIMARO:")
# PATH: project path (~ expanded)
# PORT: dev server port (empty if no server)
# DB_ENV_VAR: env var name for database URL (empty if none)
# ACTIVE_COLOR: hex color for active border (without #)
# INACTIVE_COLOR: hex color for inactive border
# SHORT_ALIAS: optional custom single letter for j<X>/cc<X> aliases
#              (first-come-first-served if not specified)

HEADER
    fi

    # Build config line (8 fields, last empty for auto short alias)
    local config_line="${key}|${name}|${path}|${port}|${db_var}|${active_color}|${inactive_color}|"

    # Append to config
    echo "$config_line" >> "$PROJECTS_CONFIG"

    # Display color swatch
    local color_display
    color_display=$(printf "\e[48;2;%d;%d;%dm  \e[0m" \
        "$((16#${active_color:0:2}))" "$((16#${active_color:2:2}))" "$((16#${active_color:4:2}))")

    echo -e "  ${GREEN}✓${NC} Added '$key' ${color_display} ${port:+(port: $port)}"

    return 0
}

# ============================================================================
# MIGRATION FUNCTIONS
# ============================================================================

# Import projects from existing PROJECT_CONFIG in .bashrc
# Converts old format to new projects.conf format
import_from_bashrc() {
    local bashrc="$HOME/.bashrc"

    echo -e "\n${BLUE}=== Import from .bashrc ===${NC}\n"

    # Step 1: Check if .bashrc exists
    if [[ ! -f "$bashrc" ]]; then
        echo -e "${RED}Error: ~/.bashrc not found${NC}"
        return 1
    fi

    # Step 2: Check if PROJECT_CONFIG exists in .bashrc
    if ! grep -q "^declare -A PROJECT_CONFIG" "$bashrc"; then
        echo -e "${YELLOW}No PROJECT_CONFIG found in ~/.bashrc${NC}"
        echo -e "${CYAN}Nothing to import.${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Found PROJECT_CONFIG in ~/.bashrc${NC}\n"

    # Step 3: Parse PROJECT_CONFIG entries
    # Old format: [key]="NAME|PATH|PORT|DATABASE_URL|rgb(active)|rgb(inactive)"
    # New format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR

    local temp_config
    temp_config=$(mktemp)

    # Add header
    cat > "$temp_config" << 'HEADER'
# Jomarchy Project Configuration
# Format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR
# Migrated from ~/.bashrc PROJECT_CONFIG
#
# Colors are hex without # (e.g., ff5555 for red)
# Leave PORT or DB_ENV_VAR empty if not needed

HEADER

    local import_count=0
    local skipped_count=0

    echo -e "${CYAN}Parsing projects...${NC}\n"

    # Extract and convert each project entry
    # Match lines like: [chimaro]="CHIMARO|~/code/chimaro|3500|postgres://...|rgb(00d4aa)|rgb(00a080)"
    while IFS= read -r line; do
        # Skip if line doesn't match project entry pattern
        [[ ! "$line" =~ ^\[([a-z0-9_-]+)\]=\"(.*)\"$ ]] && continue

        local key="${BASH_REMATCH[1]}"
        local value="${BASH_REMATCH[2]}"

        # Parse the pipe-delimited value
        # Format: NAME|PATH|PORT|DATABASE_URL|rgb(active)|rgb(inactive)
        IFS='|' read -r name path port db_url active_rgb inactive_rgb <<< "$value"

        # Extract hex colors from rgb() format
        local active_color inactive_color

        if [[ "$active_rgb" =~ rgb\(([0-9a-fA-F]{6})\) ]]; then
            active_color="${BASH_REMATCH[1],,}"  # lowercase
        else
            active_color="5588ff"  # default blue
        fi

        if [[ "$inactive_rgb" =~ rgb\(([0-9a-fA-F]{6})\) ]]; then
            inactive_color="${BASH_REMATCH[1],,}"  # lowercase
        else
            inactive_color="3366dd"  # default dark blue
        fi

        # Determine DB env var name
        # If there's a database URL, use DATABASE_URL as the env var name
        # (Actual URLs should be stored in secrets.env, not the config)
        local db_var=""
        if [[ -n "$db_url" && "$db_url" != "postgresql://"* && "$db_url" != "postgres://"* ]]; then
            # It's already an env var name
            db_var="$db_url"
        elif [[ -n "$db_url" ]]; then
            # It's a URL - we'll use DATABASE_URL as the env var
            db_var="DATABASE_URL"
        fi

        # Build new format line
        local new_line="${key}|${name}|${path}|${port}|${db_var}|${active_color}|${inactive_color}"

        echo "$new_line" >> "$temp_config"

        # Display what we're importing
        printf "  ${GREEN}✓${NC} %-12s %-12s %s\n" "$key" "$name" "$path"
        ((import_count++))

    done < <(grep -E '^\s*\[[a-z0-9_-]+\]="' "$bashrc" | sed 's/^[[:space:]]*//')

    echo -e "\n${GREEN}Parsed $import_count project(s)${NC}"

    if [[ $import_count -eq 0 ]]; then
        echo -e "${YELLOW}No valid project entries found to import.${NC}"
        rm -f "$temp_config"
        return 1
    fi

    # Step 4: Preview the conversion
    echo -e "\n${CYAN}Preview of converted config:${NC}\n"
    echo "─────────────────────────────────────────────────────────────────"
    cat "$temp_config"
    echo "─────────────────────────────────────────────────────────────────"

    # Step 5: Confirm import
    if ! gum confirm "Import these $import_count projects to ~/.config/jomarchy/projects.conf?"; then
        echo -e "${YELLOW}Import cancelled.${NC}"
        rm -f "$temp_config"
        return 1
    fi

    # Step 6: Create backup if config already exists
    _ensure_config_dirs
    if [[ -f "$PROJECTS_CONFIG" ]]; then
        local backup="${PROJECTS_CONFIG}.bak.$(date +%s)"
        cp "$PROJECTS_CONFIG" "$backup"
        echo -e "${CYAN}Backed up existing config to: $backup${NC}"
    fi

    # Step 7: Move new config into place
    mv "$temp_config" "$PROJECTS_CONFIG"
    echo -e "${GREEN}✓ Imported $import_count projects to $PROJECTS_CONFIG${NC}"

    # Step 8: Offer to comment out old .bashrc config
    echo -e ""
    if gum confirm "Comment out the old PROJECT_CONFIG in ~/.bashrc?"; then
        _comment_out_old_bashrc_config
    else
        echo -e "${YELLOW}Old config left in ~/.bashrc (you may want to remove it manually)${NC}"
    fi

    # Step 9: Check for database URLs that need to be moved to secrets
    local has_db_urls=false
    while IFS= read -r line; do
        [[ ! "$line" =~ ^\[([a-z0-9_-]+)\]=\"(.*)\"$ ]] && continue
        local value="${BASH_REMATCH[2]}"
        IFS='|' read -r _ _ _ db_url _ _ <<< "$value"
        if [[ "$db_url" =~ ^postgres(ql)?:// ]]; then
            has_db_urls=true
            break
        fi
    done < <(grep -E '^\s*\[[a-z0-9_-]+\]="' "$bashrc")

    if [[ "$has_db_urls" == "true" ]]; then
        echo -e "\n${YELLOW}⚠  Your old config contained database URLs.${NC}"
        echo -e "${YELLOW}   These should be moved to: ~/.config/jomarchy/secrets.env${NC}"
        echo -e "${YELLOW}   Example: DATABASE_URL=\"postgresql://...\"${NC}"
        echo -e "${CYAN}   Projects will use the DATABASE_URL env var instead.${NC}"
    fi

    # Step 10: Regenerate
    echo -e ""
    if gum confirm "Regenerate bash functions and Hyprland rules now?"; then
        regenerate_all
    else
        echo -e "${YELLOW}Remember to run 'Regenerate All' to apply the imported projects.${NC}"
    fi

    echo -e "\n${GREEN}✓ Migration complete!${NC}"
}

# Helper function to comment out old PROJECT_CONFIG in .bashrc
_comment_out_old_bashrc_config() {
    local bashrc="$HOME/.bashrc"
    local backup="${bashrc}.bak.$(date +%s)"

    # Create backup
    cp "$bashrc" "$backup"
    echo -e "${CYAN}Backed up ~/.bashrc to: $backup${NC}"

    # Find start and end of PROJECT_CONFIG block
    # We need to comment out from "declare -A PROJECT_CONFIG" to the closing ")"

    local temp_bashrc
    temp_bashrc=$(mktemp)

    local in_config_block=false
    local commented_lines=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^declare\ -A\ PROJECT_CONFIG ]]; then
            # Start of config block
            in_config_block=true
            echo "# [MIGRATED TO jomarchy] $line" >> "$temp_bashrc"
            ((commented_lines++))
        elif [[ "$in_config_block" == "true" ]]; then
            # Inside config block
            echo "# [MIGRATED TO jomarchy] $line" >> "$temp_bashrc"
            ((commented_lines++))

            # Check if this is the closing parenthesis
            if [[ "$line" =~ ^\) ]]; then
                in_config_block=false
            fi
        else
            # Outside config block - keep as is
            echo "$line" >> "$temp_bashrc"
        fi
    done < "$bashrc"

    # Replace original
    mv "$temp_bashrc" "$bashrc"

    echo -e "${GREEN}✓ Commented out $commented_lines lines in ~/.bashrc${NC}"
    echo -e "${CYAN}Lines marked with '# [MIGRATED TO jomarchy]' can be safely deleted later.${NC}"
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
                add_project
                ;;
            "Edit Project")
                edit_project
                ;;
            "Remove Project")
                remove_project
                ;;
            "Regenerate All")
                regenerate_all
                ;;
            "Import from .bashrc")
                import_from_bashrc
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
