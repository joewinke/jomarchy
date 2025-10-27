#!/bin/bash

# JOMARCHY-COMMUNICATIONS Installation Script
# Extends BASE with communications/messaging apps

set -e  # Exit on error

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERROR: Do not run this script as root${NC}"
    echo "Run as normal user - sudo will be used when needed"
    exit 1
fi
echo ""

# Component selection with gum
SELECTED_COMPONENTS=$(gum choose --no-limit \
    --selected "*" \
    "Discord" \
    "WhatsApp" \
    "Slack" \
    "Gmail")

echo ""
echo -e "${BLUE}Installing selected COMMUNICATIONS components...${NC}"
echo ""

# Install communications web apps if any selected
if [ -n "$SELECTED_COMPONENTS" ]; then
    if [ -f "$SCRIPT_DIR/web-apps-communications.sh" ]; then
        echo -e "${BLUE}→ Installing communications web apps...${NC}"
        bash "$SCRIPT_DIR/web-apps-communications.sh"
    else
        echo -e "${RED}ERROR: web-apps-communications.sh not found${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}No COMMUNICATIONS components selected, skipping...${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}JOMARCHY-COMMUNICATIONS Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Mark profile as installed
if [ -f "$SCRIPT_DIR/../lib/common.sh" ]; then
    source "$SCRIPT_DIR/../lib/common.sh"
    add_installed_profile "COMMUNICATIONS"
fi

echo "Installed communications web apps:"
echo "  ✓ Discord"
echo "  ✓ WhatsApp"
echo "  ✓ Slack"
echo "  ✓ Gmail"
echo ""
