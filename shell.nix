with import <nixpkgs> { overlays = [ (import ./default.nix) ]; };

mkShell { packages = [ deno."1.42.0" ]; }
