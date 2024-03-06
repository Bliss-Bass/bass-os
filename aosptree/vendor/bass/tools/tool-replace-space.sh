#!/bin/bash

target_folder="$1"
echo "Target folder: $target_folder"
file_type="$2"
echo "File type: $file_type"

# Use find command to recursively search for files of the specified type in the target folder
mapfile -d '' file_list < <(find -L "$target_folder" -type f -name "*.$file_type" -print0)

echo "File list: ${file_list[@]}"

# Array to store renamed files
renamed_files=()

# Iterate over each file found
for file in "${file_list[@]}"; do
    echo "File: $file"
    filename=$(basename "$file")
    echo "Filename: $filename"
    new_filename=$(echo "$filename" | sed 's/ /-/g')
    echo "New filename: $new_filename"
    if [[ "$filename" != "$new_filename" ]]; then
        echo "Renaming '$filename' to '$new_filename'"
        mv "$file" "$(dirname "$file")/$new_filename"
        renamed_files+=("$new_filename")
    fi
done

# Print the list of renamed files
echo "Renamed files:"
for renamed_file in "${renamed_files[@]}"; do
    echo "$renamed_file"
done