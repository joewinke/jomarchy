#!/bin/bash
# Configure agent tools and CLI aliases
# Part of Jomarchy Agentic Coding Setup

set -e

AGENT_TOOLS_DIR="$HOME/code/jomarchy/.app/agent-tools"
BASHRC="$HOME/.bashrc"

echo "=== Configuring Agent Tools ==="

# Verify agent tools directory exists
if [ ! -d "$AGENT_TOOLS_DIR" ]; then
    echo "✗ Agent tools directory not found: $AGENT_TOOLS_DIR"
    exit 1
fi

# Count tools
TOOL_COUNT=$(find "$AGENT_TOOLS_DIR" -maxdepth 1 -type f -executable | wc -l)
echo "→ Found $TOOL_COUNT agent tools"

# Get database URL from environment or prompt
if [ -z "$DATABASE_URL" ]; then
    echo ""
    echo "Database URL not configured in environment."
    echo "This is typically your Supabase connection string."
    echo ""
    read -p "Enter DATABASE_URL (or press Enter to skip): " USER_DB_URL

    if [ -n "$USER_DB_URL" ]; then
        DATABASE_URL="$USER_DB_URL"
    else
        echo "⚠️  Skipping DATABASE_URL - database tools won't work"
        DATABASE_URL=""
    fi
fi

# Remove old agent-tools configurations from .bashrc
echo "→ Cleaning up old configurations..."
sed -i '/# Agent tools/d' "$BASHRC"
sed -i '/agent-tools/d' "$BASHRC"
sed -i '/alias cl=/d' "$BASHRC"

# Add new configuration block
echo "→ Adding agent tools configuration to .bashrc..."
cat >> "$BASHRC" <<EOF

# ============================================================
# Agentic Coding Environment (Jomarchy)
# ============================================================

# Agent tools path
export AGENT_TOOLS_PATH="$AGENT_TOOLS_DIR"

# Agent Mail configuration
export AGENT_MAIL_URL="http://localhost:8765"
export PROJECT_KEY="\$PWD"  # Default: current directory

# Database configuration
EOF

if [ -n "$DATABASE_URL" ]; then
    cat >> "$BASHRC" <<EOF
export DATABASE_URL="$DATABASE_URL"
EOF
else
    cat >> "$BASHRC" <<EOF
# export DATABASE_URL="your-database-url-here"  # Configure this for db-* tools
EOF
fi

cat >> "$BASHRC" <<'EOF'

# Claude Code with agent tools (agent-only alias)
alias cl="PATH=$PATH:$AGENT_TOOLS_PATH DATABASE_URL=\"$DATABASE_URL\" AGENT_MAIL_URL=\"$AGENT_MAIL_URL\" claude"

# Quick access to agent tools documentation
alias agent-tools-help="cat $AGENT_TOOLS_PATH/README.md | less"

# ============================================================
EOF

echo "✓ Configuration added to .bashrc"

# Create project-specific functions
echo ""
echo "→ Creating project-specific Claude functions..."

# Scan for projects in ~/code/
if [ -d "$HOME/code" ]; then
    PROJECTS=$(find "$HOME/code" -maxdepth 1 -type d -not -name "code" -not -name ".*" -exec basename {} \; | sort)

    if [ -n "$PROJECTS" ]; then
        cat >> "$BASHRC" <<'FUNCTIONS_START'

# Project-specific Claude Code functions with agent tools (support arguments)
# Usage: ccc -r (resume), ccc --help, etc.

FUNCTIONS_START

        for project in $PROJECTS; do
            # Create short alias name (first letter of each word, or first 3-4 chars)
            shortname=$(echo "$project" | tr '[:upper:]' '[:lower:]' | head -c 4)

            cat >> "$BASHRC" <<FUNC_END
cc${shortname}() {
    (cd ~/code/${project} && PATH=\$PATH:\$AGENT_TOOLS_PATH DATABASE_URL="\$DATABASE_URL" AGENT_MAIL_URL="\$AGENT_MAIL_URL" claude --dangerously-skip-permissions "\$@")
}

FUNC_END
            echo "  ✓ cc${shortname} → ~/code/${project}"
        done

        echo ""
        echo "✓ Created functions for $(echo "$PROJECTS" | wc -w) projects"
    fi
fi

# Verify a few key tools
echo ""
echo "→ Verifying agent tools..."
TOOLS_OK=0
for tool in "db-query" "am-inbox" "edge-logs"; do
    if [ -f "$AGENT_TOOLS_DIR/$tool" ] && [ -x "$AGENT_TOOLS_DIR/$tool" ]; then
        echo "  ✓ $tool"
        ((TOOLS_OK++))
    else
        echo "  ✗ $tool (missing or not executable)"
    fi
done

echo ""
echo "=== Agent Tools Configuration Complete ==="
echo ""
echo "Tools available ($TOOL_COUNT total):"
echo "  • Agent Mail (11): am-register, am-inbox, am-send, am-reply, etc."
echo "  • Database (4): db-query, db-user-lookup, db-sessions, db-schema"
echo "  • Media (4): asset-info, video-status, storage-cleanup, media-validate"
echo "  • Development (5): type-check-fast, lint-staged, migration-status, etc."
echo "  • Monitoring (5): edge-logs, quota-check, job-monitor, error-log, perf-check"
echo "  • Browser (7): browser-start.js, browser-nav.js, browser-eval.js, etc."
echo "  • And more..."
echo ""
echo "Usage:"
echo "  cl                     - Launch Claude Code with tools available"
echo "  agent-tools-help       - View full documentation"
echo ""
echo "Project-specific functions (auto-generated from ~/code/):"
if [ -d "$HOME/code" ]; then
    for project in $(find "$HOME/code" -maxdepth 1 -type d -not -name "code" -not -name ".*" -exec basename {} \; | sort); do
        shortname=$(echo "$project" | tr '[:upper:]' '[:lower:]' | head -c 4)
        echo "  cc${shortname}         - Claude in ~/code/${project} (supports args like -r)"
    done
fi
echo ""
echo "Reload your shell: source ~/.bashrc"
