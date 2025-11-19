# Jomarchy Agent Tools

**49 lightweight command-line tools** for AI agents with minimal context overhead.

Following the philosophy from [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) - simple bash tools with 80x less token overhead than MCP servers.

## Philosophy: Simple Tools vs MCP Servers

**Context Overhead Comparison:**
- **Chrome DevTools MCP:** ~18,000 tokens
- **browser-tools (simple scripts):** ~225 tokens
- **Savings:** 80x reduction in context overhead

**When to use simple tools:**
- Token budget is constrained
- Need bash composability (pipes, redirects, file saves)
- Want rapid custom tool development
- Performing straightforward operations

**When to use MCP servers:**
- Complex stateful operations required
- Need structured validation and error handling
- Using well-maintained, feature-rich integrations (Agent Mail, Supabase)

## Installation

```bash
cd agent-tools
npm install  # For browser tools (puppeteer-core)

# Add to PATH (optional)
export PATH="$PATH:$(pwd)"
```

## Tool Categories

### 🔧 Agent Mail Tools (11 tools)

Lightweight wrappers for Agent Mail HTTP API - saves ~10-15k tokens vs MCP.

- **am-register** - Register or resume agent identity
- **am-whoami** - Show current agent info
- **am-agents** - List all agents in project
- **am-inbox** - Fetch inbox messages
- **am-send** - Send message
- **am-reply** - Reply to message
- **am-ack** - Acknowledge message
- **am-reserve** - Reserve files for editing
- **am-release** - Release file reservations
- **am-reservations** - List active reservations
- **am-search** - Search messages

```bash
# Examples
am-register --program claude-code --model sonnet-4.5
am-inbox AgentName --unread
am-send "Subject" "Body" --from Agent1 --to Agent2 --thread bd-123
am-reserve src/**/*.svelte --agent AgentName --ttl 3600
am-search "video generation"
```

### 🗄️ Database Tools (4 tools)

Quick psql wrappers for Supabase queries.

- **db-query** - Quick SQL queries with auto-LIMIT protection
- **db-user-lookup** - Find user/brand information
- **db-sessions** - View active chat sessions
- **db-schema** - Quick schema inspection

```bash
# Examples
db-query "SELECT * FROM assets WHERE brand_id = '...' LIMIT 5"
db-user-lookup user@example.com
db-sessions --recent 10
db-schema assets
db-schema --tables  # List all tables
```

### 📁 Media & Asset Tools (4 tools)

Asset and video batch monitoring.

- **asset-info** - Quick asset metadata lookup
- **video-status** - Batch video generation job status
- **storage-cleanup** - Find orphaned storage files *(planned)*
- **media-validate** - Check media file integrity

```bash
# Examples
asset-info asset_id
asset-info --recent 5
video-status batch_id
video-status --all-pending
media-validate --missing  # Find broken references
```

### 🔨 Development Tools (5 tools)

Speed up development workflow.

- **type-check-fast** - Quick TypeScript check of specific files
- **lint-staged** - Lint only changed files
- **migration-status** - Check Supabase migrations
- **component-deps** - Find component dependencies
- **route-list** - List all SvelteKit routes

```bash
# Examples
type-check-fast src/lib/components/video/*.svelte
type-check-fast --changed  # Only git modified files
lint-staged --fix
migration-status --create "add_video_batch_table"
component-deps MediaSelector.svelte
route-list --api  # Only API routes
```

### 📊 Monitoring Tools (5 tools)

System monitoring and debugging.

- **edge-logs** - Read Supabase edge function logs
- **quota-check** - Check AI model usage quotas
- **job-monitor** - Background job status dashboard
- **error-log** - Recent application errors
- **perf-check** - Identify slow queries and routes

```bash
# Examples
edge-logs generate-video --follow
edge-logs --list  # List all functions
quota-check --model openai-gpt4
job-monitor --failed
error-log --last 1h --pattern "video"
perf-check --slow-queries
```

### 👥 Team & User Management Tools (3 tools)

User and brand analytics.

- **user-activity** - View user activity patterns
- **brand-stats** - Brand-level usage statistics
- **invite-status** - Track pending invitations

```bash
# Examples
user-activity user@example.com
user-activity --inactive 30d
brand-stats brand_id
brand-stats --all --summary
invite-status --expired
```

### 🚀 Deployment & Infrastructure Tools (4 tools)

Deployment validation and environment checks.

- **env-check** - Verify environment variables
- **build-size** - Track build artifact sizes
- **db-connection-test** - Test database connectivity
- **cache-clear** - Clear various caches

```bash
# Examples
env-check --required
build-size --breakdown
db-connection-test --latency
cache-clear --local
```

### 🤖 AI & Generation Tools (3 tools)

AI model testing and comparison.

- **prompt-test** - Quick test AI prompts *(planned)*
- **model-compare** - Compare model outputs *(planned)*
- **generation-history** - View recent AI generations

