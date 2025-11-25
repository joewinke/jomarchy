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

# Core project launcher
# $1: project key
# $2: mode (all|code|claude|npm)
_jat_launch() {
    local project="$1"
    local mode="${2:-all}"

    case "$project" in
CORE

        # Generate case entries for each project
        while IFS='|' read -r key name path port db_var active_color inactive_color; do
            [[ -z "$key" ]] && continue

            # Expand ~ in path
            local expanded_path="${path/#\~/$HOME}"

            cat << CASE_ENTRY
        ${key})
            _jat_set_style "${name}" "${active_color}" "${inactive_color}"
            cd "${expanded_path}" || return 1
            case "\$mode" in
                all)
                    code .
                    ${port:+npm run dev &}
                    claude
                    ;;
                code) code . ;;
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
        while IFS='|' read -r key name path port db_var active_color inactive_color; do
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

        # Generate help list
        while IFS='|' read -r key name path port db_var active_color inactive_color; do
            [[ -z "$key" ]] && continue
            echo "    printf \"  %-8s %-12s %s\\n\" \"j${key}\" \"(${name})\" \"${path}\""
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

        # Generate aliases
        while IFS='|' read -r key name path port db_var active_color inactive_color; do
            [[ -z "$key" ]] && continue
            echo "# ${name}"
            echo "j${key}() { _jat_launch \"${key}\" \"\${1:-all}\"; }"
            echo "cc${key}() { _jat_claude \"${key}\"; }"
        done < <(get_projects)

    } > "$GENERATED_BASH"

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

    # Step 5: Confirm
    echo -e "\n${BLUE}=== New Project Summary ===${NC}"
    echo -e "  Key:      ${GREEN}$key${NC}"
    echo -e "  Name:     ${GREEN}$name${NC}"
    echo -e "  Path:     ${GREEN}$path${NC}"
    echo -e "  Port:     ${GREEN}${port:-─}${NC}"
    echo -e "  DB Var:   ${GREEN}${db_var:-─}${NC}"
    printf "  Colors:   Active: \e[48;2;%d;%d;%dm    \e[0m  Inactive: \e[48;2;%d;%d;%dm    \e[0m\n" \
        "$((16#${active_color:0:2}))" "$((16#${active_color:2:2}))" "$((16#${active_color:4:2}))" \
        "$((16#${inactive_color:0:2}))" "$((16#${inactive_color:2:2}))" "$((16#${inactive_color:4:2}))"

    if ! gum confirm "Add this project?"; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return 1
    fi

    # Step 6: Save to config
    local config_line="${key}|${name}|${path}|${port}|${db_var}|${active_color}|${inactive_color}"

    # Create config file with header if it doesn't exist
    if [[ ! -f "$PROJECTS_CONFIG" ]]; then
        cat > "$PROJECTS_CONFIG" << 'HEADER'
# Jomarchy Project Configuration
# Format: KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR
# Example: chimaro|CHIMARO|~/code/chimaro|3500|DATABASE_URL|00d4aa|00a080
#
# Colors are hex without # (e.g., ff5555 for red)
# Leave PORT or DB_ENV_VAR empty if not needed

HEADER
    fi

    # Append project
    echo "$config_line" >> "$PROJECTS_CONFIG"

    echo -e "\n${GREEN}✓ Project '$key' added successfully!${NC}"

    # Step 7: Regenerate
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

    # Get current values
    local current_line
    current_line=$(get_project "$edit_key")

    local cur_key cur_name cur_path cur_port cur_db cur_active cur_inactive
    IFS='|' read -r cur_key cur_name cur_path cur_port cur_db cur_active cur_inactive <<< "$current_line"

    # Step 2: Select what to edit
    local edit_choice
    edit_choice=$(echo -e "Name ($cur_name)\nPath ($cur_path)\nPort (${cur_port:-none})\nDatabase var (${cur_db:-none})\nColors\nAll fields" | \
        gum choose --header="What would you like to edit?")

    [[ -z "$edit_choice" ]] && return 1

    local new_name="$cur_name"
    local new_path="$cur_path"
    local new_port="$cur_port"
    local new_db="$cur_db"
    local new_active="$cur_active"
    local new_inactive="$cur_inactive"

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

    if [[ "$changed" == "false" ]]; then
        echo -e "${YELLOW}No changes made.${NC}"
        return 0
    fi

    if ! gum confirm "Apply these changes?"; then
        echo -e "${YELLOW}Cancelled.${NC}"
        return 1
    fi

    # Step 4: Update config file
    local new_line="${edit_key}|${new_name}|${new_path}|${new_port}|${new_db}|${new_active}|${new_inactive}"

    # Use sed to replace the line (escape pipe in pattern since it's a delimiter)
    sed -i "s|^${edit_key}\\|.*$|${new_line}|" "$PROJECTS_CONFIG"

    echo -e "\n${GREEN}✓ Project '$edit_key' updated successfully!${NC}"

    # Step 5: Regenerate
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
