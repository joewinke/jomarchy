#!/bin/bash

# Claude Code MCP Configuration
# Configures Model Context Protocol servers for Claude Code

set -e  # Exit on error

echo "========================================"
echo "Claude Code MCP Configuration"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if npx is available (comes with Node.js)
if ! command -v npx &> /dev/null; then
    echo -e "${YELLOW}WARNING: npx not found${NC}"
    echo "Node.js should be installed first (from essential-packages.sh)"
    echo "MCP configuration will be created, but may not work until Node.js is installed."
    echo ""
fi

echo -e "${BLUE}→${NC} Configuring Claude Code MCP servers for all projects..."
echo ""

# MCP configuration template
MCP_CONFIG='{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--browserUrl=http://127.0.0.1:9222"
      ]
    }
  }
}'

# Add MCP config to all existing projects in ~/code
if [ -d "$HOME/code" ]; then
    echo -e "${BLUE}→${NC} Adding MCP config to existing projects in ~/code..."
    echo ""

    projects_updated=0
    projects_skipped=0

    for project_dir in "$HOME/code"/*/ ; do
        # Remove trailing slash
        project_dir="${project_dir%/}"
        project_name=$(basename "$project_dir")

        # Skip if not a directory
        [ ! -d "$project_dir" ] && continue

        mcp_file="$project_dir/mcp.json"

        if [ -f "$mcp_file" ]; then
            # Check if chrome-devtools is already configured
            if grep -q "chrome-devtools" "$mcp_file"; then
                echo -e "${GREEN}✓${NC} $project_name (chrome-devtools already configured)"
                projects_skipped=$((projects_skipped + 1))
            else
                # Backup existing config
                cp "$mcp_file" "$mcp_file.backup.$(date +%s)"

                # Merge chrome-devtools into existing config
                # For simplicity, we'll add it to the mcpServers object
                if command -v jq &> /dev/null; then
                    jq '.mcpServers["chrome-devtools"] = {"command": "npx", "args": ["-y", "chrome-devtools-mcp@latest", "--browserUrl=http://127.0.0.1:9222"]}' "$mcp_file" > "$mcp_file.tmp"
                    mv "$mcp_file.tmp" "$mcp_file"
                    echo -e "${GREEN}✓${NC} $project_name (chrome-devtools added to existing config)"
                    projects_updated=$((projects_updated + 1))
                else
                    echo -e "${YELLOW}→${NC} $project_name (jq not available, skipping merge)"
                    projects_skipped=$((projects_skipped + 1))
                fi
            fi
        else
            # Create new mcp.json
            echo "$MCP_CONFIG" > "$mcp_file"
            echo -e "${GREEN}✓${NC} $project_name (new mcp.json created)"
            projects_updated=$((projects_updated + 1))
        fi

        # Create MCP help file if it doesn't exist
        help_file="$project_dir/.mcp-config-help.md"
        if [ ! -f "$help_file" ]; then
            cat > "$help_file" << 'MCPHELPEOF'
# MCP Server Configuration

This project has MCP (Model Context Protocol) servers configured for Claude Code.

## Currently Enabled

- **chrome-devtools** - Browser automation and debugging

## Available MCP Servers

### Supabase MCP
Interact with your Supabase database directly from Claude Code.

**Quick Setup (Recommended):**
```bash
cd ~/code/YOUR_PROJECT
supabase-mcp-config
```

The interactive helper will prompt for your credentials and configure everything automatically.

**Manual Setup:**
Edit `mcp.json` and add:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@latest",
        "--browserUrl=http://127.0.0.1:9222"
      ]
    },
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--url",
        "https://YOUR_PROJECT_REF.supabase.co",
        "--service-role-key",
        "YOUR_SERVICE_ROLE_KEY"
      ]
    }
  }
}
```

**Get your credentials:**
1. Go to https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
2. Copy the Project URL
3. Copy the service_role key (keep this secret!)

### Other MCP Servers
- **Tavily** - Web search capabilities
- **Filesystem** - Direct file system access
- **GitHub** - GitHub API integration

See: https://github.com/modelcontextprotocol/servers
MCPHELPEOF
        fi
    done

    echo ""
    echo -e "${GREEN}✓${NC} Processed projects: $projects_updated updated, $projects_skipped skipped"
else
    echo -e "${YELLOW}→${NC} ~/code directory not found, skipping project configuration"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MCP Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Configured MCP servers:"
echo "  • Chrome DevTools MCP - Browser automation and debugging"
echo ""
echo "Projects configured:"
echo "  • All projects in ~/code now have mcp.json"
echo "  • New clones will automatically get mcp.json"
echo ""
echo "To use:"
echo "  1. Launch DevChrome MCP browser (devchrome-mcp command)"
echo "  2. Restart Claude Code in any project"
echo "  3. MCP tools will be available in Claude Code sessions"
echo ""
echo "To add more MCP servers to a project:"
echo "  Edit the project's mcp.json file and add to the mcpServers object"
echo ""
