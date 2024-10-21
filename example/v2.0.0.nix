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
    pkgs.deno."2.0.0"
  ];
}
