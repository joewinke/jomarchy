# Jomarchy: Complete Project Documentation

**View online:** [github.com/joewinke/jomarchy](https://github.com/joewinke/jomarchy)

This document defines the complete Jomarchy installation system and all available profiles.

---

## 📦 Core Packages

### Development Tools
- `code` (Code - OSS) - Visual Studio Code
- `nodejs` - JavaScript runtime
- `npm` - Node package manager
- `sublime-text-4` (AUR) - Text editor
- `claude-code` (AUR) - Anthropic's CLI for Claude

### Browsers
- `firefox` - Alternative browser
- `chromium` - Pre-installed by Omarchy (omarchy-chromium package)

### Utilities
- `ydotool` - Input automation (required for ChezWizper)
- `yt-dlp` - YouTube downloader
- `tailscale` - Mesh VPN
- `nwg-displays` - Display configuration tool
- `ttf-jetbrains-mono` - JetBrains Mono font

### Graphics & Design
- `inkscape` - Vector graphics editor
- `gimp` - Image manipulation program

**Installation:** `scripts/install/essential-packages.sh`

---

## 🎤 ChezWizper Voice Transcription

**Super+R** for voice-to-text transcription

### Installation Method
Build from source (fork includes Waybar integration):
```bash
git clone https://github.com/joewinke/ChezWizper.git
cd ChezWizper
git checkout add-waybar-integration
make install
```

### What's Included
- Binary: `/usr/local/bin/chezwizper`
- systemd services: `chezwizper.service`, `chezwizper-waybar.service`
- Waybar integration: 6 scripts (status, monitor, history, smart-toggle, copy-last, preview)
- Hyprland keybinding: Super+R
- Walker/dmenu history browser

**Installation:** `scripts/install/chezwizper.sh`

---

## 🌐 Universal Web Apps (10 apps)

Chrome web apps (--app= flag):

### Development
- GitHub - https://github.com
- Cloudflare - https://dash.cloudflare.com
- Supabase - https://supabase.com/dashboard

### Communication
- Proton Mail - https://mail.proton.me

### Search
- Kagi - https://kagi.com

### Social & Media
- YouTube - https://youtube.com
- X - https://x.com
- Discord - https://discord.com
- WhatsApp - https://web.whatsapp.com

### Productivity
- Zoom - https://zoom.us

**Installation:** `scripts/install/web-apps-universal.sh`

---

## 🔌 Chrome Extensions (3 extensions)

Auto-install on first Chrome launch:

1. **Copy on Select** - `kdfngfkkopeoejecmfejlcpblohnbael`
2. **Dark Reader** - `eimadpbcbfnmbkopoojfekhnkhdbieeh`
3. **1Password** - `aeblfdkhhhdcdjpifhhbdiojplfjncoa`

**Installation:** `scripts/install/chrome-extensions.sh` ✅

---

## 📊 Waybar Customizations

### Intelligent Multi-Monitor Workspace Configuration

Automatically detects and configures workspaces based on monitor count:

**1 Monitor:**
- Workspaces 1-10 (green)

**2 Monitors:**
- Left: Workspaces 1-10 (green)
- Right: Workspaces 11-20 (cyan)

**3 Monitors:**
- Left: Workspaces 1-10 (green)
- Center: Workspaces 11-20 (cyan)
- Right: Workspaces 21-30 (magenta)

### Features
- Color-coded workspace numbers for easy identification
- Visual separators between workspace groups
- Automatic Hyprland workspace-to-monitor bindings
- Persistent workspace configuration
- Adapts automatically when monitors are added/removed

### Visual Enhancements
- Custom clock format (mm-dd dow HH:MM)
- Window title rewriting for clean app names
- ChezWizper integration (6 scripts + CSS animations)

**Installation:** `scripts/install/waybar-customizations-universal.sh` ✅

**Re-run anytime** to detect monitor changes and reconfigure workspaces

---

## 🔧 Custom Scripts

**Location:** `~/.local/bin/`

1. **toggle-zoom** - Super+Z for 2x screen magnification
2. **file-search** - F4 for fuzzy file finder with preview
3. **screensaver** - Super+L for lock/screensaver (Omarchy built-in)

**Installation:** `scripts/install/custom-scripts-universal.sh`

---

## 🌅 Blue Light Filter (Hyprsunset)

Automatic blue light filtering based on time of day for better sleep.

### Schedule
- **6:30 AM**: Normal daylight (6500K) - no color adjustment
- **7:00 PM**: Sunset warmth (5000K) - slight warm tint
- **9:00 PM**: Bedtime mode (3400K) - warm orange tint for better sleep

### What It Does
- Automatically adjusts screen color temperature throughout the day
- Reduces blue light in evenings to help with sleep
- Runs continuously in background
- Config file: `~/.config/hypr/hyprsunset.conf`

### Management
```bash
# Check status
systemctl --user status hyprsunset.service

# Restart if needed
systemctl --user restart hyprsunset.service

# Disable temporarily
systemctl --user stop hyprsunset.service
```

**Installation:** `scripts/install/custom-scripts-universal.sh` (auto-starts service)

---

## ⌨️ Hyprland Custom Keybindings

Minimal custom keybindings (verify Omarchy 3.1 compatibility):

- **F4**: Global file search
- **Super+Z**: Toggle zoom magnification
- **Super+R**: ChezWizper voice transcription
- **Super+L**: Enable screensaver/lock

### Email/Calendar/Drive Keybinds

**Optional Configuration:** `scripts/install/email-calendar-keybinds.sh`

Configure keybinds for your preferred email provider:
- **Super+Shift+E**: Email
- **Super+Shift+C**: Calendar
- **Super+Shift+D**: Drive (when available)

**Supported Providers:**
- Proton Mail (email, calendar, drive)
- Gmail/Google (email, calendar, drive)
- Hey (email, calendar)
- Outlook/Microsoft (email, calendar, OneDrive)
- Yahoo (email, calendar)

Interactive `gum` menu lets you choose your provider during installation. The script is idempotent and can be re-run to change providers.

---

## 💻 Bash Customizations

### Directory Structure
```bash
~/code/linux     # System configuration work
~/code/personal  # General purpose workspace
```

### Claude Aliases
```bash
# Linux project - system configuration
alias cl='cd ~/code/linux && claude --dangerously-skip-permissions'

# Personal project - general purpose workspace
alias cp='cd ~/code/personal && claude --dangerously-skip-permissions'

# Tailscale file download shortcut (if Tailscale installed)
alias tget='sudo tailscale file get -wait ~/Downloads/'
```

**Installation:** `scripts/install/bash-customizations-universal.sh` ✅

---

## 🔌 Claude Code MCP Configuration

### Model Context Protocol (MCP) Servers

Configures Claude Code with MCP servers for enhanced capabilities.

**Configured Servers:**
- **Chrome DevTools MCP** - Browser automation and debugging tools

**Location:** `~/.claude/mcp.json`

**What it does:**
- Enables Claude Code to interact with Chrome browser
- Provides DevTools integration
- Automatically uses latest version via npx

**Installation:** `scripts/install/claude-code-mcp.sh`

---

## 🤖 Agentic Coding Environment (DEV Profile)

**A synergistic multi-agent development setup** combining multiple AI coding tools, coordination systems, and lightweight utilities for maximum productivity.

### Philosophy: Bash Tools Over MCP

Following [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) by Mario Zechner - simple bash tools **replace MCP servers entirely** with 80x token reduction.

**Token Savings:** 32,425 tokens saved by eliminating MCP server overhead

**Why bash over MCP:**
- Composability: `tool1 | jq | tool2 > output.json`
- Cross-CLI: Same tools work in Claude Code, OpenCode, Cursor, Aider
- Zero startup: No server initialization, just execute
- Portable: Tools are simple bash/node scripts

### Components

#### 1. **Claude Code** (Already Installed)
Anthropic's official CLI for AI pair programming.
- Command: `cl` (alias with agent tools loaded)
- Uses: Primary agentic coding interface
- Documentation: https://code.claude.com/docs

#### 2. **OpenCode** (Optional)
Alternative agentic CLI with TypeScript/JavaScript focus.
- Command: `opencode`
- Uses: Alternative to Claude Code, good for front-end work
- Documentation: https://opencode.ai/docs
- **Installation:** `scripts/install/opencode.sh`

#### 3. **Agent Mail** (Multi-Agent Coordination)
Message-passing system for agents to coordinate asynchronously.
- Database: `~/.agent-mail.db` (SQLite)
- Tools: `am-register`, `am-send`, `am-inbox`, `am-reserve`, etc.
- Uses:
  - Agents communicate across sessions
  - File reservation system (prevents conflicts)
  - Thread-based conversations with audit trail
  - Searchable message archive
- **Installation:** Installed via jomarchy-agent-tools

#### 4. **Beads** (Dependency-Aware Task Planning)
Lightweight issue database with dependency tracking.
- Command: `bd`
- Uses:
  - `bd ready` - Show tasks ready to work on
  - `bd create` - Create new tasks
  - `bd status <id>` - Check task status
  - Agents can query and update task states
- Integration: Use `bd-###` as Agent Mail `thread_id` for traceability
- **Installation:** `scripts/install/beads.sh`

#### 5. **Agent Tools** (35 Generic + Project-Specific)
Lightweight command-line tools for common operations.

**Generic Tools** (available in all projects):
- **Agent Mail (11):** am-register, am-inbox, am-send, am-reply, am-ack, am-reserve, am-release, etc.
- **Database (3):** db-query, db-schema, db-sessions
- **Development (7):** type-check-fast, lint-staged, migration-status, component-deps, route-list, build-size, env-check
- **Monitoring (5):** edge-logs, quota-check, job-monitor, error-log, perf-check
- **Deployment (2):** db-connection-test, cache-clear
- **Browser (7):** browser-start.js, browser-nav.js, browser-eval.js, browser-screenshot.js, etc.

**Location:** `~/code/jomarchy/tools/`

**Project-Specific Tools Pattern:**
Projects can add custom tools in `.claude/tools/` which are automatically available when working in that project:
```
~/code/myproject/.claude/tools/
  ├── project-specific-tool-1
  └── project-specific-tool-2
```

Your `.bashrc` launcher adds both generic and project-specific tools to PATH automatically.

**Usage:**
```bash
# Generic tools work everywhere
db-query "SELECT * FROM users LIMIT 5"
am-inbox AgentName --unread
edge-logs function-name --follow

# Project-specific tools only work in their project
# (if defined in that project's .claude/tools/)
```

**Installation:** `scripts/install/agent-tools.sh`

### The Synergy

These tools work together to create a powerful development workflow:

1. **Pick Work** (Beads)
   ```bash
   bd ready --json  # Get highest priority task
   ```

2. **Reserve Files** (Agent Mail)
   ```bash
   am-reserve src/**/*.svelte --agent AgentName --ttl 3600 --reason "bd-123"
   ```

3. **Code with AI** (Claude Code / OpenCode)
   ```bash
   cl  # Claude with agent tools loaded
   # or
   opencode
   ```

4. **Coordinate** (Agent Mail)
   ```bash
   am-send "Status update" "Completed auth flow" --from Agent1 --to Agent2 --thread bd-123
   ```

5. **Monitor** (Agent Tools)
   ```bash
   edge-logs auth-function --errors
   db-query "SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '1 hour'"
   ```

6. **Complete** (Beads)
   ```bash
   bd close bd-123 --reason "Completed"
   am-release src/**/*.svelte --agent AgentName
   ```

### Cross-CLI Compatibility

Agent tools work with ANY agentic CLI:
- ✅ Claude Code (via `cl` alias)
- ✅ OpenCode (symlinked to `~/.config/opencode/tool/`)
- ✅ Cursor (add to settings)
- ✅ Aider (tools in PATH)

### Configuration

All tools configured via `~/.bashrc`:
```bash
# Agent tools path
export AGENT_TOOLS_PATH="~/code/jomarchy/tools"

# Agent Mail (bash + SQLite, no server needed)
export AGENT_MAIL_DB="${AGENT_MAIL_DB:-$HOME/.agent-mail.db}"

# Database (configure for your project)
export DATABASE_URL="postgresql://..."

# Alias: Claude Code with tools
alias cl="PATH=$PATH:$AGENT_TOOLS_PATH DATABASE_URL=\"$DATABASE_URL\" claude"

# Project-specific functions (auto-generated from ~/code/)
ccchim() {
    (cd ~/code/chimaro && PATH=$PATH:$AGENT_TOOLS_PATH DATABASE_URL="$DATABASE_URL" AGENT_MAIL_URL="$AGENT_MAIL_URL" claude --dangerously-skip-permissions "$@")
}
# ... functions for each project in ~/code/
```

**Project Functions Support Arguments:**
```bash
ccchim          # Open chimaro with agent tools
ccchim -r       # Resume last chimaro session
ccchim --help   # Show Claude help in chimaro context
```

### Documentation

Full agent tools reference: `~/code/jomarchy/tools/README.md`

Inject into agent context: `@~/code/jomarchy/tools/README.md`

---

## 🚀 Claude Desktop Shortcuts (2 shortcuts)

Desktop shortcuts matching terminal aliases:

- **Claude Linux** → `cl` → ~/code/linux
- **Claude Personal** → `cp` → ~/code/personal

**Format:**
```ini
[Desktop Entry]
Name=Claude [Project]
Exec=alacritty -T "Claude [Project]" --working-directory /home/jw/code/[project] -e bash -ic "claude --dangerously-skip-permissions; exec bash"
Icon=/home/jw/.local/share/applications/icons/Claude.png
```

**Installation:** `scripts/install/claude-launchers-universal.sh`

---

## 📋 Installation Summary

**Total packages:** ~17 core packages + 10 web apps + 3 extensions
**Total scripts:** 9 installation scripts
**Directories created:** ~/code/linux, ~/code/personal, ~/.claude
**Aliases added:** cl, cp, tget (if Tailscale)
**Desktop shortcuts:** 2 (Claude Linux, Claude Personal)
**MCP servers:** 1 (Chrome DevTools)

---

## 🎯 Quick Install

Run the master installation script:
```bash
cd ~/code/jomarchy
./scripts/install/install-jomarchy.sh
```

This will execute all BASE profile installation scripts in the correct order.

---

## ✅ What This Gives You

A fully functional Omarchy system with:
- Development environment (VSCodium, Node.js, Claude Code)
- Voice transcription (ChezWizper with Waybar)
- Essential web apps for productivity
- Custom keybindings and scripts
- Beautiful Waybar integration
- Personal workspace setup

**Perfect for:** Any Omarchy installation (laptop, desktop, VM)

---

## 🔧 Management Tools

After installation, Jomarchy provides ongoing management capabilities:

### Jomarchy Command

Run `jomarchy` from anywhere to access:

**Interactive Menu:**
- Install Additional Profiles
- Manage Web App Profiles
- Update Jomarchy
- View Installation Summary
- View Documentation

**Quick Commands:**
```bash
jomarchy --profiles    # Web app profile manager
jomarchy --install     # Install more profiles
jomarchy --update      # Update from GitHub
jomarchy --status      # View installed profiles
jomarchy --help        # Show all options
```

### Web App Profile Manager

Organize your web apps by Chrome profile:

**Features:**
- View current profile assignments
- Move apps between profiles (single or bulk)
- Rename Chrome profiles
- View detailed profile information

**Example Use Cases:**
- Separate work and personal apps
- Isolate banking apps in dedicated profile
- Keep social media in separate profile
- Organize by project or client

**Access:**
```bash
jomarchy --profiles
```

Or select "Manage Web App Profiles" from the jomarchy menu.

---

## 📚 Additional Documentation

- **README.md** - Project overview and quick start
- **CLAUDE.md** - Developer documentation and architecture
- **Online:** https://github.com/joewinke/jomarchy
