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

# Jomarchy - Joe's Omarchy Configuration

A modular post-install system for Omarchy Linux that transforms a fresh installation into a fully-configured development workstation.

---

## 🎯 Quick Start

### Fresh Omarchy Install (One Command)

As soon as wifi is connected, run:

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/jomarchy.sh)
```

This will:
1. Install git if needed
2. Clone the repository to ~/code/jomarchy
3. Run the default JOMARCHY installation
4. Optionally install DEV or BEELINK add-ons

---

## 📚 What Is Jomarchy?

**Jomarchy** is a profile-based installation system for Omarchy Linux. Select the profiles you want:

**Core Profile:**
- **BASE**: Universal configuration for any Omarchy system (packages, customizations, web apps)

**Optional Profiles:**
- **DEV**: Software development tools and GitHub integration
- **MEDIA**: Creative tools (graphics, video, 3D, audio)
- **FINANCE**: Banking and accounting web apps
- **COMMUNICATIONS**: Messaging and collaboration apps

Each profile uses interactive `gum` menus to let you select exactly which components to install. Everything is pre-selected by default, but you can deselect items you don't want.

---

## 📚 Documentation Files

### [JOMARCHY.md](JOMARCHY.md) - Default Installation ⭐
**What:** Complete Omarchy configuration for any system
**Includes:**
- Core packages (VS Code, Node.js, Firefox, claude-code, Sublime, Tailscale, etc.)
- ChezWizper voice transcription
- 10 universal web apps
- 3 Chrome extensions
- Waybar customizations
- cl/cp aliases + Claude launchers
- Custom scripts (zoom, screensaver, file search)

**Install:** `./scripts/install/install-jomarchy.sh`

---

### [JOMARCHY-DEV.md](JOMARCHY-DEV.md) - Development Add-on
**What:** Work-specific tools and projects (adds to JOMARCHY)
**Includes:**
- Dev tools (GitHub CLI, Stripe CLI, Supabase CLI)
- Interactive GitHub repository selection
- Auto-generated Claude aliases for your repos
- Work-specific web apps
- Daily Claude quote timer

**Install:** `./scripts/install/install-jomarchy-dev.sh`

---

## 🔄 Installation Model

```
Select Profiles (Multi-select with gum):
  ☑ BASE (recommended for everyone)
  ☐ DEV (software development)
  ☐ MEDIA (creative work)
  ☐ FINANCE (banking/accounting)
  ☐ COMMUNICATIONS (messaging/collaboration)
