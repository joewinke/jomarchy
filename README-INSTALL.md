# Omarchy Post-Install System

A 3-tier installation system for Omarchy Linux with clear separation between universal, development, and hardware-specific configurations.

---

## 📚 Documentation Files

### 1. [OMARCHY-ALL.md](OMARCHY-ALL.md) - Base System
**What:** Universal installation for any Omarchy system
**Includes:**
- Core packages (VS Code, Node.js, Firefox, claude-code, Sublime, Tailscale, etc.)
- ChezWizper voice transcription
- 10 universal web apps
- 3 Chrome extensions
- Waybar customizations
- cl/cp aliases + Claude launchers
- Custom scripts

**Install:** `./scripts/install/install-omarchy-all.sh`

---

### 2. [OMARCHY-DEV.md](OMARCHY-DEV.md) - Development Environment
**What:** Additional tools for development workstations (adds to ALL)
**Includes:**
- Dev tools (Stripe CLI, Supabase CLI, v4l2loopback-dkms)
- Work project repos (flush, chimaro, steelbridge)
- cf/cc/cs aliases + work Claude launchers
- 15 work-specific web apps

**Install:** `./scripts/install/install-omarchy-dev.sh`
(Automatically includes OMARCHY-ALL)

---

### 3. [OMARCHY-BEELINK.md](OMARCHY-BEELINK.md) - Hardware-Specific
**What:** Beelink SER9 Pro specific configuration (adds to DEV)
**Includes:**
- 30-workspace configuration (3 monitors)
- Waybar monitor color coding
- Brother printer driver
- Camera support
- Monitor hardware config

**Install:** `./scripts/install/install-omarchy-beelink.sh`
(Automatically includes OMARCHY-ALL + OMARCHY-DEV)

---

## 🎯 Quick Start

### Fresh Omarchy Install (One Command)

As soon as wifi is connected, run:

```bash
bash <(curl -sL https://raw.githubusercontent.com/joewinke/jomarchy/master/bootstrap-omarchy.sh)
```

This will:
1. Install git if needed
2. Clone the repository to ~/code/jomarchy
3. Present an interactive menu to select your tier
4. Run the appropriate installation script

### Already Have Repository Cloned

#### For Any Omarchy System (Laptop, VM, etc.)
```bash
cd ~/code/jomarchy
./scripts/install/install-omarchy-all.sh
```

#### For Development Workstation
```bash
cd ~/code/jomarchy
./scripts/install/install-omarchy-dev.sh
```

#### For Beelink SER9 Pro (This Machine)
```bash
cd ~/code/jomarchy
./scripts/install/install-omarchy-beelink.sh
```

---

## 🔄 Inheritance Model

```
OMARCHY-ALL (Base)
    ↓ includes
OMARCHY-DEV (Development)
    ↓ includes
OMARCHY-BEELINK (Hardware-Specific)
```

Each tier builds on the previous one:
- **ALL** = Standalone base system
- **DEV** = ALL + development additions
- **BEELINK** = ALL + DEV + hardware configuration

---

## 📊 What Gets Installed Where

### OMARCHY-ALL (Any System)
- ✅ 15 core packages
- ✅ ChezWizper + 6 Waybar scripts
- ✅ 10 universal web apps
- ✅ 3 Chrome extensions
- ✅ 2 Claude launchers (Linux, Personal)
- ✅ 2 custom scripts (zoom, screensaver)
- ✅ Bash: ~/code/linux, ~/code/personal

### OMARCHY-DEV (Development Workstation)
- ➕ 3 dev tools (AUR)
- ➕ 3 work project repos
- ➕ 3 work Claude launchers
- ➕ 15 work web apps
- ➕ cf/cc/cs aliases

### OMARCHY-BEELINK (This Machine)
- ➕ 30-workspace config (3 monitors)
- ➕ Waybar color coding
- ➕ Printer driver
- ➕ Camera support
- ➕ Monitor config (3x 3440x1440)

---

## 📁 File Structure

```
~/code/linux/
├── OMARCHY-ALL.md              # Base system documentation
├── OMARCHY-DEV.md              # Development additions documentation
├── OMARCHY-BEELINK.md          # Hardware-specific documentation
├── README-INSTALL.md           # This file
├── POST-INSTALL-PLAN.md        # Original planning document (reference)
└── scripts/install/
    ├── install-omarchy-all.sh      # Base installation script
    ├── install-omarchy-dev.sh      # Dev installation script
    ├── install-omarchy-beelink.sh  # Hardware installation script
    ├── essential-packages.sh       # Core packages
    ├── bash-customizations-universal.sh
    ├── chrome-extensions.sh
    ├── chezwizper.sh
    ├── web-apps-universal.sh
    ├── claude-launchers-universal.sh
    ├── waybar-customizations-universal.sh
    ├── custom-scripts-universal.sh
    ├── dev-tools-local.sh
    ├── bash-customizations-local.sh
    ├── claude-launchers-local.sh
    ├── web-apps-local.sh
    ├── hyprland-workspace-config-local.sh
    └── hardware-specific.sh
```

---

## ✅ Benefits of This Structure

1. **Clear Separation** - Easy to understand what each tier provides
2. **Reusable** - Use OMARCHY-ALL on any machine without dev clutter
3. **Portable** - Install just what you need for each machine type
4. **Maintainable** - Update one tier without affecting others
5. **Documented** - Each tier has its own clear documentation

---

## 🔍 Reviewing the Deltas

Want to see what differentiates each tier?

```bash
# View base system
cat OMARCHY-ALL.md

# View development additions
cat OMARCHY-DEV.md

# View hardware-specific additions
cat OMARCHY-BEELINK.md
```

Each file is standalone and shows exactly what that tier adds.

---

## 📝 Notes

- All scripts check for prerequisites and can be run multiple times safely
- Scripts will prompt before re-installing base tiers
- Installation order is enforced automatically by the inheritance model
- See individual .md files for detailed package lists and configurations

---

## 🚀 Next Steps After Installation

1. Restart your shell: `source ~/.bashrc`
2. Test ChezWizper: Press `Super+R`
3. Test Claude aliases: `cl`, `cp` (and `cf`, `cc`, `cs` if DEV installed)
4. Review what was installed: `cat OMARCHY-[tier].md`

---

Generated by Claude Code for Omarchy Linux
