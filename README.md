```
.·:''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''':·.
: :                                                                                               : :
: :         _____   ______   __       __   ______   _______    ______   __    __  __      __      : :
: :        |     \ /      \ |  \     /  \ /      \ |       \  /      \ |  \  |  \|  \    /  \     : :
: :         \$$$$$|  $$$$$$\| $$\   /  $$|  $$$$$$\| $$$$$$$\|  $$$$$$\| $$  | $$ \$$\  /  $$     : :
: :           | $$| $$  | $$| $$$\ /  $$$| $$__| $$| $$__| $$| $$   \$$| $$__| $$  \$$\/  $$      : :
: :      __   | $$| $$  | $$| $$$$\  $$$$| $$    $$| $$    $$| $$      | $$    $$   \$$  $$       : :
: :     |  \  | $$| $$  | $$| $$\$$ $$ $$| $$$$$$$$| $$$$$$$\| $$   __ | $$$$$$$$    \$$$$        : :
: :     | $$__| $$| $$__/ $$| $$ \$$$| $$| $$  | $$| $$  | $$| $$__/  \| $$  | $$    | $$         : :
: :      \$$    $$ \$$    $$| $$  \$ | $$| $$  | $$| $$  | $$ \$$    $$| $$  | $$    | $$         : :
: :       \$$$$$$   \$$$$$$  \$$      \$$ \$$   \$$ \$$   \$$  \$$$$$$  \$$   \$$     \$$         : :
: :                                                                                               : :
'·:...............................................................................................:·'
```

