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

# Jomarchy - Power Tools & Web App Manager

**Jomarchy** is a profile-based installation system for Omarchy Linux. Select the profiles you want and transform a fresh installation into a fully-configured workstation.

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
3. Present an interactive profile selector
4. Let you choose which profiles to install (BASE, DEV, MEDIA, FINANCE, COMMUNICATIONS)
5. Install the jomarchy command for post-installation management

> **✨ Web App Profile Manager:** After installation, use `jomarchy --profiles` to organize your web apps by Chrome profile (work vs personal, etc.)

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

```bash
cd ~/code/jomarchy
./jomarchy.sh
```

This launches the interactive profile selector where you can choose which profiles to install.

### Installing Specific Profiles Directly

If you prefer to skip the profile selector and install specific profiles directly:

```bash
cd ~/code/jomarchy

# Install BASE profile only
./scripts/install/install-jomarchy.sh

# Install DEV profile
./scripts/install/install-jomarchy-dev.sh

# Install MEDIA profile
./scripts/install/install-jomarchy-media.sh

# Install FINANCE profile
./scripts/install/install-jomarchy-finance.sh

# Install COMMUNICATIONS profile
./scripts/install/install-jomarchy-communications.sh
```

---

## 📊 What Gets Installed

All components below can be selectively installed via interactive gum menus. Everything is pre-selected by default, but you can deselect items you don't want.

### BASE Profile

#### 🗂️ Core Packages
- **Firefox** - Web browser (pre-installed by Omarchy)
- **Chromium** - Alternative browser (pre-installed by Omarchy)
- **Sublime Text 4** - Fast text editor
- **Claude Code** - AI-powered CLI coding assistant
- **yt-dlp** - Video downloader (YouTube, etc.)
- **Tailscale** - VPN/mesh network
- **nwg-displays** - Multi-monitor display manager
- **JetBrains Mono** - Programming font
- **ChezWizper** - Voice transcription with Super+R

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
- Waybar indicator shows when active

**Desktop Application Shortcuts:**
- Claude.ai (Linux) - Desktop shortcut to launch Claude.ai for ~/code/linux projects
- Claude.ai (Personal) - Desktop shortcut to launch Claude.ai for ~/code/personal projects
- Claude Code MCP configuration - Chrome DevTools integration for web scraping

#### 🌐 Web Apps
- **Proton Mail** - Encrypted email
- **Kagi** - Privacy-focused search engine
- **YouTube** - Video platform
- **X (Twitter)** - Social media

### MEDIA Profile

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

### FINANCE Profile

#### 🏦 Web Apps
- **Bank of America** - Online banking
- **Chase Bank** - Online banking
- **Capital One** - Online banking
- **QuickBooks Online** - Accounting and invoicing

### COMMUNICATIONS Profile

#### 💬 Web Apps
- **Discord** - Gaming and community chat
- **WhatsApp** - Messaging
- **Slack** - Team communication
- **Gmail** - Google email
- **Zoom** - Video conferencing

### DEV Profile

#### 🛠️ Development Tools
- **VSCodium** - Privacy-focused VS Code (de-Microsoft-ified, telemetry-free)
- **Node.js & npm** - JavaScript runtime
- **GitHub CLI** - Git operations from terminal
- **Stripe CLI** - Payment testing
- **Supabase CLI** - Backend/database management

#### 📦 Development Features
- **Interactive GitHub repository cloning** - Select which repos to clone from your GitHub account
- **Auto-generated project shortcuts** - Desktop shortcuts to launch Claude.ai for each cloned repo
- **Daily Claude quote timer** - Motivational quotes at 9am EST

#### 🌐 Development Web Apps
- **GitHub** - Code hosting
- **Cloudflare** - DNS and CDN management
- **Supabase** - Backend dashboard

---

## 📁 Repository Structure

```
~/code/jomarchy/
├── README.md                           # This file
├── JOMARCHY.md                         # Full project documentation
├── CLAUDE.md                           # Developer documentation
├── jomarchy.sh                         # Interactive profile selector
└── scripts/
    ├── install/
    │   ├── install-jomarchy.sh                    # BASE profile installer
    │   ├── install-jomarchy-dev.sh                # DEV profile installer
    │   ├── install-jomarchy-media.sh              # MEDIA profile installer
    │   ├── install-jomarchy-finance.sh            # FINANCE profile installer
    │   ├── install-jomarchy-communications.sh     # COMMUNICATIONS profile installer
    │   ├── essential-packages.sh                  # Core packages
    │   ├── bash-customizations-universal.sh       # Bash aliases & dirs
    │   ├── bash-customizations-local.sh           # GitHub repo cloning
    │   ├── chrome-extensions.sh                   # Browser extensions
    │   ├── chezwizper.sh                          # Voice transcription
    │   ├── claude-launchers-universal.sh          # Claude.ai desktop shortcuts
    │   ├── claude-launchers-local.sh              # Project-specific shortcuts
    │   ├── claude-code-mcp.sh                     # Claude Code MCP
    │   ├── claude-daily-quote.sh                  # Daily quote timer
    │   ├── custom-scripts-universal.sh            # Keybindings: zoom toggle, file search
    │   ├── waybar-customizations-universal.sh     # Theme-aware styling
    │   ├── waybar-workspace-detection.sh          # Multi-monitor config
    │   ├── dev-packages.sh                        # Dev tools
    │   ├── dev-tools-local.sh                     # CLI tools
    │   ├── media-packages.sh                      # Creative software
    │   ├── web-apps-universal.sh                  # BASE web apps
    │   ├── web-apps-local.sh                      # DEV web apps
    │   ├── web-apps-finance.sh                    # FINANCE web apps
    │   └── web-apps-communications.sh             # COMMUNICATIONS web apps
    └── lib/
        └── (shared library functions)
```

---

## ✅ Benefits of This Structure

1. **Profile-Based** - Choose exactly what you need (BASE, DEV, MEDIA, FINANCE, COMMUNICATIONS)
2. **Component Selection** - Each profile offers fine-grained control via gum menus
3. **Idempotent** - Scripts can be run multiple times safely without creating duplicate backups
4. **Modular** - Each component is independent and optional
5. **Documented** - Detailed descriptions of every package, customization, and feature
6. **Multi-Monitor Ready** - Intelligent workspace detection for 1-3 monitors

---

## 📝 Notes

- All scripts are idempotent and can be run multiple times safely
- Gum menus allow selective installation within each profile
- All configurations are modular - install only what you need
- BASE profile recommended for everyone as foundation

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

The profiles in this repository are designed to be universal and work on any Omarchy system.

For hardware-specific configurations (monitor setups, printer drivers, etc.), you can create your own machine-specific profiles following the same pattern as the existing profiles in `scripts/install/`.