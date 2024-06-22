#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk

if [ -p /dev/stdin ]; then
    download_urls=$(cat /dev/stdin | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep https://)
    echo $download_urls
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 | grep browser_download_url | gawk '{gsub(/ /, "\n"); print}' | uniq | grep https://)
    echo $download_urls
else
    echo "Error: File not found."
    echo "Usage: ./filter-x86_64-linux-links.sh <JSON>"
    echo "Process exited with code 1."
    exit 1
fi
