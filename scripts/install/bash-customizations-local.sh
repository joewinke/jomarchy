#!/bin/bash

# Bash Customizations (Local/Dev machines only)
# Interactive GitHub repository selection and cloning

set -e  # Exit on error

echo "========================================"
echo "Bash Customizations (Dev)"
echo "========================================"
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Create ~/code directory if it doesn't exist
if [ ! -d ~/code ]; then
    mkdir -p ~/code
    echo -e "${GREEN}✓${NC} Created ~/code directory"
fi

# Phase 1: Check GitHub CLI
echo -e "${BLUE}→${NC} Checking GitHub CLI..."
if ! command -v gh &> /dev/null; then
    echo -e "${RED}ERROR: GitHub CLI (gh) is not installed${NC}"
    echo "Please run dev-tools installation first"
    exit 1
fi

# Phase 2: GitHub Authentication
echo -e "${BLUE}→${NC} Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo ""
    echo -e "${YELLOW}GitHub authentication required${NC}"
    echo "This will open your browser to authenticate with GitHub"
    echo ""
    read -p "Press Enter to authenticate with GitHub..."
    gh auth login
    echo ""
    echo -e "${GREEN}✓${NC} GitHub authenticated"
else
    echo -e "${GREEN}✓${NC} Already authenticated with GitHub"
fi
echo ""

# Phase 3: Fetch Repositories
echo -e "${BLUE}→${NC} Fetching your GitHub repositories..."
repos_json=$(gh repo list --json name,isPrivate,url,sshUrl --limit 100)

if [ -z "$repos_json" ] || [ "$repos_json" = "[]" ]; then
    echo -e "${YELLOW}No repositories found${NC}"
    exit 0
fi

# Parse and display repos
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Available GitHub Repositories:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Convert JSON to arrays
mapfile -t repo_names < <(echo "$repos_json" | jq -r '.[].name')
mapfile -t repo_private < <(echo "$repos_json" | jq -r '.[].isPrivate')
mapfile -t repo_ssh < <(echo "$repos_json" | jq -r '.[].sshUrl')

# Display numbered list
for i in "${!repo_names[@]}"; do
    num=$((i + 1))
    name="${repo_names[$i]}"
    if [ "${repo_private[$i]}" = "true" ]; then
        privacy="${YELLOW}private${NC}"
    else
        privacy="${BLUE}public${NC}"
    fi
    printf "  [%2d] %-30s %b\n" "$num" "$name" "$privacy"
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Phase 4: Interactive Selection
echo "Enter numbers to clone (space-separated, e.g., 1 3 5)"
echo "Or press Enter to skip repository cloning"
echo ""
read -p "Selection: " selection

if [ -z "$selection" ]; then
    echo ""
    echo -e "${YELLOW}No repositories selected, skipping clone${NC}"
    selected_indices=()
else
    # Parse selection into array
    read -ra selected_numbers <<< "$selection"
    selected_indices=()

    # Convert to zero-based indices and validate
    for num in "${selected_numbers[@]}"; do
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            idx=$((num - 1))
            if [ $idx -ge 0 ] && [ $idx -lt ${#repo_names[@]} ]; then
                selected_indices+=($idx)
            else
                echo -e "${YELLOW}Warning: Invalid number $num (skipping)${NC}"
            fi
        fi
    done

    # Phase 5: Clone Selected Repos
    if [ ${#selected_indices[@]} -gt 0 ]; then
        echo ""
        echo -e "${BLUE}→${NC} Cloning selected repositories..."
        echo ""

        cloned_repos=()

        for idx in "${selected_indices[@]}"; do
            name="${repo_names[$idx]}"
            ssh_url="${repo_ssh[$idx]}"
            dest_dir=~/code/"$name"

            if [ -d "$dest_dir" ]; then
                echo -e "${YELLOW}→${NC} $name (already exists, skipping)"
                cloned_repos+=("$name")
            else
                echo -e "${BLUE}→${NC} Cloning $name..."
                if git clone "$ssh_url" "$dest_dir" 2>/dev/null; then
                    echo -e "${GREEN}✓${NC} $name cloned successfully"
                    cloned_repos+=("$name")
                else
                    echo -e "${YELLOW}→${NC} Could not clone $name (check SSH key or network)"
                    mkdir -p "$dest_dir"
                    echo -e "${YELLOW}→${NC} Created ~/code/$name directory"
                fi
            fi
        done

        # Phase 6: Generate Dynamic Aliases
        if [ ${#cloned_repos[@]} -gt 0 ]; then
            echo ""
            echo -e "${BLUE}→${NC} Generating Claude aliases..."

            BASHRC=~/.bashrc

            # Remove old work aliases block if exists
            if grep -q "# Work Project Aliases" "$BASHRC" 2>/dev/null; then
                # Create temp file without the old aliases section
                sed '/# Work Project Aliases/,/^$/d' "$BASHRC" > "${BASHRC}.tmp"
                mv "${BASHRC}.tmp" "$BASHRC"
            fi

            # Generate new aliases
            declare -A alias_map

            for repo in "${cloned_repos[@]}"; do
                # Generate alias: cc + first letter of repo name
                first_char="${repo:0:1}"
                alias_name="cc${first_char}"

                # Handle conflicts by appending more characters
                counter=1
                while [ -n "${alias_map[$alias_name]}" ]; do
                    counter=$((counter + 1))
                    if [ $counter -le ${#repo} ]; then
                        alias_name="cc${repo:0:$counter}"
                    else
                        # Fallback: append numbers
                        alias_name="cc${first_char}${counter}"
                    fi
                done

                alias_map[$alias_name]="$repo"
            done

            # Write aliases to .bashrc
            {
                echo ""
                echo "# Work Project Aliases (Auto-generated by Jomarchy)"
                for alias_name in "${!alias_map[@]}"; do
                    repo="${alias_map[$alias_name]}"
                    echo "alias ${alias_name}='cd ~/code/${repo} && claude --dangerously-skip-permissions'"
                done
                echo ""
            } >> "$BASHRC"

            echo -e "${GREEN}✓${NC} Aliases added to .bashrc"
            echo ""
            echo "Generated Claude Code aliases:"
            for alias_name in "${!alias_map[@]}"; do
                repo="${alias_map[$alias_name]}"
                echo "  $alias_name → Claude in ~/code/$repo"
            done
        fi
    fi
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bash Customizations Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ ${#cloned_repos[@]} -gt 0 ]; then
    echo "Cloned repositories:"
    for repo in "${cloned_repos[@]}"; do
        echo "  ✓ ~/code/$repo"
    done
    echo ""

    echo "Restart your shell to use the new aliases:"
    echo "  source ~/.bashrc"
    echo ""
fi

echo "Note: Repositories are cloned via SSH (git@github.com)"
echo "If cloning failed, ensure your SSH key is added to GitHub:"
echo "  https://github.com/settings/keys"
echo ""
