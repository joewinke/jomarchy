#!/bin/bash

# DevChrome MCP Installation Script
# Installs dedicated Chromium browser for Claude Code MCP debugging

set -e  # Exit on error

echo "========================================"
echo "DevChrome MCP Installation"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi

echo -e "${BLUE}→${NC} Installing DevChrome MCP..."
echo ""

# Check if Chromium is installed
if ! command -v chromium &> /dev/null; then
    echo -e "${YELLOW}WARNING: Chromium not found${NC}"
    echo -e "${BLUE}→${NC} Installing chromium..."
    if sudo pacman -S --noconfirm chromium; then
        echo -e "${GREEN}✓${NC} chromium installed successfully"
    else
        echo -e "${RED}✗${NC} chromium failed to install"
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} chromium (already installed)"
fi

# Create ~/.local/bin if it doesn't exist
mkdir -p ~/.local/bin

# 1. Install DevChrome MCP launcher script
echo -e "${BLUE}→${NC} Installing devchrome-mcp launcher script..."
cat > ~/.local/bin/devchrome-mcp << 'EOF'
#!/bin/bash
#
# DevChrome MCP - Chromium instance for Claude Code MCP debugging
# Launches Chromium with remote debugging enabled on port 9222
#

# Profile directory for this MCP instance
PROFILE_DIR="$HOME/.config/devchrome-mcp-profile"

# Create profile directory if it doesn't exist
mkdir -p "$PROFILE_DIR"

# Launch Chromium with MCP debugging flags
exec /usr/bin/chromium \
  --remote-debugging-port=9222 \
  --user-data-dir="$PROFILE_DIR" \
  --class="DevChrome-MCP" \
  --disable-features=PrivacySandboxSettings4 \
  --no-first-run \
  --no-default-browser-check \
  "$@"
EOF

chmod +x ~/.local/bin/devchrome-mcp
echo -e "${GREEN}✓${NC} devchrome-mcp launcher installed"

# 2. Create .desktop file for application launcher
echo -e "${BLUE}→${NC} Installing DevChrome MCP application launcher..."
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/devchrome-mcp.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=DevChrome MCP
Comment=Chromium with MCP remote debugging for Claude Code
Icon=chromium
Exec=/home/$USER/.local/bin/devchrome-mcp %U
Terminal=false
Categories=Development;WebBrowser;
StartupWMClass=DevChrome-MCP
Keywords=browser;web;debug;mcp;claude;development;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

# Fix $USER variable in .desktop file
sed -i "s|\$USER|$USER|g" ~/.local/share/applications/devchrome-mcp.desktop

echo -e "${GREEN}✓${NC} DevChrome MCP .desktop file installed"

# 3. Update desktop database
echo -e "${BLUE}→${NC} Updating desktop database..."
update-desktop-database ~/.local/share/applications 2>/dev/null || true
echo -e "${GREEN}✓${NC} Desktop database updated"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}DevChrome MCP Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "What was installed:"
echo "  ✓ devchrome-mcp - Launch script in ~/.local/bin"
echo "  ✓ DevChrome MCP - Application launcher"
echo "  ✓ Separate profile - ~/.config/devchrome-mcp-profile"
echo ""

echo "How to use:"
echo "  1. Launch from app menu: Search 'DevChrome MCP'"
echo "  2. Or from terminal: devchrome-mcp"
echo "  3. Or with URL: devchrome-mcp https://example.com"
echo ""

echo "Features:"
echo "  • Remote debugging on port 9222"
echo "  • Separate profile (won't affect your regular Chrome)"
echo "  • Claude Code MCP integration ready"
echo "  • Automatically connects to MCP server"
echo ""

echo "MCP Configuration:"
echo "  The MCP server should already be configured at:"
echo "  ~/.config/claude/mcp.json"
echo ""

echo "Test the connection:"
echo "  1. Launch DevChrome MCP"
echo "  2. Restart Claude Code"
echo "  3. Ask Claude to 'list all open tabs'"
echo ""
