#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

# Filtering the version (Release's tag) from the download link of Deno, from GitHub's REST-API.
# Usage: ./filter-deno-versions.sh <JSON>

if [ -p /dev/stdin ]; then
    download_urls=$(cat /dev/stdin | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep -E 'https://.*' | tr -d '"' | sort | gawk -F/ '{ print $8 }' | uniq)
    echo $download_urls
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep -E 'https://.*' | tr -d '"' | sort | gawk -F/ '{ print $8 }' | uniq)
    echo $download_urls
else
    echo "Error: File not found."
    echo "Process exited with code 1."
    exit 1
fi
