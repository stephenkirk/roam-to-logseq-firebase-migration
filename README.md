# Roam Research to Logseq Firebase Asset Migration

Simple scripts to migrate Firebase-hosted images from Roam Research to local Logseq assets.

## Scripts

1. `download-from-firebase.sh` - Downloads all Firebase images found in your Logseq journals and pages
2. `replace-firebase-urls.sh` - Replaces Firebase URLs with local asset paths

**Warning:** The `replace-firebase-urls` script creates backup files in your Logseq directory. Close Logseq before running the script or it will throw a fit and yell at you with duplicate file errors, forcing you to reindex your graph. After running, move backup files to a different location or delete them after verifying the script did what you expected.

## Usage

```bash
# Navigate to your Logseq directory and create scripts folder if it doesn't exist
cd /path/to/your/logseq/graph
mkdir -p scripts

# Copy these scripts to the scripts folder, then run from there:
cd scripts

# First download all Firebase assets
./download-from-firebase.sh

# Then replace references in your markdown files
# (Set DRY_RUN=false in the script when ready)
./replace-firebase-urls.sh
```

These scripts assume you are running them from a folder `scripts` in your Logseq graph root directory.

## Disclaimer

I solemnly swear these scripts are up to no good. While they work wonderfully on my machine, your mileage may vary.
