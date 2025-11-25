# Jomarchy Project Documentation

## Overview

**Jomarchy** is Joe's complete Omarchy Linux configuration system. It provides a modular, profile-based installation framework for setting up fresh Omarchy systems with software, web apps, and customizations.

## Repository Structure

### jomarchy (Public Repository)
**Location:** `~/code/jomarchy`
**GitHub:** `https://github.com/joewinke/jomarchy`
**Purpose:** Universal configurations that anyone can use

This is the main public repository containing installation profiles that work for any Omarchy user.

### jomarchy-machines (Private Repository)
**Location:** `~/code/jomarchy-machines`
**GitHub:** `https://github.com/joewinke/jomarchy-machines` (private)
**Purpose:** Machine-specific hardware configs + Joe's personal preferences

This is a private companion repository containing:
1. Hardware-specific configurations for individual machines
2. Personal work accounts, project apps, and preferences

## Installation Architecture

### Two-Tier Installation System

```
┌─────────────────────────────────────────────────────────┐
│  TIER 1: jomarchy (Universal/Public)                    │
│  bash <(curl -sL .../jomarchy/master/jomarchy.sh)       │
│  ↓                                                       │
│  Select profiles: BASE, DEV, MEDIA, FINANCE, COMMS      │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  TIER 2: jomarchy-machines (Machine + Personal)         │
│  bash <(curl -sL .../jomarchy-machines/master/...)      │
│  ↓                                                       │
│  Select profiles: BEELINK, JOE-PERSONAL, etc.           │
└─────────────────────────────────────────────────────────┘
```

## Jomarchy Profiles (Public)

### Profile System
All profiles use gum for interactive multi-select with component refinement.

#### BASE Profile
**Core system for any Omarchy installation**

Packages:
- Firefox, Chromium (pre-installed by Omarchy)
- Sublime Text 4, Claude Code
- yt-dlp (video downloader)
- Tailscale (VPN)
- nwg-displays (display manager)
- JetBrains Mono font
- ChezWizper (voice transcription)

Customizations:
- Bash customizations (cl/cp aliases, ~/code shortcuts)
- Chrome extensions (Copy on Select, Dark Reader, 1Password)
- Waybar customizations (clock, ChezWizper indicator, color-coded workspaces)
- Custom scripts (toggle-zoom Super+Z, file-search F4, screensaver)
- Email/Calendar/Drive keybinds (Super+Shift+E/C/D) - configurable for Proton, Gmail, Hey, Outlook, Yahoo

Web Apps:
- Proton Mail
- Kagi (search)
- YouTube
- X (Twitter)

Desktop Launchers:
- Claude (Linux)
- Claude (Personal)
- Claude Code MCP configuration

#### DEV Profile
**Software development tools**

Packages:
- VSCodium (de-Microsoft-ified VS Code)
- Node.js, npm
- GitHub CLI
- Stripe CLI
- Supabase CLI

Customizations:
- GitHub repository cloning (interactive selection)
- Auto-generated bash aliases (cc + first letter of repo name, e.g., ccj for jomarchy)
- Claude project launchers (auto-generated based on cloned repos)
- Daily Claude quote timer (9am EST)

Web Apps:
- GitHub, Cloudflare, Supabase
- Project-specific apps (Chimaro, Marduk, etc. - moved to jomarchy-machines/personal)

#### MEDIA Profile
**Creative and media tools**

Graphics:
- GIMP (image editing)
- Inkscape (vector graphics)

Video:
- OBS Studio (screen recording/streaming)
- Shotcut (video editing - lightweight)
- Kdenlive (video editing - advanced)

3D:
- Blender (3D modeling/animation)

Audio:
- Audacity (audio editing)

#### FINANCE Profile
**Banking and accounting web apps**

Web Apps:
- Bank of America
- Chase Bank
- Capital One
- QuickBooks Online

