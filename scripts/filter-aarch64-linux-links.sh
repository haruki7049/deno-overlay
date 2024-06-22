#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

# Filtering the aarch64-linux's download link from the JSON file, from GitHub's REST-API.
# Usage: ./filter-aarch64-linux-links.sh <JSON>

if [ -p /dev/stdin ]; then
    download_urls=$(cat /dev/stdin | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep deno-aarch64-unknown-linux-gnu | grep https:// | tr -d '"')
    echo $download_urls
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep deno-aarch64-unknown-linux-gnu | grep https:// | tr -d '"')
    echo $download_urls
else
    echo "Error: File not found."
    echo "Usage: ./filter-aarch64-linux-links.sh <JSON>"
    echo "Process exited with code 1."
    exit 1
fi
