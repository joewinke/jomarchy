# Jomarchy

Modular, profile-based Linux configuration system for Omarchy. Two repos: public `jomarchy` (universal profiles) and private `jomarchy-machines` (hardware + personal configs).

Full project context is in JAT knowledge bases — run `jt bases list` to see all available context.

## Commands

```bash
# Test installer locally
bash ~/code/jomarchy/jomarchy.sh

# Run management CLI
jomarchy --help
jomarchy --status
jomarchy --projects
```

## Key Files

- `jomarchy.sh` — Main installer + management CLI entry point
- `scripts/install/` — All profile and component installers
- `scripts/lib/common.sh` — Shared utilities (install_webapp, add_installed_profile)
