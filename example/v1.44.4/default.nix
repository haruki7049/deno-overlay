{
  pkgs ? import <nixpkgs> {
    inherit overlays;
  },
  overlays ? [
    (import ../..)
  ],
}:

pkgs.deno."1.44.4"
