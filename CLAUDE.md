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
jomarchy --install        # Install additional profiles
jomarchy --status         # Show installed profiles
jomarchy --update         # Update from GitHub
jomarchy --help           # Show help
```

**Management Menu Features:**
- Install Additional Profiles
- Manage Web App Profiles (organize by Chrome profile)
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

Use git-commit-assistant for organized commits:
- Group related changes (e.g., all gum fixes together)
- Separate features from refactors
- Include context in commit messages

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

## Related Documentation

- **Jomarchy README:** `~/code/jomarchy/README.md`
- **Jomarchy-Machines README:** `~/code/jomarchy-machines/README.md`
- **Omarchy Docs:** https://omarchy.org

---

**Last Updated:** October 30, 2025
**Maintained By:** Joe Winke
**Generated With:** Claude Code