#### COMMUNICATIONS Profile
**Messaging and communication apps**

Web Apps:
- Discord
- WhatsApp
- Slack
- Gmail
- Zoom

## Jomarchy-Machines Profiles (Private)

### Profile System
Same gum-based multi-select as jomarchy for consistency.

### Machine Profiles (Hardware-Specific)

#### BEELINK Profile
**Beelink SER9 Pro Desktop**
- 3x 3440x1440 ultrawide monitors
- 30-workspace configuration
- Brother HL2270DW printer driver
- Camera support (gphoto2)
- Waybar color coding per monitor

#### IMAC5K Profile (Coming Soon)
**iMac 5K**
- 5K Retina display optimization
- Color profile management
- Hardware acceleration

#### FRAMEWORK13 Profile (Coming Soon)
**Framework 13 Laptop**
- Power management optimization
- Battery life tuning
- Laptop-specific keybindings

### Personal Profiles

#### JOE-PERSONAL Profile
**Joe's work accounts and personal preferences**

Components (all selectable with gum):
1. **Work email accounts**
   - DMT Mail: `https://mail.google.com/mail/u/0/#inbox`
   - PEMail: `https://mail.google.com/mail/u/0/#inbox`

2. **Personal project web apps**
   - Chimaro Local: `http://localhost:3000`
   - Supabase Chimaro, Flush, Steelbridge: `https://supabase.com/dashboard/project/PROJECT_ID`
   - Marduk: `https://mm.marduk.app`
   - Dev Tracker: `https://coda.io`
   - Apify: `https://console.apify.com`
   - DaisyUI: `https://daisyui.com`
   - Docker: `https://localhost:9443`

3. **Work communication**
   - PE Slack: `https://slack.com/signin`

**This profile can be combined with any machine profile!**

## Installation Scripts Structure

### Jomarchy Scripts

```
~/code/jomarchy/
├── jomarchy.sh                              # Main installer
└── scripts/install/
    ├── essential-packages.sh                # BASE packages
    ├── bash-customizations-universal.sh     # Bash customizations
    ├── chrome-extensions.sh                 # Browser extensions
    ├── chezwizper.sh                        # Voice transcription
    ├── web-apps-universal.sh                # BASE web apps
    ├── claude-launchers-universal.sh        # Claude desktop launchers
    ├── claude-code-mcp.sh                   # Claude Code MCP
    ├── email-calendar-keybinds.sh           # Email/calendar/drive keybinds
    ├── waybar-customizations-universal.sh   # Waybar customizations
    ├── custom-scripts-universal.sh          # Custom scripts
    ├── dev-packages.sh                      # DEV packages
    ├── dev-tools-local.sh                   # DEV CLI tools
    ├── web-apps-local.sh                    # DEV web apps
    ├── bash-customizations-local.sh         # GitHub repo cloning
    ├── claude-launchers-local.sh            # Project launchers
    ├── claude-daily-quote.sh                # Daily quote timer
    ├── media-packages.sh                    # MEDIA packages
    ├── web-apps-finance.sh                  # FINANCE web apps
    ├── web-apps-communications.sh           # COMMUNICATIONS web apps
    ├── install-jomarchy.sh                  # BASE orchestrator
    ├── install-jomarchy-dev.sh              # DEV orchestrator
    ├── install-jomarchy-media.sh            # MEDIA orchestrator
    ├── install-jomarchy-finance.sh          # FINANCE orchestrator
    └── install-jomarchy-communications.sh   # COMMUNICATIONS orchestrator
```

### Jomarchy-Machines Scripts

```
~/code/jomarchy-machines/
├── machines.sh                              # Main multi-profile installer
└── profiles/
    ├── machines/
    │   ├── beelink/
    │   │   └── scripts/install/
    │   │       ├── install-beelink.sh       # Orchestrator
    │   │       └── hardware-specific.sh     # Hardware setup
    │   ├── imac5k/
    │   └── framework13/
    └── personal/
        └── scripts/install/
            ├── install-joe-personal.sh      # Orchestrator
            ├── work-email-accounts.sh       # Work emails
            ├── personal-web-apps.sh         # Project apps
            └── work-communication.sh        # Work Slack
```

