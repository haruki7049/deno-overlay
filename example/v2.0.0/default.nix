{
  pkgs ? import <nixpkgs> {
    inherit overlays;
  },
  overlays ? [
    (import ../..)
  ],
}:

pkgs.deno."2.0.0"