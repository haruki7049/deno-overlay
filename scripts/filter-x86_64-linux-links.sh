#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

echo $1 | grep "deno" | grep "unknown-linux-gnu"