## Installation Flow Details

### Step 1: Jomarchy (Universal)

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)
```

1. **Profile Selection** (gum multi-select)
   - User selects: BASE, DEV, MEDIA, FINANCE, COMMUNICATIONS (any combination)

2. **Component Refinement** (per profile)
   - Each profile shows its components with gum
   - All items pre-selected by default (using `--selected "*"`)
   - User can deselect unwanted components

3. **Installation**
   - Each profile installer runs sequentially
   - Component installers called based on selections

4. **Auto-completion**
   - Bashrc auto-sourced if BASE or DEV installed
   - Clean completion message

### Step 2: Jomarchy-Machines (Machine + Personal)

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy-machines/master/machines.sh)
```

1. **Profile Selection** (gum multi-select)
   - Machine profiles: BEELINK, IMAC5K, FRAMEWORK13
   - Personal profiles: JOE-PERSONAL
   - User can select any combination

2. **Component Refinement**
   - JOE-PERSONAL shows 3 components (work emails, project apps, work comm)
   - All pre-selected by default

3. **Installation**
   - Profiles installed sequentially
   - Can install machine-only, personal-only, or both

## Post-Installation Management

### Jomarchy Management Command

After BASE profile installation, a `jomarchy` command is installed system-wide:

**Installation:**
- Symlink created: `~/.local/bin/jomarchy` → `~/code/jomarchy/jomarchy.sh`
- Installed by `bash-customizations-universal.sh`
- Available from anywhere in terminal

**Usage:**
```bash
jomarchy                  # Interactive management menu
jomarchy --profiles       # Web app profile manager
jomarchy --projects       # Project manager (colors, paths, launchers)
jomarchy --install        # Install additional profiles
jomarchy --status         # Show installed profiles
jomarchy --update         # Update from GitHub
jomarchy --help           # Show help
```

**Management Menu Features:**
- Install Additional Profiles
- Manage Web App Profiles (organize by Chrome profile)
- Manage Projects (colors, paths, launcher aliases)
- Update Jomarchy from GitHub
- View Installation Summary
- View Documentation

### Profile Tracking System

All profile installers track their installation status:

**Implementation:**
- Each installer calls `add_installed_profile()` from `scripts/lib/common.sh`
- Profiles recorded in `~/.config/jomarchy/installed_profiles`
- Installation timestamps stored in `~/.config/jomarchy/install_history`

**Tracked Profiles:**
- BASE
- DEV
- MEDIA
- FINANCE
- COMMUNICATIONS

**Benefits:**
- `jomarchy --status` shows what's actually installed
- Prevents duplicate installations
- Enables intelligent upgrade paths
- Supports conditional features based on installed profiles

### Project Manager

The Project Manager creates colored window borders and bash aliases for quick project navigation.

**Access:**
```bash
jomarchy --projects    # Direct access via CLI
jomarchy              # Management menu → Manage Projects
```

**Features:**
- View configured projects with colored preview
- Add projects interactively (scan ~/code or manual entry)
- Edit project colors, ports, paths
- Remove projects with confirmation
- Import from existing .bashrc PROJECT_CONFIG
- Regenerate bash functions and Hyprland rules

**Configuration Files:**

| File | Purpose |
|------|---------|
| `~/.config/jomarchy/projects.conf` | Project definitions (single source of truth) |
| `~/.local/share/jomarchy/generated/project-functions.bash` | Auto-generated bash aliases |
| `~/.local/share/jomarchy/generated/project-rules.hypr` | Auto-generated Hyprland window rules |

