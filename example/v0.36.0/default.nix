{
  pkgs ? import <nixpkgs> {
    inherit overlays;
  },
  overlays ? [
    (import ../..)
  ],
}:

pkgs.deno."0.36.0"
