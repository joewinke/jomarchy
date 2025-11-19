#!/bin/bash

# JOMARCHY-AGENT-TOOLS Installation Script
# Thin wrapper that calls the standalone jomarchy-agent-tools installer

set -e

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

echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}AGENT-TOOLS Profile Installation${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo "This will install the complete AI-assisted development environment:"
echo "  • Agent Mail (multi-agent coordination server)"
echo "  • Beads CLI (dependency-aware task planning)"
echo "  • 43 bash agent tools (am-*, browser-*, db-*, etc.)"
echo "  • Global ~/.claude/CLAUDE.md configuration"
echo "  • Per-repository setup (bd init, CLAUDE.md templates)"
echo ""

# Check if jomarchy-agent-tools is already cloned
if [ -d "$HOME/code/jomarchy-agent-tools" ]; then
    echo -e "${GREEN}→${NC} Using local jomarchy-agent-tools installation"
    echo ""
    bash "$HOME/code/jomarchy-agent-tools/install.sh"
else
    echo -e "${BLUE}→${NC} Installing via curl from GitHub..."
    echo ""
    curl -fsSL https://raw.githubusercontent.com/joewinke/jomarchy-agent-tools/main/install.sh | bash
fi

# Mark profile as installed
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
    source "$SCRIPT_DIR/../lib/common.sh"
    add_installed_profile "AGENT-TOOLS"
fi

echo ""
echo "Integration complete!"
echo ""
echo "The AGENT-TOOLS profile is now part of your jomarchy installation."
echo ""
