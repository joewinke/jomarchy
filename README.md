```
.·:''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''':·.
: :                                                                                                                 : :
: :      oooo   .oooooo.   ooo        ooooo       .o.       ooooooooo.     .oooooo.   ooooo   ooooo oooooo   oooo   : :
: :      `888  d8P'  `Y8b  `88.       .888'      .888.      `888   `Y88.  d8P'  `Y8b  `888'   `888'  `888.   .8'    : :
: :       888 888      888  888b     d'888      .8"888.      888   .d88' 888           888     888    `888. .8'     : :
: :       888 888      888  8 Y88. .P  888     .8' `888.     888ooo88P'  888           888ooooo888     `888.8'      : :
: :       888 888      888  8  `888'   888    .88ooo8888.    888`88b.    888           888     888      `888'       : :
: :       888 `88b    d88'  8    Y     888   .8'     `888.   888  `88b.  `88b    ooo   888     888       888        : :
: :   .o. 88P  `Y8bood8P'  o8o        o888o o88o     o8888o o888o  o888o  `Y8bood8P'  o888o   o888o     o888o       : :
: :   `Y888P                                                                                                        : :
: :                                                                                                                 : :
'·:.................................................................................................................:·'
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

**Jomarchy** is the default configuration - a complete Omarchy setup with:
- Core development tools
- Voice transcription (ChezWizper)
- Essential web apps
- Custom scripts and shortcuts
- Claude Code integration

**Optional add-ons:**
- **JOMARCHY-DEV**: Work-specific projects and tools
- **JOMARCHY-BEELINK**: Hardware-specific config for Beelink SER9 Pro

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
JOMARCHY (Default)
    ↓ optional
JOMARCHY-DEV (Work Projects)
```

- **JOMARCHY** = Standalone complete system (recommended for most)
- **JOMARCHY-DEV** = Optional work-specific additions

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

### JOMARCHY (Default - Everyone Gets This)
- ✅ 15 core packages
- ✅ ChezWizper + 6 Waybar scripts
- ✅ 10 universal web apps
- ✅ 3 Chrome extensions
- ✅ 2 Claude launchers (Linux, Personal)
- ✅ 3 custom scripts (zoom, screensaver, file search)
- ✅ Bash: ~/code/linux, ~/code/personal

### JOMARCHY-DEV (Optional - Work Projects)
- ➕ 3 dev tools (GitHub CLI, Stripe CLI, Supabase CLI)
- ➕ Interactive GitHub repo selection
- ➕ Auto-generated Claude aliases (based on your repos)
- ➕ Work-specific web apps
- ➕ Daily Claude quote timer

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

## 🚀 Next Steps After Installation

1. Restart your shell: `source ~/.bashrc`
2. Test ChezWizper: Press `Super+R`
3. Test Claude aliases: `cl`, `cp` (and `cf`, `cc`, `cs` if DEV installed)
4. Launch file search: Press `F4`
5. Review what was installed: `cat JOMARCHY.md`

---

## 🖥️ Hardware-Specific Configurations

Looking for hardware-specific setups (monitor configs, printer drivers, etc.)?

These are maintained in separate repositories to keep Jomarchy universal:
- **Beelink SER9 Pro**: [jomarchy-beelink](https://github.com/joewinke/jomarchy-beelink)

---

Generated by Claude Code for Omarchy Linux
