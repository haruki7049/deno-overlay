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
    pkgs.deno."0.36.0"
  ];
}
