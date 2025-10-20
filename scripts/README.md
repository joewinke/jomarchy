# Custom Post-Installation Scripts

This directory contains modular installation scripts for setting up a fresh Omarchy Linux installation with your preferred software and configurations.

## Structure

```
~/code/linux/
├── post-install.sh              # Master orchestration script
├── scripts/
│   ├── README.md                # This file
│   └── install/                 # Individual installation scripts
│       ├── chrome-extensions.sh # Chrome extensions installer
│       ├── sublime-text.sh      # Sublime Text 4 installer
│       └── [your-app].sh        # Add more installers here
```

## How It Works

### The Omarchy Way

Omarchy Linux stores all its scripts in `~/.local/share/omarchy/bin/` with the `omarchy-` prefix:
- All system scripts: `omarchy-*`
- Your custom scripts: **NO PREFIX** (easy to identify)

### Your Custom Setup

This structure keeps YOUR scripts separate and organized:
- **Location**: `~/code/linux/scripts/` (not mixed with Omarchy's bin)
- **Version Control**: Can be committed to git
- **Portable**: Copy to any new Omarchy installation
- **Modular**: Each app gets its own script
- **Orchestrated**: Master script runs them all

## Quick Start

### On a Fresh Omarchy Installation

```bash
# Clone or copy this directory to your new system
cd ~/code/linux

# Run the post-install script
./post-install.sh
```

That's it! Everything will be installed automatically.

### Selective Installation

```bash
# Install only Chrome extensions
./post-install.sh --chrome

# Install only Sublime Text
./post-install.sh --sublime

# Show help
./post-install.sh --help
```

## What Gets Installed

### Chrome Extensions
- **Copy on Select** - Automatically copies selected text to clipboard
- **Dark Reader** - Dark mode for all websites
- **1Password** - Password manager

### Applications
- **Sublime Text 4** - Text editor (from AUR)

## Adding More Software

### Step 1: Create Installation Script

Create a new file in `scripts/install/` (e.g., `my-app.sh`):

```bash
#!/bin/bash
set -e

echo -e "Installing My App..."

# Your installation commands here
# Use omarchy-pkg-add for pacman packages
# Use omarchy-pkg-aur-install for AUR packages
omarchy-pkg-add my-app

echo -e "✓ My App installed!"
```

### Step 2: Make It Executable

```bash
chmod +x scripts/install/my-app.sh
```

### Step 3: Add to Master Script

Edit `post-install.sh` and add:

```bash
# In the installation functions section:
install_my_app() {
    if [[ -f "$INSTALL_DIR/my-app.sh" ]]; then
        bash "$INSTALL_DIR/my-app.sh"
    else
        echo -e "${RED}Error: my-app.sh not found${NC}"
        return 1
    fi
}

# In the install_all function:
install_all() {
    # ... existing installations ...
    install_my_app
    echo ""
}

# In the case statement:
case "$1" in
    # ... existing options ...
    --my-app)
        install_my_app
        ;;
esac
```

### Step 4: Test It

```bash
./post-install.sh --my-app
```

## Real-World Examples

### Installing from Pacman

```bash
#!/bin/bash
# docker.sh
set -e

echo -e "Installing Docker..."
omarchy-pkg-add docker docker-compose

# Enable and start service
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER

echo -e "✓ Docker installed! Log out and back in for group changes."
```

### Installing from AUR

```bash
#!/bin/bash
# visual-studio-code.sh
set -e

echo -e "Installing Visual Studio Code..."
omarchy-pkg-aur-install visual-studio-code-bin

echo -e "✓ VS Code installed!"
```

### Installing with Configuration

```bash
#!/bin/bash
# obsidian.sh
set -e

echo -e "Installing Obsidian..."
omarchy-pkg-add obsidian

# Create vault directory
mkdir -p ~/Documents/Obsidian

# Copy custom settings
if [[ -f ~/code/linux/configs/obsidian.json ]]; then
    mkdir -p ~/.config/obsidian
    cp ~/code/linux/configs/obsidian.json ~/.config/obsidian/
fi

echo -e "✓ Obsidian installed!"
```

## Omarchy Helper Commands

Use these in your installation scripts:

### Package Management
```bash
omarchy-pkg-add package-name          # Install from pacman
omarchy-pkg-aur-install package-name  # Install from AUR
omarchy-pkg-remove package-name       # Remove package
```

### Application Launchers
```bash
omarchy-webapp-install "App Name" "https://url.com" icon.png  # Install web app
omarchy-tui-install "App Name" "command" float icon.png       # Install TUI app
```

### System Refresh
```bash
omarchy-refresh-applications  # Refresh app menu
omarchy-refresh-config        # Reload configs
```

## Tips

1. **Keep it modular** - One script per application/configuration
2. **Use color codes** - Makes output easier to read
3. **Add error checking** - Use `set -e` to exit on errors
4. **Test individually** - Test each script before adding to master
5. **Document dependencies** - Note if one script requires another
6. **Version control** - Commit this to git for easy updates

## Troubleshooting

### Script not found
Make sure you're running from the correct directory:
```bash
cd ~/code/linux
./post-install.sh
```

### Permission denied
Make sure scripts are executable:
```bash
chmod +x post-install.sh
chmod +x scripts/install/*.sh
```

### Installation fails
Run individual scripts to debug:
```bash
bash scripts/install/chrome-extensions.sh
```

## Backup and Restore

### Before Fresh Install
```bash
# Backup this directory
tar -czf ~/omarchy-custom-scripts.tar.gz ~/code/linux/scripts ~/code/linux/post-install.sh
```

### After Fresh Install
```bash
# Restore
cd ~
tar -xzf omarchy-custom-scripts.tar.gz
cd ~/code/linux
./post-install.sh
```

## See Also

- [Omarchy Manual](https://manuals.omamix.org/2/the-omarchy-manual)
- [Chrome Extensions Auto-Install Guide](../CHROME-EXTENSIONS-AUTO-INSTALL.md)
- [Meta-Workspace System](../CLAUDE.md)
