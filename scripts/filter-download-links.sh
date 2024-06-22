#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash jq

if [ -p /dev/stdin ]; then
    download_urls=$(cat /dev/stdin \
        | jq '.[].assets' \
        | grep browser_download_url \
        | tr ' ' '\n' \
        | grep -v browser_download_url \
        | grep -v deno_src \
        | grep -v denort \
        | tr -d '"' \
        | sort)
    echo $download_urls
elif [[ -f $1 ]]; then
    download_urls=$(cat $1 \
        | jq '.[].assets' \
        | grep browser_download_url \
        | tr ' ' '\n' \
        | grep -v browser_download_url \
        | grep -v deno_src \
        | grep -v denort \
        | tr -d '"' \
        | sort)
    echo $download_urls
else
    echo "Error: File not found."
    echo "Usage: ./filter-x86_64-linux-links.sh <JSON>"
    echo "Process exited with code 1."
    exit 1
fi
