#!/bin/bash
# Install OpenCode - Alternative agentic coding CLI
# Part of Jomarchy Agentic Coding Setup

set -e

echo "=== Installing OpenCode ==="

# Check for Node.js installation
if ! command -v node &> /dev/null; then
    echo "✗ Node.js is not installed. Please install Node.js first."
    echo "  On Arch: sudo pacman -S nodejs npm"
    exit 1
fi

# Check Node version (requires >= 18)
NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "✗ OpenCode requires Node.js >= 18 (current: $(node -v))"
    echo "  Please upgrade Node.js"
    exit 1
fi

# Install OpenCode globally
echo "→ Installing OpenCode via npm..."
npm install -g @opencode-ai/cli

# Verify installation
if command -v opencode &> /dev/null; then
    echo "✓ OpenCode installed successfully"
    opencode --version
else
    echo "✗ OpenCode installation failed - command not found"
    echo "  Ensure npm global bin is in your PATH"
    exit 1
fi

# Create OpenCode config directory
CONFIG_DIR="$HOME/.config/opencode"
mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/tool"

# Create symlinks to shared agent tools
AGENT_TOOLS_DIR="$HOME/code/jomarchy/tools"
echo "→ Creating symlinks to shared agent tools..."

# Core agent tools that work across CLIs
TOOLS_TO_LINK=(
    "db-query"
    "db-user-lookup"
    "db-sessions"
    "am-inbox"
    "am-send"
    "am-register"
    "edge-logs"
    "asset-info"
    "video-status"
)

LINKED_COUNT=0
for tool in "${TOOLS_TO_LINK[@]}"; do
    if [ -f "$AGENT_TOOLS_DIR/$tool" ]; then
        ln -sf "$AGENT_TOOLS_DIR/$tool" "$CONFIG_DIR/tool/$tool"
        ((LINKED_COUNT++))
    fi
done

echo "✓ Linked $LINKED_COUNT agent tools to OpenCode"

# Set up API key if not configured
if [ ! -f "$CONFIG_DIR/config.json" ]; then
    echo ""
    echo "⚠️  OpenCode API key not configured"
    echo "Run: opencode config set apiKey YOUR_KEY"
    echo ""
fi

echo ""
echo "=== OpenCode Installation Complete ==="
echo "Commands:"
echo "  opencode               - Start interactive session"
echo "  opencode -p 'prompt'   - Single prompt execution"
echo "  opencode config        - Manage configuration"
echo ""
echo "Custom tools available in: ~/.config/opencode/tool/"
