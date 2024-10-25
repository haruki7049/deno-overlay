{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    crane.url = "github:ipetkov/crane";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      deno-overlay = import ./.;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake.overlays = {
        inherit deno-overlay;
      };

      perSystem =
        {
          pkgs,
          lib,
          self',
          system,
          ...
        }:
        let
          rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rust;
          overlays = [ deno-overlay inputs.rust-overlay.overlays.default ];
          fetch-releases-bin = craneLib.buildPackage {
            src = lib.cleanSource ./scripts/fetch-releases/.;
            strictDeps = true;

            doCheck = true;
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system overlays;
          };

          packages = {
            inherit fetch-releases-bin;
          };

          checks = {
            v0-36-0 = pkgs.callPackage ./example/v0.36.0 { };
            v1-42-0 = pkgs.callPackage ./example/v1.42.0 { };
            v1-44-4 = pkgs.callPackage ./example/v1.44.4 { };
            v2-0-0 = pkgs.callPackage ./example/v2.0.0 { };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.rustfmt.enable = true;
            programs.taplo.enable = true;
            programs.actionlint.enable = true;
            programs.shellcheck.enable = true;

            settings.formatter.shellcheck.excludes = [
              ".envrc"
            ];
          };

          devShells.default = pkgs.mkShell {
            packages = [
              # Rust-lang
              rust

              # Nix LSP
              pkgs.nil
            ];
          };
        };
    };
}