```bash
# Examples
generation-history --user user_id
generation-history --model gpt-4 --last 24h
```

### 🧪 Testing & Quality Tools (3 tools)

Testing and data management.

- **test-route** - Quick API route testing
- **db-seed-mini** - Quick minimal test data generation *(planned)*
- **snapshot-compare** - Compare database snapshots *(planned)*

```bash
# Examples
test-route /api/video/generate --method POST --data '{"prompt":"..."}'
```

### 🌐 Browser Automation Tools (7 tools)

From [badlogic/browser-tools](https://github.com/badlogic/browser-tools) - Chrome DevTools Protocol tools.

- **browser-start.js** - Launch Chrome with debugging
- **browser-nav.js** - Navigate to URLs
- **browser-eval.js** - Execute JavaScript in page
- **browser-screenshot.js** - Capture screenshots
- **browser-pick.js** - Interactive element picker
- **browser-cookies.js** - Display cookies
- **browser-hn-scraper.js** - Example: Hacker News scraper

```bash
# Examples
browser-start.js --profile
browser-nav.js https://example.com
browser-eval.js 'document.title'
browser-screenshot.js  # Returns temp file path
browser-pick.js "Click the submit button"
browser-cookies.js
```

## Environment Variables

Required for most tools:

```bash
# Database
export DATABASE_URL="postgresql://..."
# or
export SUPABASE_DB_URL="postgresql://..."

# Agent Mail (if using am-* tools)
export AGENT_MAIL_URL="http://localhost:8765"
export AGENT_MAIL_TOKEN="your-token"  # Optional if JWT not enabled
export PROJECT_KEY="/path/to/project"  # Default: current directory

# Supabase
export PUBLIC_SUPABASE_URL="https://..."
export PUBLIC_SUPABASE_ANON_KEY="..."
export SUPABASE_SERVICE_ROLE="..."

# AI Services (optional)
export OPENAI_API_KEY="..."
export SAMBANOVA_API_KEY="..."
```

## Design Principles

Each tool follows these guidelines:

1. **Single purpose** - Do one thing well
2. **Fast execution** - Optimize for speed (< 1 second ideal)
3. **Clear output** - Human-readable by default, JSON on demand
4. **Composable** - Work well with pipes, redirects, xargs
5. **Low context** - Minimal dependencies, clear interface
6. **Error handling** - Fail gracefully with helpful messages

## Usage Patterns

### Composition with pipes

```bash
# Find pending video batches and get details
video-status --all-pending | jq '.[].id' | xargs -I {} video-status {}

# Search Agent Mail and acknowledge results
am-search "urgent" --json | jq '.[].id' | xargs -I {} am-ack {} --agent MyAgent

# Check changed files and lint them
type-check-fast --changed && lint-staged --fix
```

### Integration with scripts

```bash
#!/usr/bin/env bash
# check-deployment.sh - Pre-deployment checks

echo "=== Pre-Deployment Checks ==="

# Environment check
env-check --required || exit 1

# Type check changed files
type-check-fast --changed || exit 1

# Database connection
db-connection-test || exit 1

# Build and check size
npm run build
build-size --breakdown

echo "✓ All checks passed"
```

### Agent coordination

```bash
# Agent registers and checks inbox
am-register --name MyAgent --task "Bug fixes"
am-inbox MyAgent --unread

# Reserve files before editing
am-reserve src/lib/components/*.svelte --agent MyAgent

# Work on files...

# Release when done
am-release --agent MyAgent --all
```

## Token Savings Calculation

Replacing MCP servers with simple tools:

| Tool Category | MCP Tokens | Simple Tools | Savings |
|--------------|------------|--------------|---------|
| Browser Tools | ~18,000 | ~225 | 17,775 |
| Agent Mail | ~10,000 | ~200 | 9,800 |
| Database | ~5,000 | ~150 | 4,850 |
| **Total** | **33,000** | **575** | **32,425** |

**That's enough saved context for ~65,000 additional words of code/documentation!**

## Contributing

To add a new tool:

1. Create executable script in `~/code/jomarchy-agent-tools/tools/`
2. Follow naming convention: `category-action` (e.g., `db-query`, `am-inbox`)
3. Add `--help` flag with usage examples
4. Keep it single-purpose and fast
5. Test with pipes and redirects
6. Document in this README

## Future Enhancements

Tools marked as *(planned)* are placeholders for future implementation:
- storage-cleanup - Requires Supabase Storage API integration
- prompt-test - Requires AI model API integration
- model-compare - Requires multi-model API setup
- db-seed-mini - Requires test data generation logic
- snapshot-compare - Requires snapshot diff algorithm

## License

MIT

## Credits

- Browser tools from [badlogic/browser-tools](https://github.com/badlogic/browser-tools)
- Philosophy from [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) by Mario Zechner
- Part of the [Jomarchy Agent Tools](https://github.com/joewinke/jomarchy-agent-tools) unified repository
