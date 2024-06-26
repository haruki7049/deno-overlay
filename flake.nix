{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, treefmt-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        fetch-json = pkgs.rustPlatform.buildRustPackage {
          name = "fetch-json";
          src = ./scripts/fetch-json;

          cargoHash = "sha256-gbw4ZIb9kbculTGISIlq6az3Eq0M4S+0kGDcq7gmvbk=";
        };
      in {
        formatter = treefmtEval.config.build.wrapper;
        checks = { formatting = treefmtEval.config.build.check self; };

        packages = { inherit fetch-json; };

        devShells.default =
          pkgs.mkShell { packages = with pkgs; [ nixd rustc cargo clang ]; };
      });
}
