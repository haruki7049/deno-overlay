#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

# Filtering the x86_64-linux's download link from the JSON file, from GitHub's REST-API.
# Usage: ./filter-x86_64-linux-links.sh <JSON>

if [ -p /dev/stdin ]; then
    download_urls=$(cat /dev/stdin | gawk '{gsub(/ /, "\n"); print}' | uniq | grep deno-x86_64-unknown-linux-gnu | grep https:// | tr -d '"')
    echo $download_urls
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 | gawk '{gsub(/ /, "\n"); print}' | uniq | grep deno-x86_64-unknown-linux-gnu | grep https:// | tr -d '"')
    echo $download_urls
else
    echo "Error: File not found."
    echo "Usage: ./filter-x86_64-linux-links.sh <JSON>"
    echo "Process exited with code 1."
    exit 1
fi
