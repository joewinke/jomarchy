# OMARCHY-DEV: Development Environment Additions

This document defines **additional** items installed on development workstations.

**Prerequisites:** OMARCHY-ALL must be installed first.

---

## 📦 Additional Development Tools (AUR)

- `stripe-cli` - Stripe API CLI tool
- `supabase-bin` - Supabase CLI

**Installation:** `scripts/install/dev-tools-local.sh`

---

## 💼 Work Project Setup

### Clone Repositories
```bash
cd ~/code
git clone https://github.com/yourusername/flush.git
git clone https://github.com/yourusername/chimaro.git
git clone https://github.com/yourusername/steelbridge.git
```

### Work Project Claude Aliases
```bash
# Flush project
alias cf='cd ~/code/flush && claude --dangerously-skip-permissions'

# Chimaro project
alias cc='cd ~/code/chimaro && claude --dangerously-skip-permissions'

# Steelbridge project
alias cs='cd ~/code/steelbridge && claude --dangerously-skip-permissions'
```

**Installation:** `scripts/install/bash-customizations-local.sh`

---

## 🚀 Claude Desktop Launchers (3 work launchers)

Terminal launchers matching work project aliases:

- **Claude Chimaro** → `cc` → ~/code/chimaro
- **Claude Flush** → `cf` → ~/code/flush
- **Claude Steelbridge** → `cs` → ~/code/steelbridge

**Installation:** `scripts/install/claude-launchers-local.sh`

---

## 🌐 Work-Specific Web Apps (15 apps)

Chrome web apps for work projects:

### Development Projects
- **Chimaro Local** - http://localhost:3000

### Backend Services
- **Supabase Chimaro** - https://supabase.com/dashboard/project/[chimaro-id]
- **Supabase Flush** - https://supabase.com/dashboard/project/[flush-id]
- **Supabase Steelbridge** - https://supabase.com/dashboard/project/[steelbridge-id]

### Work Communication
- **DMT Mail** - https://mail.google.com/mail/u/[account]/#inbox
- **PEMail** - https://mail.google.com/mail/u/[account]/#inbox
- **PE Slack** - https://[workspace].slack.com

### Development Tools
- **Marduk** - https://mm.marduk.app
- **Dev Tracker** - https://coda.io/d/Dev-Tracker_d-EkWOo9WC4/Icebox_sum9Bg7
- **Apify** - https://console.apify.com
- **DaisyUI** - https://daisyui.com
- **Docker** - https://localhost:[port]

### Financial
- **Bank of America** - https://www.bankofamerica.com
- **Chase Bank** - https://www.chase.com
- **Capital One** - https://www.capitalone.com
- **QBO** - https://qbo.intuit.com

**Installation:** `scripts/install/web-apps-local.sh`

---

## 📋 Installation Summary

**What OMARCHY-DEV Adds:**

- **Packages:** 2 additional dev tools (AUR)
- **Repositories:** 3 work project repos cloned
- **Aliases:** 3 work project Claude aliases (cf, cc, cs)
- **Desktop launchers:** 3 work project Claude launchers
- **Web apps:** 15 work-specific Chrome web apps

**Total environment:** OMARCHY-ALL (base) + OMARCHY-DEV additions

---

## 🎯 Quick Install

Run the development installation script:
```bash
cd ~/code/linux
./scripts/install/install-omarchy-dev.sh
```

This will:
1. First run `install-omarchy-all.sh` (if not already installed)
2. Then install all development-specific items

---

## ✅ What This Gives You

Everything from OMARCHY-ALL, plus:
- Development tools (Stripe CLI, Supabase CLI)
- Work project repositories and aliases
- Work-specific web apps and Claude launchers
- Complete development environment for client work

**Perfect for:** Development workstations handling client/work projects

**Not included:** Hardware-specific configurations (see OMARCHY-BEELINK.md)
