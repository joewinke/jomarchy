# Project Documentation

## Overview

[Brief description of what this project does]

## Technology Stack

[List key technologies, frameworks, libraries]

## Project Structure

```
├── src/          # Source code
├── docs/         # Documentation
├── tests/        # Test files
└── ...
```

## Development Setup

```bash
# Installation
[Installation commands]

# Running locally
[Dev server commands]

# Testing
[Test commands]
```

## Key Patterns & Conventions

[Project-specific coding patterns, naming conventions, architecture decisions]

## Common Tasks

### Task 1
[Steps to accomplish common task]

### Task 2
[Steps to accomplish common task]

## Agent Tools Configuration

**Global instructions:** See `~/.claude/CLAUDE.md` for Agent Mail, Beads, and bash tools documentation.

**This project uses:**
- ✅ Beads task planning (`.beads/` directory)
- ✅ Agent Mail coordination (project key: `[absolute path to this repo]`)
- ✅ 43 bash agent tools available globally

**Quick start for AI assistants:**
```bash
# See tasks ready to work
bd ready

# Register with Agent Mail
am-register --program claude-code --model sonnet-4.5

# Reserve files before editing
am-reserve "src/**" --agent AgentName --ttl 3600 --reason "bd-123"
```

## Troubleshooting

[Common issues and solutions]

---

**Last Updated:** [Date]
**Maintained By:** [Your Name]
**Generated With:** Jomarchy Agent Tools Setup
