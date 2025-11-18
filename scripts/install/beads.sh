#!/bin/bash
# Install Beads - Dependency-aware task planning for agents
# Part of Jomarchy Agentic Coding Setup

set -e

INSTALL_DIR="$HOME/.local/bin"

echo "=== Installing Beads ==="

# Check for Go installation
if ! command -v go &> /dev/null; then
    echo "✗ Go is not installed. Installing Go..."

    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) GO_ARCH="amd64" ;;
        aarch64) GO_ARCH="arm64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    # Download and install Go
    GO_VERSION="1.21.5"
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    # Add Go to PATH if not present
    if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc"; then
        echo "" >> "$HOME/.bashrc"
        echo "# Go programming language" >> "$HOME/.bashrc"
        echo "export PATH=\"\$PATH:/usr/local/go/bin:\$HOME/go/bin\"" >> "$HOME/.bashrc"
        echo "→ Added Go to PATH in .bashrc"
    fi

    export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
    echo "✓ Go installed successfully"
fi

# Clone Beads repository
REPO_DIR="$HOME/code/beads"
if [ -d "$REPO_DIR" ]; then
    echo "→ Beads repository already exists, pulling latest..."
    cd "$REPO_DIR"
    git pull
else
    echo "→ Cloning Beads repository..."
    git clone https://github.com/steveyegge/beads.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Build Beads
echo "→ Building Beads..."
go build -o bd cmd/bd/main.go

# Install to ~/.local/bin
mkdir -p "$INSTALL_DIR"
cp bd "$INSTALL_DIR/bd"
chmod +x "$INSTALL_DIR/bd"

# Verify installation
if command -v bd &> /dev/null; then
    echo "✓ Beads (bd) installed successfully"
    bd --version || true
else
    echo "✗ Beads installation failed - bd command not found"
    echo "  Ensure ~/.local/bin is in your PATH"
    exit 1
fi

# Add to PATH if not present
if ! grep -q ".local/bin" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Local user binaries" >> "$HOME/.bashrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "→ Added ~/.local/bin to PATH in .bashrc"
fi

echo ""
echo "=== Beads Installation Complete ==="
echo "Commands:"
echo "  bd list              - List all tasks"
echo "  bd ready             - Show ready-to-work tasks"
echo "  bd create <title>    - Create new task"
echo "  bd status <id>       - Show task status"
echo ""
echo "Reload your shell: source ~/.bashrc"
