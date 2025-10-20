# OMARCHY-ALL: Base System Installation

This document defines what gets installed on **ANY** Omarchy system (laptop, desktop, VM, etc.).

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
- `chromium` - Already in Omarchy defaults

### Utilities
- `ydotool` - Input automation (required for ChezWizper)
- `yt-dlp` - YouTube downloader
- `tailscale` - Mesh VPN
- `nwg-displays` - Display configuration tool
- `ttf-jetbrains-mono` - JetBrains Mono font

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

### Visual Enhancements
- Custom clock format (mm-dd dow HH:MM)
- Window title rewriting for clean app names
- ChezWizper integration (6 scripts + CSS animations)

**Installation:** `scripts/install/waybar-customizations-universal.sh` ✅

---

## 🔧 Custom Scripts

**Location:** `~/.local/bin/`

1. **toggle-zoom** - Super+Z for 2x screen magnification
2. **screensaver-enable** - Super+L for lock/screensaver

**Installation:** `scripts/install/custom-scripts-universal.sh`

---

## ⌨️ Hyprland Custom Keybindings

Minimal custom keybindings (verify Omarchy 3.1 compatibility):

- **F4**: Global file search
- **Super+Z**: Toggle zoom magnification
- **Super+R**: ChezWizper voice transcription
- **Super+L**: Enable screensaver/lock

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

## 🚀 Claude Desktop Launchers (2 launchers)

Terminal launchers matching aliases:

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

**Total packages:** ~15 core packages + 10 web apps + 3 extensions
**Total scripts:** 9 installation scripts
**Directories created:** ~/code/linux, ~/code/personal, ~/.claude
**Aliases added:** cl, cp, tget (if Tailscale)
**Desktop launchers:** 2 (Claude Linux, Claude Personal)
**MCP servers:** 1 (Chrome DevTools)

---

## 🎯 Quick Install

Run the master installation script:
```bash
cd ~/code/linux
./scripts/install/install-omarchy-all.sh
```

This will execute all 8 universal installation scripts in the correct order.

---

## ✅ What This Gives You

A fully functional Omarchy system with:
- Development environment (VS Code, Node.js, Claude Code)
- Voice transcription (ChezWizper with Waybar)
- Essential web apps for productivity
- Custom keybindings and scripts
- Beautiful Waybar integration
- Personal workspace setup

**Perfect for:** Any Omarchy installation (laptop, desktop, VM)
