#!/usr/bin/env bash
cd ~/agent-tools/shared

echo "Removing chimaro- prefix from all tools..."

for file in chimaro-*; do
    if [ -f "$file" ]; then
        newname=$(echo "$file" | sed 's/^chimaro-//')
        mv "$file" "$newname"
        echo "  $file -> $newname"
    fi
done

echo ""
echo "Fixing imports..."
sed -i "s|from './chimaro-am-lib.js'|from './am-lib.js'|g" am-* 2>/dev/null

echo "Done! Tools are now generic (no prefix)"
ls | grep "^am-" | head -5
