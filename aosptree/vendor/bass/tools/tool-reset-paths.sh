#!/bin/bash

# Generate temporary manifest file
temp_manifest="temp-manifest.xml"
repo manifest -o "$temp_manifest"

# Parse the XML file for repository paths
repo_paths=$(grep -oP 'path="\K[^"]+' "$temp_manifest")

# Read each repository path
while IFS= read -r repo_path; do
  # Change into the repository directory
  cd "$repo_path" || continue

  # Perform 'git reset --hard'
  git reset --hard

  # Change back to the original directory
  cd - >/dev/null || continue
done <<< "$repo_paths"

# Clean up the temporary manifest file
rm "$temp_manifest"