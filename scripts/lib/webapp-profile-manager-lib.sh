# WebApp Profile Manager Library for Jomarchy
# Manage Chrome profile assignments for web applications
# This is a library file meant to be sourced, not executed directly
# Assumes common.sh has been sourced for color variables

readonly APPS_DIR="$HOME/.local/share/applications"
readonly CHROME_CONFIG="$HOME/.config/chromium/Local State"

# Function to get Chrome profile mappings
get_profiles() {
    if [[ -f "$CHROME_CONFIG" ]]; then
        jq -r '.profile.info_cache | to_entries[] | "\(.key)|\(.value.name)"' "$CHROME_CONFIG" 2>/dev/null || echo "Default|Default Profile"
    else
        echo "Default|Default Profile"
    fi
}

# Function to get detailed Chrome profile information
get_detailed_profiles() {
    if [[ -f "$CHROME_CONFIG" ]]; then
        jq -r '.profile.info_cache | to_entries[] | "\(.key)|\(.value.name)|\(.value.user_name // "")|\(.value.is_supervised // false)|\(.value.managed_user_id // "")"' "$CHROME_CONFIG" 2>/dev/null
    fi
}

# Function to count apps per profile
count_apps_per_profile() {
    get_web_apps | cut -d'|' -f2 | sort | uniq -c | while read -r count profile; do
        echo "$profile|$count"
    done
}

# Function to show Chrome profile overview
show_profile_overview() {
    echo -e "\n${BLUE}=== Chrome Profile Overview ===${NC}\n"

    # Get profile counts using a temp variable to avoid process substitution issues
    declare -A app_counts
    local count_output
    count_output=$(count_apps_per_profile)

    while IFS='|' read -r profile count; do
        [[ -z "$profile" ]] && continue
        app_counts["$profile"]="$count"
    done <<< "$count_output"
    
    # Show detailed profile info
    local profiles
    mapfile -t profiles < <(get_detailed_profiles)
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No Chrome profiles found${NC}"
        return
    fi
    
    printf "%-15s %-20s %-10s %s\n" "Profile Key" "Display Name" "Web Apps" "Status"
    printf "%-15s %-20s %-10s %s\n" "-----------" "------------" "---------" "------"
    
    for profile_info in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name user_name is_supervised managed_id <<< "$profile_info"
        local app_count="${app_counts[$profile_key]:-0}"
        local status="Active"
        
        # Check if profile directory exists
        local profile_dir
        if [[ "$profile_key" == "Default" ]]; then
            profile_dir="$HOME/.config/chromium/Default"
        else
            profile_dir="$HOME/.config/chromium/$profile_key"
        fi
        
        if [[ ! -d "$profile_dir" ]]; then
            status="${RED}Missing${NC}"
        elif [[ "$is_supervised" == "true" ]]; then
            status="${YELLOW}Supervised${NC}"
        fi
        
        printf "%-15s %-20s %-10s %s\n" "$profile_key" "$profile_name" "$app_count" "$status"
    done
    
    echo
}

# Function to get web apps and their current profiles
get_web_apps() {
    # Find all web apps (both chromium --app and omarchy-launch-webapp)
    find "$APPS_DIR" -name "*.desktop" 2>/dev/null | while read -r desktop_file; do
        local exec_line
        exec_line=$(grep "^Exec=" "$desktop_file" 2>/dev/null)

        # Skip if not a web app
        if [[ ! "$exec_line" =~ (chromium.*--app|omarchy-launch-webapp) ]]; then
            continue
        fi

        local app_name
        local current_profile="Default"
        local url=""

        app_name=$(basename "$desktop_file" .desktop)

        # Extract current profile if specified (only for direct chromium calls)
        if grep -q "profile-directory" "$desktop_file"; then
            current_profile=$(echo "$exec_line" | sed -n 's/.*--profile-directory="\([^"]*\)".*/\1/p')
        fi

        # Extract URL
        if [[ "$exec_line" =~ chromium.*--app ]]; then
            # Direct chromium call
            url=$(echo "$exec_line" | sed -n 's/.*--app="\([^"]*\)".*/\1/p')
        elif [[ "$exec_line" =~ omarchy-launch-webapp ]]; then
            # omarchy-launch-webapp call
            url=$(echo "$exec_line" | sed -n 's/.*omarchy-launch-webapp[[:space:]]*"\?\([^"[:space:]]*\)"\?.*/\1/p')
        fi

        echo "$app_name|$current_profile|$url|$desktop_file"
    done | sort
}