```

Each profile is modular and independent. Install any combination you need:
- **BASE only** = Complete minimal system
- **BASE + DEV** = Development workstation
- **BASE + MEDIA** = Creative workstation
- **All profiles** = Full-featured system

---

## 💻 Manual Installation

### Already Have Repository Cloned

#### Default Installation (Recommended)
```bash
cd ~/code/jomarchy
./scripts/install/install-jomarchy.sh
```

#### With Development Add-on
```bash
cd ~/code/jomarchy
./scripts/install/install-jomarchy-dev.sh
```

---

## 📊 What Gets Installed

All components below can be selectively installed via interactive gum menus. Everything is pre-selected by default, but you can deselect items you don't want.

### BASE Profile (Universal - For Everyone)

#### 🗂️ Core Packages
- **Firefox** - Web browser (pre-installed by Omarchy)
- **Chromium** - Alternative browser (pre-installed by Omarchy)
- **Sublime Text 4** - Fast text editor
- **Claude Code** - AI-powered CLI coding assistant
- **yt-dlp** - Video downloader (YouTube, etc.)
- **Tailscale** - VPN/mesh network
- **nwg-displays** - Multi-monitor display manager
- **JetBrains Mono** - Programming font
- **ydotool** - Auto-installed with ChezWizper

#### 🎨 Customizations

**Bash Customizations:**
- `~/code/linux` - Directory for system projects
- `~/code/personal` - Directory for personal projects
- `cl` - Alias: cd to ~/code/linux + launch Claude Code with --dangerously-skip-permissions
- `cp` - Alias: cd to ~/code/personal + launch Claude Code with --dangerously-skip-permissions
- `tget` - Alias: Tailscale file download to ~/Downloads/

**Waybar Customizations:**
- **Theme-aware accent colors** - Automatically extracts `@selected-text` from all Omarchy themes and applies to Waybar modules
  - Kanagawa: Orange accents
  - Gruvbox: Yellow accents
  - Tokyo Night: Cyan accents
- **Intelligent workspace detection** - Auto-configures for 1-3 monitors:
  - 1 monitor: workspaces 1-10
  - 2 monitors: 1-10 (left), 11-20 (right)
  - 3 monitors: 1-10 (left), 11-20 (center), 21-30 (right)
- **Workspace color coding** - Visual identification per monitor:
  - Monitor 1: Green (#99d9ab)
  - Monitor 2: Cyan (#00ffcc)
  - Monitor 3: Magenta (#ff00ff)
- **Active workspace highlighting** - Uses theme accent colors with transparency
- **Clock format** - Shows date (mm-dd weekday HH:MM)
- **Window title styling** - Current app name with theme accents
- Updates `~/.config/waybar/config.jsonc` and `~/.config/waybar/style.css`
- Updates `~/.config/hypr/monitors.conf` and `~/.config/hypr/workspace-layouts.conf`

**Custom Scripts:**
- `toggle-zoom` - **Super+Z** for 2x screen magnification
- `file-search` - **F4** for fuzzy file finder (fzf-based, searches ~/home excluding .git, .cache, node_modules)
- **Hyprsunset** - Blue light filter with auto-schedule:
  - 6:30 AM: Normal daylight (6500K)
  - 7:00 PM: Sunset warmth (5000K)
  - 9:00 PM: Bedtime mode (3400K)
- **Jomarchy screensaver** - Custom ASCII art branding (activated with **Super+L**)

#### 🌐 Applications

**Chrome Extensions:**
- Copy on Select - Auto-copy highlighted text
- Dark Reader - Dark mode for all websites
- 1Password - Password manager

**ChezWizper:**
- Voice transcription with **Super+R**
- Includes ydotool for text insertion
- Waybar indicator shows when active

**Claude Launchers:**
- Claude (Linux) - Desktop launcher for ~/code/linux projects
- Claude (Personal) - Desktop launcher for ~/code/personal projects
- Claude Code MCP configuration - Chrome DevTools integration

#### 🌐 Web Apps
- **Proton Mail** - Encrypted email
- **Kagi** - Privacy-focused search engine
- **YouTube** - Video platform
- **X (Twitter)** - Social media

### MEDIA Profile (Optional - Creative Work)

#### 🎨 Graphics
- **GIMP** - Image editing (Photoshop alternative)
- **Inkscape** - Vector graphics (Illustrator alternative)

#### 🎬 Video
- **OBS Studio** - Screen recording and live streaming
- **Shotcut** - Lightweight video editor
- **Kdenlive** - Advanced video editor

#### 🧊 3D
- **Blender** - 3D modeling, animation, and rendering

#### 🎵 Audio
- **Audacity** - Audio editing and recording

### FINANCE Profile (Optional - Banking & Accounting)

#### 🏦 Web Apps
- **Bank of America** - Online banking
- **Chase Bank** - Online banking
- **Capital One** - Online banking
- **QuickBooks Online** - Accounting and invoicing

### COMMUNICATIONS Profile (Optional - Messaging & Collaboration)

#### 💬 Web Apps
- **Discord** - Gaming and community chat
- **WhatsApp** - Messaging
- **Slack** - Team communication
- **Gmail** - Google email
- **Zoom** - Video conferencing

### DEV Profile (Optional - Software Development)

#### 🛠️ Development Tools
- **VS Code** - Full IDE
- **Node.js & npm** - JavaScript runtime
- **GitHub CLI** - Git operations from terminal
- **Stripe CLI** - Payment testing
- **Supabase CLI** - Backend/database management

#### 📦 Development Features
- **Interactive GitHub repository cloning** - Select which repos to clone from your GitHub account
- **Auto-generated Claude project launchers** - Desktop launchers for each cloned repo
- **Daily Claude quote timer** - Motivational quotes at 9am EST

#### 🌐 Development Web Apps
- **GitHub** - Code hosting
- **Cloudflare** - DNS and CDN management
- **Supabase** - Backend dashboard

---

## 📁 Repository Structure

```
~/code/jomarchy/
├── JOMARCHY.md                 # Default installation documentation
├── JOMARCHY-DEV.md             # Development add-on documentation
├── README-INSTALL.md           # This file
├── jomarchy.sh                 # One-command installer
└── scripts/install/
    ├── install-jomarchy.sh             # Default installation
    ├── install-jomarchy-dev.sh         # Dev add-on
    ├── essential-packages.sh
    ├── bash-customizations-universal.sh
    ├── bash-customizations-local.sh
    ├── chrome-extensions.sh
    ├── claude-launchers-universal.sh
    ├── claude-launchers-local.sh
    ├── custom-scripts-universal.sh
    ├── dev-tools-local.sh
    ├── waybar-customizations-universal.sh
    ├── web-apps-universal.sh
    └── web-apps-local.sh
```

---

## ✅ Benefits of This Structure

1. **Simple Default** - One installation that works for everyone
2. **Optional Extensions** - Add work/hardware configs only if needed
3. **Clear Separation** - Easy to understand what each piece provides
4. **Portable** - Use JOMARCHY on any machine
5. **Documented** - Each component has clear documentation

---

## 🔍 Reviewing What's Included

```bash
# View default installation
cat JOMARCHY.md

# View development add-on
cat JOMARCHY-DEV.md
```

---

## 📝 Notes

- Scripts can be run multiple times safely
- Add-ons automatically install base requirements
- All configurations are modular and optional beyond the base

---

## 🔧 Managing Your Installation

After installation, you have a unified management tool at your fingertips:

### Interactive Menu

```bash
jomarchy
```

Launches an interactive menu with options to:
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
- Move apps between profiles (single or bulk)
- Rename Chrome profiles
- View detailed profile information

**Use case:** Separate work apps (Slack, Gmail, Calendar) from personal apps (YouTube, Discord, X) by assigning them to different Chrome profiles.

---

## 🚀 Next Steps After Installation

1. Restart your shell: `source ~/.bashrc`
2. Test ChezWizper: Press `Super+R`
3. **Organize web apps**: Run `jomarchy --profiles`
4. Test Claude aliases: `cl`, `cp`
5. Launch file search: Press `F4`

---

## 🖥️ Hardware-Specific Configurations

Looking for hardware-specific setups (monitor configs, printer drivers, etc.)?

These are maintained in separate repositories to keep Jomarchy universal:
- **Beelink SER9 Pro**: [jomarchy-beelink](https://github.com/joewinke/jomarchy-beelink)

---

Generated by Claude Code for Omarchy Linux
