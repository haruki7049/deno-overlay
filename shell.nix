with import <nixpkgs> { overlays = [ (import ./default.nix) ]; };

mkShell { packages = [ deno."1.44.4" ]; }
