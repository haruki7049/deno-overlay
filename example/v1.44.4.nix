{ pkgs ? import <nixpkgs> {
    inherit overlays;
  }
, overlays ? [
    (import ../default.nix)
  ]
, mkShell ? pkgs.mkShell
}:

mkShell {
  packages = [
    pkgs.deno."1.44.4"
  ];
}
