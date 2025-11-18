#!/bin/bash
# Configure agent tools and CLI aliases
# Part of Jomarchy Agentic Coding Setup

set -e

AGENT_TOOLS_DIR="$HOME/code/jomarchy/tools"
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

# Update global Claude documentation if it exists
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    echo ""
    echo "→ Updating ~/.claude/CLAUDE.md with agent tools documentation..."

    # Check if agent tools section already exists
    if grep -q "## Agent Tools: Lightweight bash tools" "$CLAUDE_MD"; then
        echo "  ℹ Agent Tools section already exists in CLAUDE.md (skipping)"
    else
        # Append agent tools documentation
        cat >> "$CLAUDE_MD" << 'AGENT_TOOLS_DOC'

## Agent Tools: Lightweight bash tools for common operations

**56 generic bash tools** available system-wide with massive token savings (32,425 tokens vs MCP servers).

Philosophy: Following [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) by Mario Zechner - simple bash tools achieve 80x token reduction.

**Location:** `~/code/jomarchy/tools/`

### Tool Categories

- **Agent Mail (11):** am-register, am-inbox, am-send, am-reply, am-ack, am-reserve, am-release, am-reservations, am-search, am-agents, am-whoami
- **Database (4):** db-query, db-user-lookup, db-sessions, db-schema
- **Media (4):** asset-info, video-status, storage-cleanup, media-validate
- **Development (5):** type-check-fast, lint-staged, migration-status, component-deps, route-list
- **Monitoring (5):** edge-logs, quota-check, job-monitor, error-log, perf-check
- **Team (3):** user-activity, brand-stats, invite-status
- **Deployment (4):** env-check, build-size, db-connection-test, cache-clear
- **AI/Testing (6):** generation-history, test-route, prompt-test, model-compare, db-seed-mini, snapshot-compare
- **Browser (7):** browser-start.js, browser-nav.js, browser-eval.js, browser-screenshot.js, browser-pick.js, browser-cookies.js, browser-hn-scraper.js

### Quick Usage

**All tools have `--help` flags:**
```bash
db-query --help
am-inbox --help
edge-logs --help
```

**Common examples:**
```bash
# Database queries (auto-LIMIT protection)
db-query "SELECT * FROM users WHERE created_at > NOW() - INTERVAL '1 hour'"
db-user-lookup user@example.com

# Agent Mail (lightweight HTTP wrappers)
am-inbox AgentName --unread
am-send "Subject" "Body" --from Agent1 --to Agent2 --thread bd-123
am-reserve src/**/*.svelte --agent AgentName --ttl 3600 --reason "bd-123"

# Monitoring
edge-logs function-name --follow --errors
quota-check --model openai-gpt4

# Media
asset-info asset_id
video-status batch_id --all-pending

# Browser automation
browser-screenshot.js  # Returns temp file path
browser-eval.js 'document.title'
```

### Integration with Agent Mail & Beads

Use together for maximum efficiency:
```bash
# 1. Pick work
bd ready --json

# 2. Reserve files (bash tool instead of MCP)
am-reserve src/**/*.ts --agent $AGENT_NAME --ttl 3600 --reason "bd-123"

# 3. Query database
db-query "SELECT COUNT(*) FROM invocations WHERE status='pending'"

# 4. Monitor edge function
edge-logs video-generator --errors

# 5. Complete and release
bd close bd-123 --reason "Completed"
am-release src/**/*.ts --agent $AGENT_NAME
```

### Why Bash Tools (Not MCP)

These tools **replace MCP servers** entirely, providing:
- **Massive token savings**: 32,425 tokens saved (80x reduction)
- **Bash composability**: Use pipes, jq, redirects, xargs
- **Cross-CLI compatibility**: Works with Claude Code, OpenCode, Cursor, Aider
- **Zero overhead**: Just executables, no server startup

Example of bash composability:
\`\`\`bash
# Chain tools together
am-inbox AgentName --unread --json | jq '.[] | select(.importance=="urgent")'

# Pipe to other tools
db-query "SELECT id FROM users WHERE role='admin'" | xargs -I {} db-user-lookup {}

# Save to file and process
edge-logs video-gen --errors > errors.log && grep "timeout" errors.log
\`\`\`

### Full Documentation

For complete tool reference: `@~/code/jomarchy/tools/README.md`

This injects full docs into your context when needed (Mario's approach - saves tokens vs auto-discovery).
AGENT_TOOLS_DOC

        echo "  ✓ Added agent tools documentation to ~/.claude/CLAUDE.md"
    fi
fi

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
