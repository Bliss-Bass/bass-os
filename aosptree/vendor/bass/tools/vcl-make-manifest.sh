#!/bin/bash

# Help menu
display_help() {
  echo "Usage: script.sh [options]"
  echo "Options:"
  echo "  -h, --help     Display this help menu"
  # Add more options here
}

# Options section with case statement
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      display_help
      exit 0
      ;;
    # Add more cases for other options here
    *)
      echo "Unknown option: $1"
      display_help
      exit 1
      ;;
  esac
  shift
done

local_manifest=()  # Declare local_manifest as a global array
declare -A manifest_info # Define the manifest_info array

# Update genRevManifest to create an array for revision information
genRevManifest() {
  temp_manifest_path=$(mktemp /tmp/manifest.XXXXXXXXXX.xml)  # Define the temp manifest path as a temporary XML file

  # Generate the manifest and read the generated XML into the array variable
  git manifest -o "$temp_manifest_path" -r
  
  while IFS= read -r line; do
    if [[ $line =~ '<project' ]]; then
      name=$(echo "$line" | grep -oP '(?<=name=")[^"]+')
      path=$(echo "$line" | grep -oP '(?<=path=")[^"]+')
      revision=$(echo "$line" | grep -oP '(?<=revision=")[^"]+')
      remote=$(echo "$line" | grep -oP '(?<=remote=")[^"]+')
      groups=$(echo "$line" | grep -oP '(?<=groups=")[^"]+')
      local_manifest+=("$name,$path,$revision,$remote,$groups")  # Add the project info to the local array
    fi
  done < "$temp_manifest_path"

  # Populate manifest_info array
  for file in .repo/manifests/**/*.xml; do
    filename=$(basename "$file")
    while IFS= read -r line; do
      if [[ $line =~ '<project' ]]; then
        name=$(echo "$line" | grep -oP '(?<=name=")[^"]+')
        path=$(echo "$line" | grep -oP '(?<=path=")[^"]+')
        initial_revision=$(echo "$line" | grep -oP '(?<=revision=")[^"]+')
        remote=$(echo "$line" | grep -oP '(?<=remote=")[^"]+')
        groups=$(echo "$line" | grep -oP '(?<=groups=")[^"]+')
        manifest_info["$filename,$name"]=$path,$initial_revision,remote:$remote,groups:$groups  # Populate manifest_info array
      elif [[ $line =~ '<remote' || $line =~ '<remove-project' ]]; then
        IFS=' ' read -ra fields <<< "$line"
        for field in "${fields[@]}"; do
          if [[ $field =~ (remote|remove-project).*name=([^[:space:]]+) ]]; then
            key="${BASH_REMATCH[1]},${BASH_REMATCH[2]}"
          elif [[ $field =~ (alias|fetch|groups)=([^[:space:]]+) ]]; then
            value="${BASH_REMATCH[1]}:${BASH_REMATCH[2]}"
          fi
        done
        manifest_info["$filename,$key"]+="$value"  # Add remote or remove-project entry to manifest_info array
      fi
    done < "$file"
  done
}

recreate_project_structure() {
  # Analyze gathered information and update project structure
  for file in .repo/manifests/default.xml; do
    tmpfile=$(mktemp)  # Create a temporary file to store the updated content
    while IFS= read -r line; do
      if [[ $line =~ '<project' ]]; then
        name=$(echo "$line" | grep -oP '(?<=name=")[^"]+')
        path=$(echo "$line" | grep -oP '(?<=path=")[^"]+')
        remote=$(echo "$line" | grep -oP '(?<=remote=")[^"]+')
        groups=$(echo "$line" | grep -oP '(?<=groups=")[^"]+')
        if [[ $remote == "aosp" || ${manifest_info["$file,$name,$path"]} || ($groups && ${manifest_info["$file,$name,$path,groups"]} && ${manifest_info["$file,$name,$path,groups"]//groups:/} == $groups) ]]; then
          echo "$line" >> "$tmpfile"  # Keep the entry if remote is "aosp" or exists in manifest_info, and group matches if present
        fi
      else
        echo "$line" >> "$tmpfile"  # Keep non-project lines as they are
      fi
    done < "$file"
    mv "$tmpfile" "$file"  # Replace the original file with the updated content
  done
}

# Call the function to populate manifest_info
# populate_manifest_info


