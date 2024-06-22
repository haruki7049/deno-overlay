#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash curl

# Fetching the releases of Deno by using GitHub's REST-API.

json_data=$(curl https://api.github.com/repos/denoland/deno/releases)
echo $json_data
