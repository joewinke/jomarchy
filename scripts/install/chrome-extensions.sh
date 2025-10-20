#!/bin/bash
#
# chrome-extensions.sh - Install Chrome extensions for current user
#
# This script uses Chrome's External Extensions JSON method to install
# extensions without requiring root access.

set -e

# Extension IDs and names
declare -A EXTENSIONS=(
    ["kdfngfkkopeoejecmfejlcpblohnbael"]="Copy on Select"
    ["eimadpbcbfnmbkopoojfekhnkhdbieeh"]="Dark Reader"
    ["aeblfdkhhhdcdjpifhhbdiojplfjncoa"]="1Password"
)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Installing Chrome Extensions${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Create external extensions directory in user config
EXT_DIR="$HOME/.config/chromium/External Extensions"
mkdir -p "$EXT_DIR"

# Create a JSON file for each extension
for ext_id in "${!EXTENSIONS[@]}"; do
    ext_name="${EXTENSIONS[$ext_id]}"
    json_file="$EXT_DIR/$ext_id.json"

    echo -e "  📦 ${ext_name}"

    cat > "$json_file" << EOF
{
  "external_update_url": "https://clients2.google.com/service/update2/crx"
}
EOF
done

echo ""
echo -e "${GREEN}✓ Chrome extension configuration complete!${NC}"
echo -e "${YELLOW}  Extensions will install when you next start Chromium${NC}"
echo ""
