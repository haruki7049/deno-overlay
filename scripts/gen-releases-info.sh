#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash gnugrep gawk jq nurl

versions=$(cat ../versions.txt)
urls=$(cat ../download-links.txt)
json='[]'

for i in "${!versions[@]}"; do
    version=$(echo "$versions" | gawk '{ print $i }')
    x86_url=$(echo "$urls" | grep "$version" | grep deno-x86_64-unknown-linux-gnu)
    nix_hash=$(nix-prefetch fetchurl "$x86_url")

    echo $nix_hash
done
