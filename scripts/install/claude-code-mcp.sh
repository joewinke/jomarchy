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

echo -e "${BLUE}→${NC} Configuring Claude Code MCP servers..."

# Create .claude directory if it doesn't exist
mkdir -p ~/.claude

# Check if mcp.json already exists
if [ -f ~/.claude/mcp.json ]; then
    echo -e "${YELLOW}→${NC} Existing mcp.json found, backing up..."
    cp ~/.claude/mcp.json ~/.claude/mcp.json.backup.$(date +%s)
    echo -e "${GREEN}✓${NC} Backup created"
fi

# Create or update mcp.json with Chrome DevTools MCP
cat > ~/.claude/mcp.json << 'EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"]
    }
  }
}
EOF

echo -e "${GREEN}✓${NC} Claude Code MCP configuration created at ~/.claude/mcp.json"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}MCP Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Configured MCP servers:"
echo "  • Chrome DevTools MCP - Browser automation and debugging"
echo ""
echo "To use:"
echo "  1. Restart any running Claude Code instances"
echo "  2. MCP tools will be available in Claude Code sessions"
echo ""
echo "To add more MCP servers:"
echo "  Edit ~/.claude/mcp.json and add to the mcpServers object"
echo ""
