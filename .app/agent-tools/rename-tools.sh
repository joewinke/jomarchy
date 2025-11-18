#!/usr/bin/env bash
# Rename all tools to have chimaro- prefix

cd ~/agent-tools/chimaro-tools

# Agent Mail tools
for f in am-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

# Database tools
for f in db-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

# Media/Asset tools
for f in asset-* video-* storage-* media-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

# Development tools
for f in type-* lint-* migration-* component-* route-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

# Monitoring tools
for f in edge-* quota-* job-* error-* perf-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

# Team/Deployment/AI/Testing tools
for f in user-* brand-* invite-* env-* build-* cache-* prompt-* model-* generation-* test-* snapshot-*; do
  [ -f "$f" ] && mv "$f" "chimaro-$f"
done

echo "Renamed all tools with chimaro- prefix"
ls chimaro-* | wc -l
