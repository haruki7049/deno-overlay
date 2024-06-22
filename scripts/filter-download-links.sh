#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

# This script filters the download links from a GitHub release JSON file.

if [ -f "sources.json" ]; then
    download_urls=$(cat sources.json | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep -E 'https://.*' | sort -n )
    echo "$download_urls" | tr -d '"'
else
    echo "Not exists"
    exit 1
fi
