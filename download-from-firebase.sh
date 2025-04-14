#!/bin/bash
# This script downloads images from Firebase storage referenced in your Logseq journals and pages.
# It extracts all URLs from markdown files and downloads them to the assets directory.
#
# Usage: ./download-from-firebase.sh
#
# Note: This script assumes it's run from LOGSEQ_ROOT/scripts directory.
# The directory structure is expected to be:
# LOGSEQ_ROOT/
# ├── journals/
# ├── pages/
# ├── assets/roam/
# └── scripts/
#     └── download-from-firebase.sh

# Configuration
JOURNALS_DIR="../journals"
PAGES_DIR="../pages"
ASSETS_DIR="../assets/roam"
LOG_FILE="download.log"

echo "Extracting Firebase URLs..."
FIREBASE_URLS=$(grep -o --no-filename 'https://firebasestorage\.googleapis\.com/v0/b/firescript[^)]*' "$JOURNALS_DIR"/*.md "$PAGES_DIR"/*.md)

echo "Starting migration at $(date)" > "$LOG_FILE"
echo "Found $(echo "$FIREBASE_URLS" | wc -l) Firebase URLs" >> "$LOG_FILE"

echo "$FIREBASE_URLS" | while read -r url; do
    [ -z "$url" ] && continue

    echo "Downloading $url..."
    if curl -s --output-dir "$ASSETS_DIR" --remote-name "$url"; then
        echo "Downloaded $url" >> "$LOG_FILE"
        sleep 0.5
    fi

done