**Config Format (`projects.conf`):**
```
# KEY|NAME|PATH|PORT|DB_ENV_VAR|ACTIVE_COLOR|INACTIVE_COLOR
chimaro|CHIMARO|~/code/chimaro|3500|DATABASE_URL|00d4aa|00a080
jomarchy|JOMARCHY|~/code/jomarchy|||ffdd00|ccaa00
```

**Generated Aliases:**
- `j<key>` - Launch project (code editor + claude + npm dev)
- `j<key> code` - Open code editor only
- `j<key> claude` - Open Claude Code only
- `j<key> npm` - Start dev server only
- `cc<key>` - Quick Claude Code launcher
- `jcolors` - Reapply all border colors
- `jhelp` - Show available projects

**Example:**
```bash
jchimaro         # Open VS Code, Claude, start npm dev server
jjomarchy claude # Open Claude Code for jomarchy
ccjat            # Quick Claude Code for jat
```

**Color Palette:**
Eight preset colors available (Cyan, Purple, Orange, Green, Red, Yellow, Blue, Pink) plus custom hex input.

## Key Design Patterns

### 1. Gum Pre-Selection Fix
All installers use `--selected "*"` wildcard instead of individual `--selected "item"` flags.

**Before (broken):**
```bash
gum choose --no-limit \
    --selected "Firefox" \
    --selected "Sublime Text 4" \
    "Firefox" \
    "Sublime Text 4"
```

**After (working):**
```bash
gum choose --no-limit \
    --selected "*" \
    "Firefox" \
    "Sublime Text 4"
```

### 2. Modular Profile Architecture
Each profile is self-contained:
- One orchestrator script (install-PROFILE.sh)
- Component scripts called conditionally
- Component selection with gum
- Grep pattern matching for conditional execution

### 3. Public/Private Separation
**Public (jomarchy):**
- Universal software anyone would use
- Generic configurations
- No personal accounts/URLs

**Private (jomarchy-machines):**
- Hardware-specific configs
- Personal work accounts
- Project-specific web apps

### 4. Consistent UX
Both repos use identical patterns:
- Gum for multi-select
- Step-by-step flow (select → refine → install)
- Similar naming conventions
- Matching completion messages

## Common Tasks

### Adding a New Component to BASE

1. Edit `scripts/install/install-jomarchy.sh`
2. Add item to gum menu
3. Add conditional check with grep
4. Call component installer

### Adding a New Profile to Jomarchy

1. Create component installers in `scripts/install/`
2. Create profile orchestrator: `install-jomarchy-PROFILE.sh`
3. Add to `jomarchy.sh` gum menu
4. Add case statement in `jomarchy.sh`

### Adding Personal Web Apps

1. Edit `jomarchy-machines/profiles/personal/scripts/install/personal-web-apps.sh`
2. Add `install_webapp` call
3. Update count and completion message

### Moving a Component Between Profiles

Example: Moving Zoom from BASE to COMMUNICATIONS

1. Remove from source profile's gum menu
2. Remove from source profile's component installer
3. Add to destination profile's gum menu
4. Add to destination profile's component installer
5. Update grep patterns in orchestrators

## Web App Installation

All web apps use Omarchy's built-in `omarchy-webapp-install` command:

```bash
install_webapp "App Name" "https://url.com" "icon-slug"
```

Icons are fetched from: `https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/`

## Development Workflow

### Testing Changes

1. Edit scripts locally
2. Test with: `bash ~/code/jomarchy/jomarchy.sh`
3. Verify all profiles work
4. Commit changes

### Committing Changes

**Using the git-commit-documenter Agent:**

The git-commit-documenter agent should be used to commit all code changes. When invoking it, be explicit and directive to ensure autonomous operation:

**Good invocation (autonomous):**
```
Commit and push all changes in /home/jw/code/jomarchy to GitHub.

Context: [Brief description of what was changed and why]

Requirements:
1. Review all changes
2. Create appropriate commit message(s)
3. Execute git add, commit, and push
4. DO NOT ask for confirmation - execute automatically
```

