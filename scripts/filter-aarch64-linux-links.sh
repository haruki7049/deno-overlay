#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

# Filtering the aarch64-linux's download link from the JSON file, from GitHub's REST-API.
# Usage: ./filter-aarch64-linux-links.sh <JSON>

if [[ -z $1 ]]; then
    echo "Error: No JSON file provided."
    echo "Usage: ./filter-aarch64-linux-links.sh <JSON>"
    echo "Process exited with code 1."
    exit 1
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep deno-aarch64-unknown-linux-gnu)
    echo $download_urls
else
    echo "Error: File not found."
    echo "Usage: ./filter-aarch64-linux-links.sh <JSON>"
    echo "Process exited with code 2."
    exit 2
fi
