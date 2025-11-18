#!/bin/bash
# Install Agent Mail server for multi-agent coordination
# Part of Jomarchy Agentic Coding Setup

set -e

INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"

echo "=== Installing Agent Mail Server ==="

# Install uv (Python package manager) if not present
if ! command -v uv &> /dev/null; then
    echo "→ Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$SERVICE_DIR"

# Clone Agent Mail repository
REPO_DIR="$HOME/code/agent-mail"
if [ -d "$REPO_DIR" ]; then
    echo "→ Agent Mail repository already exists, pulling latest..."
    cd "$REPO_DIR"
    git pull
else
    echo "→ Cloning Agent Mail repository..."
    git clone https://github.com/jazzdup/agent-mail.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Install dependencies with uv
echo "→ Installing Agent Mail dependencies..."
uv venv
source .venv/bin/activate
uv pip install -e .

# Create systemd service
echo "→ Creating systemd service..."
cat > "$SERVICE_DIR/agent-mail.service" <<'EOF'
[Unit]
Description=Agent Mail Server
After=network.target

[Service]
Type=simple
WorkingDirectory=%h/code/agent-mail
ExecStart=%h/code/agent-mail/.venv/bin/python -m agent_mail.server
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Enable and start service
echo "→ Enabling and starting Agent Mail service..."
systemctl --user daemon-reload
systemctl --user enable agent-mail.service
systemctl --user start agent-mail.service

# Wait for service to start
sleep 2

# Check service status
if systemctl --user is-active --quiet agent-mail.service; then
    echo "✓ Agent Mail server installed and running"
    echo "  Service: systemctl --user status agent-mail"
    echo "  URL: http://localhost:8765"
else
    echo "✗ Agent Mail service failed to start"
    systemctl --user status agent-mail.service
    exit 1
fi

# Add environment variables to .bashrc if not present
if ! grep -q "AGENT_MAIL_URL" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Agent Mail configuration" >> "$HOME/.bashrc"
    echo "export AGENT_MAIL_URL=\"http://localhost:8765\"" >> "$HOME/.bashrc"
    echo "export PROJECT_KEY=\"\$PWD\"  # Default: current directory" >> "$HOME/.bashrc"
    echo "→ Added Agent Mail env vars to .bashrc"
fi

echo ""
echo "=== Agent Mail Installation Complete ==="
echo "Reload your shell: source ~/.bashrc"