# Function to display current assignments
show_current_assignments() {
    show_profile_overview

    echo -e "${CYAN}Web App Profile Assignments:${NC}\n"

    local profiles
    mapfile -t profiles < <(get_profiles)

    # Create profile lookup
    declare -A profile_names
    for profile in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name <<< "$profile"
        profile_names["$profile_key"]="$profile_name"
    done

    # Use here-string instead of pipe to avoid subshell
    local web_apps_output
    web_apps_output=$(get_web_apps)

    while IFS='|' read -r app_name current_profile url desktop_file; do
        [[ -z "$app_name" ]] && continue
        local display_profile="${profile_names[$current_profile]:-$current_profile}"
        printf "%-25s -> %-18s (%s)\n" "$app_name" "$display_profile" "$current_profile"
    done <<< "$web_apps_output"

    echo
}

# Function to change profile for a web app
change_app_profile() {
    local app_choice="$1"
    local new_profile="$2"

    # Find the desktop file
    local desktop_file
    desktop_file=$(find "$APPS_DIR" -name "${app_choice}.desktop" | head -1)

    if [[ ! -f "$desktop_file" ]]; then
        echo -e "${RED}Error: Desktop file not found for $app_choice${NC}"
        return 1
    fi

    # Backup original
    cp "$desktop_file" "${desktop_file}.backup"

    # Read current content
    local exec_line
    exec_line=$(grep "^Exec=" "$desktop_file")

    local new_exec_line

    # Check if it's using omarchy-launch-webapp
    if [[ "$exec_line" =~ omarchy-launch-webapp ]]; then
        # Extract the URL
        local url
        url=$(echo "$exec_line" | sed -n 's/.*omarchy-launch-webapp[[:space:]]*"\?\([^"[:space:]]*\)"\?.*/\1/p')

        # Convert to direct chromium call
        if [[ "$new_profile" != "Default" ]]; then
            new_exec_line="Exec=chromium --profile-directory=\"$new_profile\" --new-window --ozone-platform=wayland --app=\"$url\" --name=\"$app_choice\" --class=\"$app_choice\""
        else
            new_exec_line="Exec=chromium --new-window --ozone-platform=wayland --app=\"$url\" --name=\"$app_choice\" --class=\"$app_choice\""
        fi
    else
        # Already using direct chromium call
        # Remove existing profile-directory if present
        new_exec_line=$(echo "$exec_line" | sed 's/--profile-directory="[^"]*" *//g')

        # Add new profile if not Default
        if [[ "$new_profile" != "Default" ]]; then
            # Insert profile directory after chromium
            new_exec_line=$(echo "$new_exec_line" | sed "s|chromium |chromium --profile-directory=\"$new_profile\" |")
        fi
    fi

    # Update the desktop file
    sed -i "s|^Exec=.*|$new_exec_line|" "$desktop_file"

    echo -e "${GREEN}✓ Updated $app_choice to use profile: $new_profile${NC}"
}