# Jomarchy - Omarchy Linux Power Tools

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Profiles](https://img.shields.io/badge/Profiles-5-blue)](#-what-is-jomarchy)
[![Tools](https://img.shields.io/badge/Tools-43-purple)](#-developer-tools-ai-assisted-development)
[![Beads](https://img.shields.io/badge/Beads-Enabled-orange)](https://github.com/steveyegge/beads)
[![Sister Project](https://img.shields.io/badge/Sister-jomarchy--agent--tools-green)](https://github.com/joewinke/jomarchy-agent-tools)

**Transform a fresh Omarchy Linux installation into a fully-configured workstation with one command.**

Profile-based installation system (BASE + DEV + MEDIA + FINANCE + COMMUNICATIONS) with intelligent workspace detection, theme-aware customizations, and integrated web app management. Plus 43 bash tools for AI-assisted development.

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)
```

---

## ⚡ Quick Start

```bash
# 1. Install (one command, requires wifi)
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)

# 2. Select profiles interactively
# ☑ BASE (recommended)
# ☐ DEV (software development)
# ☐ MEDIA (creative work)
# ☐ FINANCE (banking/accounting)
# ☐ COMMUNICATIONS (messaging)

# 3. Restart shell
source ~/.bashrc

# 4. Manage post-installation
jomarchy --profiles  # Organize web apps by Chrome profile
```

**Configured workstation in 5 minutes!** The installer presents interactive menus, installs your selected profiles, and sets up the `jomarchy` command for ongoing management.

---

## What Is Jomarchy?

Jomarchy is a **profile-based installation system** for Omarchy Linux that transforms a minimal system into a fully-configured workstation:

- **Choose** from 5 modular profiles (BASE, DEV, MEDIA, FINANCE, COMMUNICATIONS)
- **Select** components within each profile via interactive gum menus
- **Configure** intelligent multi-monitor workspaces (1-3 monitors)
- **Organize** web apps by Chrome profile (work vs personal)
- **Manage** with unified `jomarchy` command for updates and configuration

### 🏗️ Architecture

```
┌───────────────────────────────────────────────────┐
│                  Fresh Omarchy                    │
│            (Hyprland + Waybar + Arch)             │
└─────────────────┬─────────────────────────────────┘
                  │
                  ▼
         ┌────────────────────┐
         │  Profile Selector  │  Interactive gum menu
         │   jomarchy.sh      │  Multi-select profiles
         └────────┬───────────┘
                  │
    ┌─────────────┼─────────────┬─────────────┬─────────────┐
    │             │             │             │             │
    ▼             ▼             ▼             ▼             ▼
┌───────┐    ┌───────┐    ┌───────┐    ┌──────────┐  ┌─────────────┐
│ BASE  │    │  DEV  │    │ MEDIA │    │ FINANCE  │  │ COMMS       │
└───┬───┘    └───┬───┘    └───┬───┘    └────┬─────┘  └──────┬──────┘
    │            │            │             │               │
    │            │            │             │               │
    ▼            ▼            ▼             ▼               ▼
Packages +  VSCodium +   GIMP    +   Banking   +    Discord
Waybar   +  GitHub   +   OBS     +   QuickBooks +   Slack
Chrome   +  Node.js  +   Blender +             +   WhatsApp
Shortcuts+  43 Tools +           +             +   Gmail
```

**How it works:**
1. **Interactive Selection** - Choose profiles via gum multi-select
2. **Component Menus** - Each profile offers fine-grained control
3. **Intelligent Setup** - Auto-detects monitors, applies theme colors
4. **Web App Management** - Organize apps by Chrome profile
5. **Ongoing Management** - `jomarchy` command for updates and config

---

## Why Use Jomarchy?

### The Problem

Fresh Linux installations face three challenges:

1. **Manual tedium**: Installing packages, configuring shortcuts, setting up workspaces
2. **Inconsistency**: Different setups across machines, forgotten customizations
3. **No organization**: Web apps scattered across profiles, no structure

### The Solution

**Jomarchy automates and organizes everything:**

| Challenge | Solution | Benefit |
|-----------|----------|---------|
| Manual tedium | Profile-based automation | 5-minute setup vs 2-hour manual |
| Inconsistency | Version-controlled configs | Same setup everywhere |
| No organization | Web app profile manager | Work/personal separation |

**Real-world impact:**
- **Modular profiles** - Install only what you need (BASE only = minimal system)
- **Theme-aware** - Waybar colors auto-sync with Omarchy theme
- **Multi-monitor ready** - Intelligent workspace detection (1-3 monitors)
- **Post-install management** - `jomarchy` command for ongoing config

---

## 🎯 Profile Overview

### Core Profile

**BASE** - Universal foundation (recommended for everyone)
- Essential packages (Sublime Text, yt-dlp, Tailscale, ChezWizper voice transcription)
- Bash customizations (`cl`, `cp` aliases for Claude Code)
- Waybar theme-aware styling with intelligent workspace detection
- Custom scripts (Super+Z zoom, F4 file search, Hyprsunset blue light filter)
- Web apps (Proton Mail, Kagi, YouTube, X)
- Chrome extensions (Dark Reader, Copy on Select, 1Password)

### Optional Profiles

**DEV** - Software development
- VSCodium (de-Microsoft-ified VS Code)
- Node.js, GitHub CLI, Stripe CLI, Supabase CLI
- 43 bash tools for AI-assisted workflows (Agent Mail + Beads + browser automation)
- Interactive GitHub repo cloning + auto-generated project shortcuts
- Web apps (GitHub, Cloudflare, Supabase)

**MEDIA** - Creative tools
- Graphics: GIMP, Inkscape
- Video: OBS Studio, Shotcut, Kdenlive
- 3D: Blender
- Audio: Audacity

**FINANCE** - Banking & accounting
- Web apps: Bank of America, Chase, Capital One, QuickBooks Online

**COMMUNICATIONS** - Messaging & collaboration
- Web apps: Discord, WhatsApp, Slack, Gmail, Zoom

---

## Installation

### One-Line Install (Fresh Omarchy System)

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)
```

This:
- ✅ Installs git if needed
- ✅ Clones repository to ~/code/jomarchy
- ✅ Presents interactive profile selector
- ✅ Installs selected profiles with component menus
- ✅ Sets up `jomarchy` command for management

**Time:** ~5 minutes (depending on profile selection) | **Requires:** Omarchy Linux, wifi

### Manual Installation

Already have the repository cloned?

```bash
cd ~/code/jomarchy
./jomarchy.sh  # Interactive selector

# Or install specific profiles directly:
./scripts/install/install-jomarchy.sh              # BASE
./scripts/install/install-jomarchy-dev.sh          # DEV
./scripts/install/install-jomarchy-media.sh        # MEDIA
./scripts/install/install-jomarchy-finance.sh      # FINANCE
./scripts/install/install-jomarchy-communications.sh # COMMUNICATIONS
```

---

## What Gets Installed

### 1. BASE Profile Components

**Core Packages (Selectable via gum menu):**
- Firefox & Chromium (pre-installed by Omarchy)
- Sublime Text 4 - Fast text editor
- Claude Code - AI-powered CLI coding assistant
- yt-dlp - Video downloader
- Tailscale - VPN/mesh network
- nwg-displays - Multi-monitor display manager
- JetBrains Mono - Programming font
- ChezWizper - Voice transcription with Super+R

**Bash Customizations:**
```bash
~/code/linux          # System projects directory
~/code/personal       # Personal projects directory
cl                    # Alias: cd to ~/code/linux + launch Claude Code
cp                    # Alias: cd to ~/code/personal + launch Code
tget                  # Alias: Tailscale file download to ~/Downloads/
```

**Waybar Customizations (Automatic):**
- **Theme-aware accent colors** - Auto-extracts `@selected-text` from active theme
  - Works with ALL themes (Kanagawa, Gruvbox, Tokyo Night, Matte Black, etc.)
  - Change theme → Waybar colors update automatically
- **Intelligent workspace detection** - Auto-configures for 1-3 monitors:
  - 1 monitor: workspaces 1-10
  - 2 monitors: 1-10 (left), 11-20 (right)
  - 3 monitors: 1-10 (left), 11-20 (center), 21-30 (right)
- **Workspace color coding** - Visual identification per monitor:
  - Monitor 1: Green (#99d9ab)
  - Monitor 2: Cyan (#00ffcc)
  - Monitor 3: Magenta (#ff00ff)
- **Active workspace highlighting** - Theme accent colors with transparency
- Updates `~/.config/waybar/config.jsonc`, `~/.config/waybar/style.css`
- Updates `~/.config/hypr/monitors.conf`, `~/.config/hypr/workspace-layouts.conf`

**Custom Scripts (Automatic):**
- `toggle-zoom` - **Super+Z** for 2x screen magnification
- `file-search` - **F4** for fuzzy file finder (fzf, searches ~/home)
- **Hyprsunset** - Blue light filter with auto-schedule:
  - 6:30 AM: Normal daylight (6500K)
  - 7:00 PM: Sunset warmth (5000K)
  - 9:00 PM: Bedtime mode (3400K)
- **Jomarchy screensaver** - Custom ASCII art branding (activated with **Super+L**)
- **Email/Calendar/Drive Keybinds** - Configure keybinds for your preferred email provider:
  - **Super+Shift+E** → Email
  - **Super+Shift+C** → Calendar
  - **Super+Shift+D** → Drive (when available)
  - Supported providers: Proton Mail, Gmail/Google, Hey, Outlook/Microsoft, Yahoo

**Chrome Extensions (Selectable via gum menu):**
- Dark Reader - Dark mode for all websites
- Copy on Select - Auto-copy highlighted text
- 1Password - Password manager

**ChezWizper Voice Transcription:**
- **Super+R** to activate
- Waybar indicator shows when active
- Works system-wide

**Desktop Application Shortcuts:**
- Claude.ai (Linux) - Desktop shortcut for ~/code/linux projects
- Claude.ai (Personal) - Desktop shortcut for ~/code/personal projects
- Claude Code MCP configuration - Chrome DevTools integration

**Web Apps (Selectable via gum menu):**
- Proton Mail - Encrypted email
- Kagi - Privacy-focused search
- YouTube - Video platform
- X (Twitter) - Social media

### 2. DEV Profile Components

**Development Tools (Selectable via gum menu):**
- **VSCodium** - Privacy-focused VS Code (de-Microsoft-ified, telemetry-free)
- **Node.js & npm** - JavaScript runtime
- **GitHub CLI** - Git operations from terminal
- **Stripe CLI** - Payment testing
- **Supabase CLI** - Backend/database management

**Development Features:**
- **Interactive GitHub repository cloning** - Select which repos to clone from your GitHub account
- **Auto-generated bash aliases** - Quick Claude Code access with `cc` + first letter (e.g., `ccj` for jomarchy, `ccm` for marduk)
- **Auto-generated project shortcuts** - Desktop shortcuts to launch Claude.ai for each cloned repo
- **Daily Claude quote timer** - Motivational quotes at 9am EST

**Development Web Apps (Selectable via gum menu):**
- GitHub - Code hosting
- Cloudflare - DNS and CDN management
- Supabase - Backend dashboard

### 3. MEDIA Profile Components

**Graphics (Selectable via gum menu):**
- GIMP - Image editing (Photoshop alternative)
- Inkscape - Vector graphics (Illustrator alternative)

**Video (Selectable via gum menu):**
- OBS Studio - Screen recording and live streaming
- Shotcut - Lightweight video editor
- Kdenlive - Advanced video editor

**3D (Selectable via gum menu):**
- Blender - 3D modeling, animation, rendering

**Audio (Selectable via gum menu):**
- Audacity - Audio editing and recording

### 4. FINANCE Profile Components

**Web Apps (Selectable via gum menu):**
- Bank of America - Online banking
- Chase Bank - Online banking
- Capital One - Online banking
- QuickBooks Online - Accounting and invoicing

### 5. COMMUNICATIONS Profile Components

**Web Apps (Selectable via gum menu):**
- Discord - Gaming and community chat
- WhatsApp - Messaging
- Slack - Team communication
- Gmail - Google email
- Zoom - Video conferencing

---

## 🤖 Developer Tools (AI-Assisted Development)

If you install the **DEV profile**, you get access to **43 lightweight bash tools** for AI-assisted development workflows:

### Agent Mail Tools (11 tools)
Multi-agent coordination with messaging and file reservations:
- `am-register`, `am-inbox`, `am-send`, `am-reply`, `am-ack`
- `am-reserve`, `am-release`, `am-reservations`
- `am-search`, `am-agents`, `am-whoami`

### Browser Automation Tools (11 tools)
Chrome DevTools Protocol automation:
- **Core**: `browser-start.js`, `browser-nav.js`, `browser-eval.js`, `browser-screenshot.js`, `browser-pick.js`, `browser-cookies.js`, `browser-hn-scraper.js`
- **Advanced**: `browser-wait.js` (smart waiting), `browser-snapshot.js` (1000x token savings), `browser-console.js` (debug JS), `browser-network.js` (API testing)

### Database & Utility Tools (21 tools)
Database queries, monitoring, media management, deployment helpers

**Philosophy:** Following [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) by Mario Zechner - simple bash tools save ~32,000 tokens vs MCP servers.

**Task Management with Beads:**
- This repository uses [Beads](https://github.com/steveyegge/beads) for dependency-aware task planning
- Multi-project support: Use Chimaro's dashboard to view tasks across all projects
- Git-backed storage: Tasks are committable to your repository

**For AI Assistants:**
- Full documentation in `CLAUDE.md`
- All tools have `--help` flags
- Integration patterns with Agent Mail + Beads

**Sister Project:** For standalone agent tools installer (works with any Linux system, not just Omarchy), see [jomarchy-agent-tools](https://github.com/joewinke/jomarchy-agent-tools)

---

## 🔧 Managing Your Installation

After installation, manage everything with the `jomarchy` command:

### Interactive Menu

```bash
jomarchy
```

**Options:**
- Install Additional Profiles
- **Manage Web App Profiles** (organize apps by Chrome profile)
- Update Jomarchy
- View Installation Summary
- View Documentation

### Quick Commands

```bash
jomarchy --profiles    # Jump to web app profile manager
jomarchy --install     # Install additional profiles
jomarchy --update      # Update jomarchy from GitHub
jomarchy --status      # Show what's installed
jomarchy --help        # Show all options
```

### Web App Profile Manager

The integrated profile manager lets you:
- View which web apps use which Chrome profiles
- Move apps between profiles (single or bulk operations)
- Rename Chrome profiles
- View detailed profile information

**Use case:** Separate work apps (Slack, Gmail, Calendar) from personal apps (YouTube, Discord, X) by assigning them to different Chrome profiles.

---

## How It Works

### Profile Selection Flow

```
1. Run jomarchy.sh
   ↓
2. Select profiles (gum multi-select):
   ☑ BASE (recommended)
   ☐ DEV
   ☐ MEDIA
   ☐ FINANCE
   ☐ COMMUNICATIONS
   ↓
3. Each profile shows component menu:
   - Packages
   - Customizations
   - Web Apps
   - Extensions
   ↓
4. Installation runs selected components
   ↓
5. jomarchy command installed for management
```

### Intelligent Multi-Monitor Detection

Jomarchy auto-detects your monitor setup and configures Hyprland workspaces:

```bash
# Automatic detection based on connected monitors:

1 Monitor:
  Workspaces 1-10 on primary

2 Monitors:
  Workspaces 1-10 on left (green)
  Workspaces 11-20 on right (cyan)

3 Monitors:
  Workspaces 1-10 on left (green)
  Workspaces 11-20 on center (cyan)
  Workspaces 21-30 on right (magenta)
```

**Updates automatically** when you add/remove monitors.

### Directory Structure

```
~/.config/
├── waybar/
│   ├── config.jsonc           # Updated with workspaces
│   └── style.css              # Updated with theme colors
├── hypr/
│   ├── monitors.conf          # Auto-generated monitor config
│   └── workspace-layouts.conf # Auto-generated workspace config
└── ...

~/code/
├── jomarchy/                  # This repository
│   ├── jomarchy.sh           # Main installer
│   ├── scripts/install/      # Profile installers
│   ├── tools/                # 43 bash tools (DEV profile)
│   └── .beads/              # Task database
├── linux/                     # System projects (created by BASE)
└── personal/                  # Personal projects (created by BASE)

~/.local/bin/
└── jomarchy                   # Management command
```

---

## ✅ Benefits

1. **Profile-Based** - Choose exactly what you need (BASE, DEV, MEDIA, FINANCE, COMMUNICATIONS)
2. **Component Selection** - Fine-grained control via gum menus within each profile
3. **Idempotent** - Scripts can be run multiple times safely
4. **Modular** - Each component is independent and optional
5. **Theme-Aware** - Waybar colors auto-sync with Omarchy theme
6. **Multi-Monitor Ready** - Intelligent workspace detection (1-3 monitors)
7. **Organized** - Web app profile manager for work/personal separation
8. **Documented** - Detailed descriptions of every component

---

## 🚀 Next Steps After Installation

1. **Restart shell:** `source ~/.bashrc`
2. **Test ChezWizper:** Press `Super+R`
3. **Organize web apps:** Run `jomarchy --profiles`
4. **Test Claude aliases:** `cl` (linux projects), `cp` (personal projects)
5. **Launch file search:** Press `F4`
6. **Test zoom toggle:** Press `Super+Z`

---

## Requirements

- **OS:** Omarchy Linux
- **Shell:** Bash
- **Network:** Wifi (for installation)
- **Optional:** GitHub account (for DEV profile repo cloning)

---

## 📝 Notes

- All scripts are idempotent and can be run multiple times safely
- Gum menus allow selective installation within each profile
- All configurations are modular - install only what you need
- BASE profile recommended for everyone as foundation
- For hardware-specific configs, create your own profiles in `scripts/install/`

---

## Troubleshooting

### Waybar Colors Not Updating

```bash
# Re-run theme detection
cd ~/code/jomarchy
./scripts/install/waybar-customizations-universal.sh
```

### Workspaces Not Detected

```bash
# Re-run workspace detection
cd ~/code/jomarchy
./scripts/install/waybar-workspace-detection.sh
```

### Web App Profile Manager Issues

```bash
# Check Chrome profile directory
ls ~/.config/chromium/

# Re-run profile manager
jomarchy --profiles
```

### Tools Not Found (DEV profile)

```bash
# Check if tools are in PATH
which am-inbox

# Add to PATH if missing
echo 'export PATH="$HOME/code/jomarchy/tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Contributing

Contributions welcome! Please open issues or PRs.

**Areas for contribution:**
- Additional profiles (gaming, education, etc.)
- More customization scripts
- Theme support improvements
- Documentation enhancements

---

## ❓ FAQ

### Can I run this on non-Omarchy systems?

**Partially.** Most components work on any Arch-based system, but Waybar/Hyprland configs assume Omarchy's structure. For universal agent tools that work anywhere, see [jomarchy-agent-tools](https://github.com/joewinke/jomarchy-agent-tools).

### Can I install profiles separately?

**Yes!** Run specific installers:
```bash
./scripts/install/install-jomarchy-dev.sh
./scripts/install/install-jomarchy-media.sh
```

### How do I add custom packages?

Create your own profile in `scripts/install/` following the existing pattern. All profile scripts are modular and independent.

### Does this work with multiple machines?

**Yes!** Clone the repository on each machine and run `jomarchy.sh`. Your configs are version-controlled in the repository.

### How do I update to the latest version?

```bash
jomarchy --update
# Or manually:
cd ~/code/jomarchy
git pull origin master
```

---

## License

MIT License

---

## Credits

- **Omarchy Linux:** Created by [@DHH](https://github.com/dhh) and Basecamp - [github.com/basecamp/omarchy](https://github.com/basecamp/omarchy)
- **Jomarchy:** Assembled by [@joewinke](https://github.com/joewinke)

---

## Related Projects

- **jomarchy-agent-tools:** [github.com/joewinke/jomarchy-agent-tools](https://github.com/joewinke/jomarchy-agent-tools) - Standalone AI agent tools installer (works on any Linux)
- **Omarchy Linux:** [github.com/basecamp/omarchy](https://github.com/basecamp/omarchy) - The Linux distribution this is built for
- **Chimaro:** AI-powered application platform with unified Beads dashboard

---

**Built for Omarchy Linux. Transforms your system in 5 minutes.**

**[Install Now](#quick-start)** | **[Report Issue](https://github.com/joewinke/jomarchy/issues)** | **[Contribute](https://github.com/joewinke/jomarchy/pulls)**
