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

## Architectures
- x86_64-linux

## A list of versions this overlay can support
- 2.4.2
- 2.2.14
- 2.4.1
- 2.4.0
- 2.3.7
- 2.3.6
- 2.3.5
- 2.3.4
- 2.3.3
- 2.3.2
- 2.2.13
- 2.1.13
- 2.3.1
- 2.3.0
- 2.2.12
- 2.2.11
- 2.2.10
- 2.2.9
- 2.1.12
- 2.1.11
- 2.2.8
- 2.2.7
- 2.2.6
- 2.2.5
- 2.2.4
- 2.2.3
- 2.2.2
- 2.2.1
- 2.2.0
- 2.1.10