#! /usr/bin/env nix-shell
#! nix-shell -p bash jq coreutils -i bash

# shellcheck disable=SC1008,SC2016

versions=$(jq ".[].[].version" < sources.json | tr -d \" | sed -e "s/^/- /g")
readme='# deno-overlay
A Deno overlay for Nix package manager.

# Usage
```nix
let
  deno_overlay = import (fetchTarball https://github.com/haruki7049/deno-overlay/archive/7a6d6faa0f3bbc4aafb6ee7306a88e800f4dc5d8.tar.gz);
  pkgs = import <nixpkgs> {
    overlays = [
      deno_overlay
    ];
  };
  denoVersion = "1.42.0";
in
pkgs.mkShell {
  packages = with pkgs; [
    deno.${denoVersion}
  ];
}
```

## Architectures
- x86_64-linux

## A list of versions this overlay can support'

printf "%s\n%s" "$readme" "$versions" > README.md
