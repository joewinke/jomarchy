#!/bin/bash

# Claude Daily Quote Timer
# Sets up systemd user timer for daily inspiring quotes

set -e  # Exit on error

echo "========================================"
echo "Claude Daily Quote Timer Setup"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if claude is installed
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}WARNING: claude command not found${NC}"
    echo "Claude Code should be installed first (from essential-packages.sh)"
    echo "Timer will be created, but won't work until Claude Code is installed."
    echo ""
fi

echo -e "${BLUE}→${NC} Creating systemd user timer for daily Claude quotes..."

# Create systemd user directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Create the service file
cat > ~/.config/systemd/user/claude-daily-quote.service << 'EOF'
[Unit]
Description=Daily Claude Inspiring Quote
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '$HOME/.local/bin/claude -p "Tell me an inspiring quote for $(date +%%A,%%B%%d,%%Y)."'
EOF

echo -e "${GREEN}✓${NC} Service file created"

# Create the timer file
cat > ~/.config/systemd/user/claude-daily-quote.timer << 'EOF'
[Unit]
Description=Run daily Claude quote at 9am EST
Requires=claude-daily-quote.service

[Timer]
OnCalendar=*-*-* 08:00:00 America/New_York
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo -e "${GREEN}✓${NC} Timer file created"

# Reload systemd user daemon
systemctl --user daemon-reload
echo -e "${GREEN}✓${NC} Systemd daemon reloaded"

# Enable and start the timer
systemctl --user enable claude-daily-quote.timer
systemctl --user start claude-daily-quote.timer
echo -e "${GREEN}✓${NC} Timer enabled and started"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Daily Quote Timer Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo "Schedule: Every day at 8:00 AM America/New_York (9:00 AM EST)"
echo ""
echo "Useful commands:"
echo "  Check status: systemctl --user status claude-daily-quote.timer"
echo "  View quotes:  journalctl --user -u claude-daily-quote.service"
echo "  Test now:     systemctl --user start claude-daily-quote.service"
echo ""

# Show next scheduled run
NEXT_RUN=$(systemctl --user list-timers claude-daily-quote.timer --no-pager | grep -A1 "NEXT" | tail -1 | awk '{print $1, $2, $3}')
if [ -n "$NEXT_RUN" ]; then
    echo "Next scheduled run: $NEXT_RUN"
    echo ""
fi
