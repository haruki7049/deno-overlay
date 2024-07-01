# deno-overlay
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

## A list of versions this overlay can support
- 1.42.0
- 1.44.4
