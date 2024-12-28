#!/bin/bash
set -e

# Clean workspace
echo "→ Cleaning workspace..."
rm -rf .git
rm -rf .cache
rm -rf tmp

# Clear temporary files
echo "→ Clearing temporary files..."
find . -name "*.tmp" -delete
find . -name "*.bak" -delete
rm -rf /tmp/*

echo "✓ Environment cleaned successfully"

# The  cleanup.sh  script is a simple bash script that removes the  .git  directory,  .cache  directory, and  tmp  directory.
# It also deletes temporary files and clears the  /tmp  directory.