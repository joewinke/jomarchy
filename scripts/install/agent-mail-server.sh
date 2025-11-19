#!/bin/bash

# Install Agent Mail Server
# Multi-agent coordination system via HTTP API

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Installing Agent Mail Server...${NC}"
echo ""

# Check if already installed
if systemctl --user is-active --quiet agent-mail 2>/dev/null; then
    echo -e "${YELLOW}  ⊘ Agent Mail Server already running${NC}"
    echo "  Check status: systemctl --user status agent-mail"
    exit 0
fi

if command -v agent-mail &> /dev/null; then
    echo -e "${YELLOW}  ⊘ Agent Mail Server already installed${NC}"
    echo "  Version: $(agent-mail --version 2>/dev/null || echo 'unknown')"
else
    echo "  → Installing Agent Mail Server via official installer..."
    echo ""

    # Use official installer with --yes flag
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh | bash -s -- --yes

    echo ""
    echo -e "${GREEN}  ✓ Agent Mail Server installed${NC}"
fi

# Wait a moment for service to start
sleep 2

# Check if service is running
if systemctl --user is-active --quiet agent-mail 2>/dev/null; then
    echo -e "${GREEN}  ✓ Agent Mail Server is running${NC}"
    echo "  API: http://localhost:3141"
    echo "  Check logs: journalctl --user -u agent-mail -f"
else
    echo -e "${YELLOW}  ⚠ Agent Mail Server installed but not running${NC}"
    echo "  Start it with: systemctl --user start agent-mail"
    echo "  Enable at boot: systemctl --user enable agent-mail"
fi

echo ""
echo "  Usage:"
echo "    am-register --program claude-code --model sonnet-4.5"
echo "    am-inbox AgentName"
echo "    am-send \"Subject\" \"Body\" --from AgentName --to project-team"
echo ""
