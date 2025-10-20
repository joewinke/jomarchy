# OMARCHY-BEELINK: Hardware-Specific Configuration

This document defines **hardware-specific** items for the Beelink SER9 Pro workstation.

**Prerequisites:** OMARCHY-ALL + OMARCHY-DEV must be installed first.

---

## 🖥️ Hardware Specifications

**Model:** Beelink SER9 Pro
- **CPU:** AMD Ryzen AI 9 HX 370 (12 Zen5 cores)
- **GPU:** Integrated Radeon 890M
- **NPU:** XDNA 2 with 80 AI TOPS
- **RAM:** 64GB LPDDR5X 8000MHz
- **Storage:** Dual M.2 2880 PCIe 4.0 SSD
- **Monitors:** 3x 3440x1440 ultrawide displays

---

## 🖨️ Hardware Drivers

### Printer
- **Brother HL2270DW** - Brother laser printer driver
- Package: `brother-hl2270dw`

### Camera
- **gphoto2** - DSLR camera support
- Package: `gphoto2`

### Virtual Webcam
- **v4l2loopback-dkms** - Virtual webcam driver for OBS, etc.
- Package: `v4l2loopback-dkms` (AUR)

**Installation:** `scripts/install/hardware-specific.sh`

---

## 🖥️ Monitor Configuration

### Physical Setup
- **DP-2** (Left): 3440x1440 @ 120Hz at position 0x0
- **HDMI-A-1** (Center): 3440x1440 @ 100Hz at position 3440x0
- **DP-1** (Right): 3440x1440 @ 120Hz at position 6880x0

### Configuration File
`~/.config/hypr/monitors.conf`

**Note:** Running at 120Hz on DP monitors provides better stability than 165Hz while maintaining smooth performance on the Radeon 890M.

---

## 📊 30-Workspace Configuration

### Workspace Distribution
- **Workspaces 1-10:** Left monitor (DP-2)
- **Workspaces 11-20:** Center monitor (HDMI-A-1)
- **Workspaces 21-30:** Right monitor (DP-1)

### Configuration Files
- `monitors.conf` - Binds workspaces to specific monitors
- `workspace-layouts.conf` - Makes all 30 workspaces persistent
- `workspaces.conf` - Workspace-specific settings

### Keybindings (Omarchy 3.1 Compatible)
**Note:** Custom workspace keybindings backed up but not installed pending Omarchy 3.1 keybinding redesign.

**Backup location:** `~/code/linux/backups/bash-functions/workspace-functions.sh`

Functions backed up (not installed):
- `ws_meta()` - Switch all monitors to meta-workspace
- `smart_move_to_workspace()` - Intelligent window movement
- `switch_monitor_workspace()` - Single monitor workspace switching

---

## 🎨 Waybar Monitor Color Coding

Visual workspace indicators for 3-monitor setup:

### Color Scheme
- **Workspaces 1-10** (Left monitor): Light green (#99d9ab)
- **Workspaces 11-20** (Center monitor): Bright cyan (#00ffcc)
- **Workspaces 21-30** (Right monitor): Bright magenta (#ff00ff)

### CSS Implementation
```css
/* Workspaces 1-10: Light green */
#workspaces button.persistent:nth-child(n+1):nth-child(-n+10) {
  color: #99d9ab;
}

/* Workspaces 11-20: Bright cyan */
#workspaces button.persistent:nth-child(n+11):nth-child(-n+20) {
  color: #00ffcc;
}

/* Workspaces 21-30: Bright magenta */
#workspaces button.persistent:nth-child(n+21):nth-child(-n+30) {
  color: #ff00ff;
}
```

---

## 📋 Installation Summary

**What OMARCHY-BEELINK Adds:**

- **Hardware drivers:** 3 (printer + camera + virtual webcam)
- **Monitor config:** 3-monitor setup with specific positions/refresh rates
- **Workspace config:** 30 workspaces distributed across 3 monitors
- **Waybar styling:** Monitor-specific color coding

**Total environment:** OMARCHY-ALL (base) + OMARCHY-DEV (work) + OMARCHY-BEELINK (hardware)

---

## 🎯 Quick Install

Run the Beelink-specific installation script:
```bash
cd ~/code/linux
./scripts/install/install-omarchy-beelink.sh
```

This will:
1. First run `install-omarchy-all.sh` (if not already installed)
2. Then run `install-omarchy-dev.sh` (if not already installed)
3. Finally install all Beelink-specific hardware configurations

---

## 🔧 Monitor Troubleshooting

### Monitor Won't Wake from Sleep

If a monitor shows black screen or won't wake:

```bash
# Reconfigure the specific monitor
hyprctl keyword monitor DP-2,3440x1440@120,0x0,1      # Left
hyprctl keyword monitor HDMI-A-1,3440x1440@100,3440x0,1  # Center
hyprctl keyword monitor DP-1,3440x1440@120,6880x0,1   # Right

# If still won't wake, try 60Hz temporarily:
hyprctl keyword monitor DP-2,3440x1440@60,0x0,1
hyprctl keyword monitor DP-1,3440x1440@60,6880x0,1
```

**Note:** The integrated Radeon 890M handles 120Hz more reliably than 165Hz.

---

## ✅ What This Gives You

Everything from OMARCHY-ALL + OMARCHY-DEV, plus:
- Brother printer ready to use
- Camera support configured
- Perfect 3-monitor workspace layout
- Visual workspace indicators per monitor
- Hardware-optimized monitor refresh rates

**Perfect for:** This specific Beelink SER9 Pro workstation with 3 ultrawide monitors

**Other machines:** Use OMARCHY-ALL or OMARCHY-DEV depending on hardware