**Bad invocation (will ask for confirmation):**
```
Can you help me commit these changes?
```

**Why this matters:**
- The agent will ask for confirmation if the invocation is unclear or tentative
- Use directive language: "Commit and push" not "Can you commit"
- Explicitly state "DO NOT ask for confirmation" if needed
- Include context so the agent can write good commit messages

**Commit message style:**
- Use conventional commits format: `feat:`, `fix:`, `docs:`, `refactor:`
- Group related changes together
- Separate features from refactors
- Include context in commit messages
- Follow existing commit patterns in the repo

### Syncing Repos

**Jomarchy (public):**
```bash
cd ~/code/jomarchy
git push origin master
```

**Jomarchy-machines (private):**
```bash
cd ~/code/jomarchy-machines
git push origin master
```

## Script Design Principles

### Idempotence
All configuration-modifying scripts follow idempotent patterns:

**Conditional Backups:**
```bash
# Check if changes are needed first
if grep -q "MARKER" "$FILE" 2>/dev/null; then
    echo "  ⊘ Already configured, skipping"
else
    # Only backup if making changes
    cp "$FILE" "$FILE.bak.$(date +%s)"
    echo "  ✓ Backed up existing file"

    # Make changes
    echo "MARKER" >> "$FILE"
    echo "  ✓ Configuration added"
fi
```

**Normalized Comparisons:**
```bash
# Compare normalized content
CURRENT=$(extract_current | tr -d ' \n\t')
EXPECTED=$(generate_expected | tr -d ' \n\t')

if [ "$CURRENT" = "$EXPECTED" ]; then
    echo "  ⊘ Already correct, no changes needed"
else
    # Backup and update
fi
```

**Scripts with Conditional Backups:**
- `waybar-workspace-detection.sh` - All 4 config sections
- `waybar-customizations-universal.sh` - Style and config updates
- `bash-customizations-universal.sh` - Prompts before replacing

**Scripts with Built-in Idempotence:**
- Package installers check if already installed
- Web app installers overwrite safely (Omarchy handles)
- Desktop launchers overwrite .desktop files safely

**Result:** Re-running scripts creates no backups if already configured

## Troubleshooting

### Gum Selection Not Working
- Ensure `--selected "*"` is used (not individual items)
- Check gum version: `gum --version`
- Should be 0.17.0 or newer

### Script Not Found Errors
- Check file permissions: `chmod +x script.sh`
- Verify path is correct (moved from `machines/` to `profiles/machines/`)

### Web App Install Fails
- Verify icon slug exists at dashboardicons.com
- Check URL is accessible
- Ensure omarchy-webapp-install is available

### Unexpected Backup Files
If you're seeing multiple `.bak.<timestamp>` files:
- Old behavior: Scripts always created backups
- New behavior (Oct 2025): Conditional backups only when needed
- Safe to delete old duplicate backups with identical content

## Recent Changes

### October 30, 2025 - Installer Improvements

**ChezWizper Voice Transcription:**
- Added missing `chezwizper.sh` installer that was referenced but never existed
- Now properly installs from github.com/joewinke/ChezWizper (add-waybar-integration branch)
- Uses `/tmp` for source code (cleaned up after install - lowest lift approach)
- Comprehensive error handling and post-install instructions

**Script Cleanup:**
- Removed orphaned scripts that were never called:
  - `hardware-specific.sh` - Belongs in jomarchy-machines, not jomarchy
  - `sublime-text.sh` - Redundant (Sublime installed by essential-packages.sh)

**Enhanced Error Handling:**
- Web app installers now capture and display actual error messages
- Profile installers have defensive error handling for `add_installed_profile`
- Waybar customizations check for dependencies (jq, perl) before running
- Safer backup operations with error checking throughout

