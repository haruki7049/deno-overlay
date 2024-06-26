{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
  };

  outputs = { self, nixpkgs, treefmt-nix, flake-utils, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        lib = pkgs.lib;
        craneLib = crane.mkLib pkgs;

        commonArgs = rec {
          src = craneLib.cleanCargoSource ./scripts/build-json;
          strictDeps = true;

          buildInputs = with pkgs; [
            openssl
          ];

          LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
        };

        build-json = craneLib.buildPackage (commonArgs // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        });
      in {
        formatter = treefmtEval.config.build.wrapper;
        checks = { formatting = treefmtEval.config.build.check self; };

        packages = { inherit build-json; };

        devShells.default =
          pkgs.mkShell { packages = with pkgs; [ nixd rustc cargo clang ]; };
      });
}
