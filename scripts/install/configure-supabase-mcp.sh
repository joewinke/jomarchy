#!/bin/bash

# Configure Supabase MCP for Claude Code
# Interactive script to add Supabase MCP server to a project's mcp.json

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "========================================"
echo "Configure Supabase MCP"
echo "========================================"
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}ERROR: jq is required but not installed${NC}"
    echo "Install with: sudo pacman -S jq"
    exit 1
fi

# Function to configure a single project
configure_project() {
    local project_dir="$1"
    local mcp_file="$project_dir/mcp.json"

    if [ ! -f "$mcp_file" ]; then
        echo -e "${RED}ERROR: No mcp.json found in $project_dir${NC}"
        echo "Run claude-code-mcp.sh first to initialize MCP configuration"
        return 1
    fi

    # Check if supabase is already configured
    if grep -q '"supabase"' "$mcp_file"; then
        echo -e "${YELLOW}Supabase MCP is already configured in this project${NC}"
        echo ""
        read -p "Do you want to update the configuration? (y/n): " update_choice
        if [[ ! "$update_choice" =~ ^[Yy]$ ]]; then
            echo "Skipping..."
            return 0
        fi
    fi

    echo ""
    echo -e "${CYAN}Enter your Supabase project details:${NC}"
    echo ""

    # Prompt for Supabase URL
    echo -e "${BLUE}1. Project URL${NC}"
    echo "   Example: https://abcdefgh.supabase.co"
    echo "   Find at: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api"
    echo ""
    read -p "Project URL: " supabase_url

    # Validate URL format
    if [[ ! "$supabase_url" =~ ^https://[a-z0-9]+\.supabase\.co$ ]]; then
        echo -e "${YELLOW}Warning: URL doesn't match expected format${NC}"
        read -p "Continue anyway? (y/n): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            echo "Cancelled"
            return 1
        fi
    fi

    echo ""
    echo -e "${BLUE}2. Service Role Key${NC}"
    echo "   Starts with: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    echo "   Find at: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api"
    echo "   ${RED}Keep this secret! Don't commit to git.${NC}"
    echo ""
    read -s -p "Service Role Key: " service_role_key
    echo ""

    # Validate key format (basic check)
    if [[ ! "$service_role_key" =~ ^eyJ ]]; then
        echo -e "${YELLOW}Warning: Key doesn't match expected format${NC}"
        read -p "Continue anyway? (y/n): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
            echo "Cancelled"
            return 1
        fi
    fi

    echo ""
    echo -e "${BLUE}→${NC} Configuring Supabase MCP..."

    # Backup existing config
    cp "$mcp_file" "$mcp_file.backup.$(date +%s)"
    echo -e "${GREEN}✓${NC} Backup created"

    # Add or update Supabase MCP configuration
    jq --arg url "$supabase_url" \
       --arg key "$service_role_key" \
       '.mcpServers.supabase = {
         "command": "npx",
         "args": [
           "-y",
           "@supabase/mcp-server-supabase@latest",
           "--url",
           $url,
           "--service-role-key",
           $key
         ]
       }' "$mcp_file" > "$mcp_file.tmp"

    mv "$mcp_file.tmp" "$mcp_file"
    echo -e "${GREEN}✓${NC} Supabase MCP configured"

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Configuration Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "What's next:"
    echo "  1. Restart Claude Code in this project"
    echo "  2. Supabase MCP tools will be available"
    echo "  3. ${RED}IMPORTANT:${NC} Add mcp.json to .gitignore if it contains secrets"
    echo ""
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments - configure current directory or show project selection
    if [ -f "mcp.json" ]; then
        project_name=$(basename "$PWD")
        echo -e "${BLUE}Configuring Supabase MCP for: ${project_name}${NC}"
        configure_project "$PWD"
    elif [ -d "$HOME/code" ]; then
        # Show project selection
        echo -e "${CYAN}Select a project to configure:${NC}"
        echo ""

        projects=()
        for dir in "$HOME/code"/*/ ; do
            if [ -f "${dir}mcp.json" ]; then
                projects+=("$(basename "$dir")")
            fi
        done

        if [ ${#projects[@]} -eq 0 ]; then
            echo -e "${RED}No projects with mcp.json found in ~/code${NC}"
            exit 1
        fi

        # Use gum if available, otherwise simple selection
        if command -v gum &> /dev/null; then
            selected_project=$(printf '%s\n' "${projects[@]}" | gum choose)
        else
            PS3="Enter project number: "
            select selected_project in "${projects[@]}"; do
                if [ -n "$selected_project" ]; then
                    break
                fi
            done
        fi

        if [ -n "$selected_project" ]; then
            echo ""
            configure_project "$HOME/code/$selected_project"
        else
            echo "No project selected"
            exit 1
        fi
    else
        echo -e "${RED}ERROR: Not in a project directory and ~/code not found${NC}"
        echo "Usage: $0 [project_path]"
        exit 1
    fi
elif [ $# -eq 1 ]; then
    # Argument provided - configure specific project
    configure_project "$1"
else
    echo "Usage: $0 [project_path]"
    echo ""
    echo "If no path is provided:"
    echo "  - Configures current directory if it has mcp.json"
    echo "  - Shows project selection from ~/code"
    exit 1
fi
