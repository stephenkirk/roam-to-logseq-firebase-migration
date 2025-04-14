#!/bin/bash
# This script replaces Firebase storage URLs in Markdown files with
# local asset paths. It processes both journal and page files.
#
# Usage: ./replace-firebase-urls.sh
#
# Note: This script assumes it's run from LOGSEQ_ROOT/scripts directory.
# The directory structure is expected to be:
# LOGSEQ_ROOT/
# ├── journals/
# ├── pages/
# ├── assets/roam/
# └── scripts/
#     └── replace-firebase-urls.sh
#
# The script will:
# 1. Back up all original files
# 2. Scan for Firebase URLs in the format:
#    https://firebasestorage.googleapis.com/v0/b/firescript...
# 3. Replace them with relative paths to locally downloaded assets
# 4. Create a log file with details of all replacements
#
# Options:
#   Set DRY_RUN=true/false in the script to toggle dry run mode

JOURNALS_DIR="../journals"
PAGES_DIR="../pages"
ASSETS_DIR="../assets/roam"
LOG_FILE="replacement.log"
BACKUP_DIR="./backup"
DRY_RUN=true

# Create backup directory if not in dry run mode
if [ "$DRY_RUN" = false ]; then
    echo "Creating backup of pages..."
    mkdir -p "$BACKUP_DIR/journals" "$BACKUP_DIR/pages"
    cp -r "$JOURNALS_DIR"/* "$BACKUP_DIR/journals"
    cp -r "$PAGES_DIR"/* "$BACKUP_DIR/pages"
    echo "Backup created in $BACKUP_DIR"
fi

echo "Starting replacements at $(date)" > "$LOG_FILE"
if [ "$DRY_RUN" = true ]; then
    echo "*** DRY RUN MODE - No files will be modified ***" | tee -a "$LOG_FILE"
fi

TOTAL_FILES=$(find "$JOURNALS_DIR" "$PAGES_DIR" -name "*.md" | wc -l | tr -d ' ')
CURRENT=0

# Process each journal file
find "$JOURNALS_DIR" "$PAGES_DIR" -name "*.md" | while read -r journal_file; do
    CURRENT=$((CURRENT + 1))
    filename=$(basename "$journal_file")

    echo "[$CURRENT/$TOTAL_FILES] Processing $filename..." | tee -a "$LOG_FILE"

    # Find Firebase URLs in this file
    firebase_urls=$(grep -o "https://firebasestorage\.googleapis\.com/v0/b/firescript[^)]*" "$journal_file" 2>/dev/null || echo "")

    if [ -z "$firebase_urls" ]; then
        echo "  No Firebase URLs found in $filename" | tee -a "$LOG_FILE"
        continue
    fi

    # Count URLs
    url_count=$(echo "$firebase_urls" | wc -l | tr -d ' ')
    echo "  Found $url_count Firebase URLs" | tee -a "$LOG_FILE"

    if [ "$DRY_RUN" = true ]; then
        echo "$firebase_urls" | while read -r url; do
            asset_filename=$(echo "$url" | sed -E 's/.*\/o\/([^?]+)\?.*/\1/')

            if [ -f "$ASSETS_DIR/$asset_filename" ]; then
                echo "    Would replace: $url" | tee -a "$LOG_FILE"
                echo "    With: ../assets/roam/$asset_filename" | tee -a "$LOG_FILE"
            else
                echo "    Asset not found locally for: $url" | tee -a "$LOG_FILE"
            fi
        done
    else
        # Create a temporary file for processing
        temp_file=$(mktemp)
        cp "$journal_file" "$temp_file"

        # Process each URL
        echo "$firebase_urls" | while read -r url; do
            # Extract just the filename part from the URL
            asset_filename=$(echo "$url" | sed -E 's/.*\/o\/([^?]+)\?.*/\1/')

            # Check if the asset exists locally
            if [ -f "$ASSETS_DIR/$asset_filename" ]; then
                # Escape URL for sed
                escaped_url=$(echo "$url" | sed 's/[\/&]/\\&/g')

                # Perform replacement
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    # macOS
                    sed -i '' "s|$escaped_url|../assets/roam/$asset_filename|g" "$temp_file"
                else
                    # Linux
                    sed -i "s|$escaped_url|../assets/roam/$asset_filename|g" "$temp_file"
                fi

                echo "    Replaced: $url" >> "$LOG_FILE"
            else
                echo "    Asset not found locally for: $url" >> "$LOG_FILE"
            fi
        done

        cp "$temp_file" "$journal_file"
        rm "$temp_file"
    fi
done

if [ "$DRY_RUN" = true ]; then
    echo "*** DRY RUN COMPLETED - Set DRY_RUN=false in the script to perform actual replacements ***" | tee -a "$LOG_FILE"
else
    echo "Replacements completed at $(date)" | tee -a "$LOG_FILE"
    echo "Backup of original files is in $BACKUP_DIR"
fi

echo "All done! Check $LOG_FILE for details."
