# Roam Research to Logseq Firebase Asset Migration

Simple scripts to migrate Firebase-hosted images from Roam Research to local Logseq assets.

## Scripts

1. `download-from-firebase.sh` - Downloads all Firebase images found in your Logseq journals and pages
2. `replace-firebase-urls.sh` - Replaces Firebase URLs with local asset paths

## Usage

```bash
# First download all Firebase assets
./scripts/download-from-firebase.sh

# Then replace references in your markdown files
# (Set DRY_RUN=false in the script when ready)
./scripts/replace-firebase-urls.sh
```

These scripts assume you are running them from a folder `scripts` in your Logseq graph root directory.

## Disclaimer

I solemnly swear these scripts are up to no good. While they work wonderfully on my machine, your mileage may vary.