# Function to select and change profile for an app
interactive_change_profile() {
    local web_apps
    mapfile -t web_apps < <(get_web_apps)
    
    if [[ ${#web_apps[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No web apps found.${NC}"
        return
    fi
    
    # Create app choices for gum
    local app_choices=()
    for app in "${web_apps[@]}"; do
        IFS='|' read -r app_name current_profile url _ <<< "$app"
        app_choices+=("$app_name (currently: $current_profile)")
    done
    
    # Select app
    local selected_app
    selected_app=$(printf '%s\n' "${app_choices[@]}" | gum choose --header="Select web app to modify:")
    
    if [[ -z "$selected_app" ]]; then
        return
    fi
    
    # Extract app name
    local app_name
    app_name=$(echo "$selected_app" | sed 's/ (currently:.*//')
    
    # Get profile choices
    local profiles
    mapfile -t profiles < <(get_profiles)
    
    local profile_choices=()
    for profile in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name <<< "$profile"
        profile_choices+=("$profile_name ($profile_key)")
    done
    
    # Select profile
    local selected_profile
    selected_profile=$(printf '%s\n' "${profile_choices[@]}" | gum choose --header="Select Chrome profile for $app_name:")
    
    if [[ -z "$selected_profile" ]]; then
        return
    fi
    
    # Extract profile key
    local profile_key
    profile_key=$(echo "$selected_profile" | sed 's/.*(\([^)]*\)).*/\1/')
    
    # Change the profile
    change_app_profile "$app_name" "$profile_key"
}

# Function to bulk assign profiles
bulk_assign_profiles() {
    local profiles
    mapfile -t profiles < <(get_profiles)
    
    local profile_choices=()
    for profile in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name <<< "$profile"
        profile_choices+=("$profile_name ($profile_key)")
    done
    
    # Select target profile
    local selected_profile
    selected_profile=$(printf '%s\n' "${profile_choices[@]}" | gum choose --header="Select target Chrome profile:")
    
    if [[ -z "$selected_profile" ]]; then
        return
    fi
    
    local profile_key
    profile_key=$(echo "$selected_profile" | sed 's/.*(\([^)]*\)).*/\1/')
    
    # Select multiple apps
    local web_apps
    mapfile -t web_apps < <(get_web_apps)
    
    local app_choices=()
    for app in "${web_apps[@]}"; do
        IFS='|' read -r app_name current_profile _ _ <<< "$app"
        app_choices+=("$app_name (currently: $current_profile)")
    done
    
    # Multi-select apps
    local selected_apps
    mapfile -t selected_apps < <(printf '%s\n' "${app_choices[@]}" | gum choose --no-limit --header="Select web apps to assign to $selected_profile:")
    
    if [[ ${#selected_apps[@]} -eq 0 ]]; then
        return
    fi
    
    # Confirm bulk operation
    echo -e "\n${YELLOW}About to assign ${#selected_apps[@]} apps to profile: $selected_profile${NC}"
    if ! gum confirm "Proceed with bulk assignment?"; then
        return
    fi
    
    # Apply changes
    for selected_app in "${selected_apps[@]}"; do
        local app_name
        app_name=$(echo "$selected_app" | sed 's/ (currently:.*//')
        change_app_profile "$app_name" "$profile_key"
    done
    
    echo -e "\n${GREEN}✓ Bulk assignment completed!${NC}"
}

# Function to rename a Chrome profile
rename_chrome_profile() {
    local profiles
    mapfile -t profiles < <(get_detailed_profiles)
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No Chrome profiles found${NC}"
        return
    fi
    
    # Let user select a profile to rename
    local profile_choices=()
    for profile_info in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name _ _ _ <<< "$profile_info"
        profile_choices+=("$profile_name ($profile_key)")
    done
    
    local selected
    selected=$(printf '%s\n' "${profile_choices[@]}" | gum choose --header="Select profile to rename:")
    
    if [[ -z "$selected" ]]; then
        return
    fi
    
    local selected_key selected_name
    selected_key=$(echo "$selected" | sed 's/.*(//' | sed 's/)//')
    selected_name=$(echo "$selected" | sed 's/ (.*)//')
    
    # Get new name
    local new_name
    new_name=$(gum input --header="Enter new name for profile '$selected_name':" --placeholder="$selected_name")
    
    if [[ -z "$new_name" ]]; then
        echo -e "${YELLOW}No name provided, cancelling rename${NC}"
        return
    fi
    
    if [[ "$new_name" == "$selected_name" ]]; then
        echo -e "${YELLOW}Name unchanged${NC}"
        return
    fi
    
    # Validate new name doesn't conflict
    for profile_info in "${profiles[@]}"; do
        IFS='|' read -r _ existing_name _ _ _ <<< "$profile_info"
        if [[ "$existing_name" == "$new_name" ]]; then
            echo -e "${RED}Error: Profile name '$new_name' already exists${NC}"
            return
        fi
    done
    
    # Confirm the rename
    if ! gum confirm "Rename profile '$selected_name' to '$new_name'?"; then
        return
    fi
    
    # Close Chrome before modifying (warn user)
    echo -e "\n${YELLOW}WARNING: Chrome/Chromium should be closed before renaming profiles.${NC}"
    if ! gum confirm "Is Chrome/Chromium closed?"; then
        echo -e "${YELLOW}Please close Chrome/Chromium and try again${NC}"
        return
    fi
    
    # Backup the config file
    local backup_file="$CHROME_CONFIG.backup.$(date +%s)"
    if ! cp "$CHROME_CONFIG" "$backup_file"; then
        echo -e "${RED}Error: Could not create backup of Chrome config${NC}"
        return
    fi
    
    echo -e "${CYAN}Created backup: $backup_file${NC}"
    
    # Update the profile name using jq
    local temp_file
    temp_file=$(mktemp)
    
    if jq ".profile.info_cache.\"$selected_key\".name = \"$new_name\"" "$CHROME_CONFIG" > "$temp_file"; then
        if mv "$temp_file" "$CHROME_CONFIG"; then
            echo -e "${GREEN}✓ Successfully renamed profile '$selected_name' to '$new_name'${NC}"
            echo -e "${CYAN}Note: Changes will appear when you restart Chrome/Chromium${NC}"
        else
            echo -e "${RED}Error: Could not update Chrome config file${NC}"
            echo -e "${YELLOW}Restoring from backup...${NC}"
            cp "$backup_file" "$CHROME_CONFIG"
        fi
    else
        echo -e "${RED}Error: JSON processing failed${NC}"
        echo -e "${YELLOW}Restoring from backup...${NC}"
        cp "$backup_file" "$CHROME_CONFIG"
    fi
    
    # Cleanup temp file
    [[ -f "$temp_file" ]] && rm -f "$temp_file"
}

# Function to manage Chrome profiles
manage_chrome_profiles() {
    while true; do
        echo -e "\n${BLUE}=== Chrome Profile Management ===${NC}"
        
        local choice
        choice=$(echo -e "View Profile Details\nList Apps by Profile\nRename Profile\nCreate New Profile (Manual)\nBack to Main Menu" | gum choose --header="Chrome Profile Options:")
        
        case "$choice" in
            "View Profile Details")
                show_profile_details
                ;;
            "List Apps by Profile")
                list_apps_by_profile
                ;;
            "Rename Profile")
                rename_chrome_profile
                ;;
            "Create New Profile (Manual)")
                show_create_profile_instructions
                ;;
            "Back to Main Menu")
                return
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                ;;
        esac
    done
}

# Function to show detailed profile information
show_profile_details() {
    local profiles
    mapfile -t profiles < <(get_detailed_profiles)
    
    if [[ ${#profiles[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No Chrome profiles found${NC}"
        return
    fi
    
    # Let user select a profile
    local profile_choices=()
    for profile_info in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name _ _ _ <<< "$profile_info"
        profile_choices+=("$profile_name ($profile_key)")
    done
    
    local selected
    selected=$(printf '%s\n' "${profile_choices[@]}" | gum choose --header="Select profile to view details:")
    
    if [[ -z "$selected" ]]; then
        return
    fi
    
    local selected_key
    selected_key=$(echo "$selected" | sed 's/.*(//' | sed 's/)//')
    
    # Find and display profile details
    for profile_info in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name user_name is_supervised managed_id <<< "$profile_info"
        if [[ "$profile_key" == "$selected_key" ]]; then
            echo -e "\n${CYAN}Profile Details: $profile_name${NC}\n"
            echo -e "Profile Key:     $profile_key"
            echo -e "Display Name:    $profile_name"
            echo -e "User Name:       ${user_name:-"(not set)"}"
            echo -e "Supervised:      $is_supervised"
            
            # Show directory info
            local profile_dir
            if [[ "$profile_key" == "Default" ]]; then
                profile_dir="$HOME/.config/chromium/Default"
            else
                profile_dir="$HOME/.config/chromium/$profile_key"
            fi
            
            if [[ -d "$profile_dir" ]]; then
                local dir_size
                dir_size=$(du -sh "$profile_dir" 2>/dev/null | cut -f1)
                echo -e "Directory:       $profile_dir ($dir_size)"
            else
                echo -e "Directory:       ${RED}$profile_dir (missing)${NC}"
            fi
            
            # Show apps using this profile
            echo -e "\nWeb Apps using this profile:"
            local web_apps_output app_count=0
            web_apps_output=$(get_web_apps)

            while IFS='|' read -r app_name current_profile _ _; do
                [[ -z "$app_name" ]] && continue
                if [[ "$current_profile" == "$profile_key" ]]; then
                    echo -e "  • $app_name"
                    ((app_count++))
                fi
            done <<< "$web_apps_output"

            if [[ $app_count -eq 0 ]]; then
                echo -e "  ${YELLOW}(no web apps assigned)${NC}"
            fi
            
            break
        fi
    done
    
    echo
}

# Function to list apps grouped by profile
list_apps_by_profile() {
    echo -e "\n${CYAN}Web Apps Grouped by Profile:${NC}\n"
    
    local profiles
    mapfile -t profiles < <(get_profiles)
    
    # Create profile lookup
    declare -A profile_names
    for profile in "${profiles[@]}"; do
        IFS='|' read -r profile_key profile_name <<< "$profile"
        profile_names["$profile_key"]="$profile_name"
    done
    
    # Sort apps by profile and group during output
    local last_profile="" web_apps_output
    web_apps_output=$(get_web_apps | sort -t'|' -k2)

    while IFS='|' read -r app_name current_profile _ _; do
        [[ -z "$app_name" ]] && continue
        if [[ "$current_profile" != "$last_profile" ]]; then
            if [[ -n "$last_profile" ]]; then
                echo
            fi
            local display_name="${profile_names[$current_profile]:-$current_profile}"
            echo -e "${YELLOW}$display_name ($current_profile):${NC}"
            last_profile="$current_profile"
        fi
        echo -e "  • $app_name"
    done <<< "$web_apps_output"

    echo
}

# Function to show instructions for creating a new profile
show_create_profile_instructions() {
    echo -e "\n${CYAN}Creating a New Chrome Profile:${NC}\n"
    echo -e "Chrome profiles must be created from within Chrome itself."
    echo -e "\n${YELLOW}Steps:${NC}"
    echo -e "1. Open Chrome/Chromium"
    echo -e "2. Click your profile icon (top-right corner)"
    echo -e "3. Select 'Add' or 'Manage profiles'"
    echo -e "4. Click 'Add profile'"
    echo -e "5. Choose a name and avatar"
    echo -e "6. Restart this tool to see the new profile"
    echo -e "\n${GREEN}Tip:${NC} You can also run: ${CYAN}chromium --profile-directory=\"New Profile Name\"${NC}"
    echo -e "to create and switch to a new profile directly."
    echo
}

# Main menu
main_menu() {
    while true; do
        echo -e "\n${BLUE}=== WebApp Profile Manager ===${NC}"
        
        local choice
        choice=$(echo -e "View Current Assignments\nChange Single App Profile\nBulk Assign Profiles\nManage Chrome Profiles\nRefresh Applications\nExit" | gum choose --header="What would you like to do?")
        
        case "$choice" in
            "View Current Assignments")
                show_current_assignments
                ;;
            "Change Single App Profile")
                interactive_change_profile
                ;;
            "Bulk Assign Profiles")
                bulk_assign_profiles
                ;;
            "Manage Chrome Profiles")
                manage_chrome_profiles
                ;;
            "Refresh Applications")
                echo -e "${CYAN}Refreshing application database...${NC}"
                update-desktop-database ~/.local/share/applications
                echo -e "${GREEN}✓ Applications refreshed${NC}"
                ;;
            "Exit")
                echo -e "\n${GREEN}Thanks for using WebApp Profile Manager!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                ;;
        esac
    done
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for cmd in gum jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "Install with: ${CYAN}sudo pacman -S ${missing_deps[*]}${NC}"
        exit 1
    fi
}

# Main entry point for webapp profile manager
# Call this function from jomarchy.sh
webapp_profile_manager_run() {
    check_dependencies
    main_menu
}