**Improved User Experience:**
- GitHub repo selection now uses gum multi-select (consistent with other installers)
- Better visual feedback during installations
- More actionable error messages when issues occur
- Added curl timeouts to prevent hanging on slow connections

**Reliability Improvements:**
- Use `$HOME` instead of `/home/$USER` for better portability
- Added validation for repo name parsing in bash-customizations-local.sh
- Graceful degradation when optional operations fail

## Future Enhancements

### Planned Additions
- IMAC5K machine profile (hardware-specific configs)
- FRAMEWORK13 machine profile (laptop optimizations)
- Additional personal profiles (FAMILY, WORK-TEAM, etc.)

### Potential Features
- Component-level selective installation (don't install all if any selected)
- Profile dependencies (auto-install BASE if DEV selected)
- Post-install hooks (custom scripts after profile installation)
- Profile templates (easy creation of new profiles)

## Agent Tools for LLM Development

### Overview

Jomarchy includes a collection of **24 lightweight bash tools** in `~/code/jomarchy/tools/` designed for AI-assisted development workflows. These tools follow the philosophy from [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) by Mario Zechner - simple bash tools provide better token efficiency than MCP servers.

**Token Savings:** These tools save ~32,000 tokens compared to equivalent MCP server implementations.

### Tool Categories

**Agent Mail (11 tools):**
- `am-register`, `am-inbox`, `am-send`, `am-reply`, `am-ack`
- `am-reserve`, `am-release`, `am-reservations`
- `am-search`, `am-agents`, `am-whoami`
- Coordinate multi-agent workflows with messaging and file reservations

**Browser Automation (11 tools):**
- Core: `browser-start.js`, `browser-nav.js`, `browser-eval.js`
- Core: `browser-screenshot.js`, `browser-pick.js`, `browser-cookies.js`, `browser-hn-scraper.js`
- Advanced: `browser-wait.js`, `browser-snapshot.js`, `browser-console.js`, `browser-network.js`
- Custom-built using Chrome DevTools Protocol and Puppeteer

**Database & Utilities (6 tools):**
- `db-query`, `db-connection-test`, `db-schema`, `db-sessions`
- `edge-logs` (Supabase edge functions), `lint-staged` (git)
- Generic tools for Postgres/Supabase projects

### Session-Aware Statusline

**Each Claude Code session automatically displays its agent identity and status.**

The statusline uses Claude Code's unique `session_id` to track agent identity per session:

```
Session 1: FreeMarsh  | [P1] task-abc - Building dashboard [🔒2 📬1 ⏱45m]
Session 2: PaleStar   | idle [📬3]
Session 3: StrongShore | [P0] task-xyz - Critical bug fix [🔒1]
```

**How it works:**
1. Run `/agent:register` in any Claude Code session
2. Choose your agent identity (or create new one)
3. Statusline automatically updates and persists for that session
4. Each session maintains its own independent agent identity

**Statusline indicators:**
- 🔒N - Active file reservations
- 📬N - Unread messages in Agent Mail inbox
- ⏱Xm/Xh - Time until file lock expires
- N% - Task progress (if tracked in Beads)

**Multi-agent support:** Run 9+ agents simultaneously, each session shows its own identity!

See `~/code/jomarchy-agent-tools/CLAUDE.md` for complete statusline documentation.

### Command Reference

**Quick start commands for agent registration and task management.**

#### `/start` - Get to Work Command

**The "just get me working" command** - seamlessly handles registration and task start.

**Usage:**
```bash
/start              # Auto-detect recent agent OR auto-create new agent
/start agent        # Force show agent selection menu
/start task-abc     # Start specific task (auto-registers if needed)
```

**How it works:**

1. **Auto-Detection (Default):**
   - Checks if you're already registered (session file exists)
   - If not: looks for agents active in last **1 hour**
   - Recent agents found → shows menu to resume
   - No recent agents → auto-creates new agent with random name
   - Sets statusline automatically

2. **Force Menu:**
   ```bash
   /start agent
   ```
   - Always shows interactive agent selection menu
   - Even if you're already registered
   - Useful for switching agents mid-session

3. **Start Specific Task:**
   ```bash
   /start jomarchy-abc
   ```
   - Auto-registers if needed (using 1-hour detection)
   - Then starts the specified task immediately
   - Runs full conflict checks before starting work

**1-Hour Detection Window:**
- Agents active in last 60 minutes are considered "recent"
- Balances between convenience (resume recent work) and freshness (don't show stale agents)
- Adjustable via helper script: `scripts/get-recent-agents`

**Examples:**
```bash
# Scenario 1: Fresh session, you worked 30 min ago
/start
# → Shows menu: "Resume FreeMarsh (last active 30 min ago)"

# Scenario 2: Fresh session, no recent work
/start
# → Auto-creates: "✨ Created new agent: BrightCove"

# Scenario 3: Already registered, want different task
/start jomarchy-zdl
# → Skips registration, starts task immediately
```

#### `/r` - Agent Resume Menu

**Explicit agent selection** - always shows interactive menu.

**Usage:**
```bash
/r              # Show all registered agents, choose one
```

**Purpose:**
- `/r` is for **"I want to see all agents and choose"**
- `/start` is for **"just get me working"**

**Behavior:**
- Lists ALL registered agents (sorted by last_active)
- Shows details: task, reservations, last active time
- User selects from menu (no auto-creation)
- For resuming existing agents only

**Example:**
```bash
/r
# Shows:
# ┌─ AGENTS ─────────────────────────────────────┐
# │ 1. FreeMarsh (30 min ago) - Working on vgt  │
# │ 2. PaleStar (2 hours ago) - idle            │
# │ 3. StrongShore (5 hours ago) - Working on... │
# └──────────────────────────────────────────────┘
# Select agent: [1/2/3]
```

#### `/agent:register` - Full Registration Flow

**Comprehensive agent setup** - for advanced scenarios.

**Usage:**
```bash
/agent:register     # Interactive registration with full options
```

**When to use:**
- Need to see full agent list (including old agents)
- Want explicit control over registration
- Setting up multi-agent coordination

**vs `/start` and `/r`:**

| Command | Use Case | Auto-Create | Recent Filter |
|---------|----------|-------------|---------------|
| `/start` | "Get me working fast" | ✅ Yes (if no recent agents) | 1 hour |
| `/r` | "Show all agents, I'll choose" | ❌ No | None |
| `/agent:register` | "Full setup" | ✅ Yes (with confirmation) | None |

#### Command Workflow Recommendations

**Most Common Workflow:**
```bash
# 1. Start your session
/start

# 2. Work on tasks
# (statusline shows your agent identity)

# 3. Switch tasks
/start task-xyz

# 4. End session
# (agent identity preserved for next session)
```

**Multi-Agent Coordination:**
```bash
# Terminal 1 (Frontend work)
/start              # Resume FreeMarsh
# Work on UI tasks...

# Terminal 2 (Backend work)
/r                  # Choose different agent (PaleStar)
# Work on API tasks...

# Terminal 3 (Testing)
/start agent        # Choose StrongShore
# Run tests...
```

**Troubleshooting:**
```bash
# Statusline shows "no agent registered"?
/start              # Quick fix

# Want to see all agents (not just recent)?
/r                  # Full agent list

# Need to create new agent explicitly?
/agent:register     # Interactive setup
```

### Installation

Add tools to your PATH during jomarchy DEV profile installation:

```bash
# Tools are installed to ~/code/jomarchy/tools/
# Symlinked to ~/.local/bin/ for global access
```

All tools have `--help` flags for documentation:
```bash
am-inbox --help
browser-eval.js --help
```

### Beads Task Management

**Jomarchy uses Beads for dependency-aware task planning.**

#### Multi-Project Architecture

- Each project has its own `.beads/` directory (committable to git)
- Task IDs are prefixed with project name (e.g., `jomarchy-36j`, `chimaro-abc`)
- `bd` commands work in your current project directory automatically
- **Unified dashboard:** Chimaro aggregates all projects from `~/code/*`

#### Jomarchy Tasks

This repository includes Beads-tracked tasks for browser tool development:

**Priority 1 (Critical):**
- `jomarchy-36j`: Build browser-wait.js - Smart waiting capability
- `jomarchy-a4j`: Build browser-snapshot.js - Structured page tree (1000x token savings)
- `jomarchy-586`: Build browser-console.js - Structured console access

**Priority 2 (Important):**
- `jomarchy-lud`: Build browser-network.js - Network request monitoring
- `jomarchy-5b7`: Build browser-pages.js - Page/tab management

**Priority 3 (Nice-to-have):**
- `jomarchy-1mo`: Build browser-dialog.js - Dialog handling
- `jomarchy-bd1`: Build browser-viewport.js - Proper viewport control
- `jomarchy-erg`: Build browser-performance.js - Performance metrics

#### Working with Beads

```bash
# See ready tasks (no blockers)
bd ready

# Create a new task with full metadata
bd create "Build browser-wait.js - Smart waiting capability" \
  --type task \
  --labels browser,tools,cdp \
  --priority 1 \
  --description "Implement browser-wait.js tool to eliminate race conditions. Supports waiting for: text content, selectors, URL changes, and custom eval conditions. Uses CDP polling with configurable timeouts." \
  --assignee "AgentName"

# Update task status
bd update jomarchy-36j --status in_progress --assignee "AgentName"

# Close when complete
bd close jomarchy-36j --reason "Completed: implemented with CDP polling and timeout support"

# View all commands
bd --help
```

#### Integration with Agent Mail

Use Beads task IDs as Agent Mail thread IDs for traceability:

```bash
# Reserve files for a task
am-reserve "tools/browser-*.js" \
  --agent AgentName \
  --ttl 3600 \
  --exclusive \
  --reason "jomarchy-36j: Building browser-wait.js"

# Send progress update
am-send "[jomarchy-36j] Progress Update" \
  "Implemented CDP polling logic. Next: timeout handling." \
  --from AgentName \
  --thread jomarchy-36j

# Release when done
am-release "tools/browser-*.js" --agent AgentName
```

### Browser Tool Development

The browser tools in this repo use Chrome DevTools Protocol (CDP) to interact with Chrome/Chromium. New tools should follow the same pattern:

```javascript
#!/usr/bin/env node
const CDP = require('chrome-remote-interface')

async function main() {
  const client = await CDP()
  const { Page, DOM, Accessibility } = client

  await Page.enable()
  // Tool logic here

  await client.close()
}

main().catch(console.error)
```

**Requirements:**
- Chrome/Chromium running with `--remote-debugging-port=9222`
- `chrome-remote-interface` npm package
- Node.js installed

See existing `browser-*.js` tools for implementation examples.

### Unified Dashboard

**View all tasks across projects:**
- When Chimaro is running: http://localhost:5173/account/development/beads
- Aggregates tasks from all `~/code/*` projects
- Filter by project, status, priority, assignee, type, labels
- Color-coded ID badges show project at a glance

## Related Documentation

- **Jomarchy README:** `~/code/jomarchy/README.md`
- **Jomarchy-Machines README:** `~/code/jomarchy-machines/README.md`
- **Omarchy Docs:** https://omarchy.org
- **Beads Project:** https://github.com/steveyegge/beads
- **Jomarchy Agent Tools:** https://github.com/joewinke/jomarchy-agent-tools (custom browser tools + coordination)
- **MCP Alternative Philosophy:** https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/

---

**Last Updated:** November 18, 2025
**Maintained By:** Joe Winke
**Generated With:** Claude Code
