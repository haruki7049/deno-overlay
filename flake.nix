{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
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
          self',
          system,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              deno-overlay
            ];
          };

          checks = {
            #v0-36-0 = pkgs.callPackage ./example/v0.36.0 { };
            v1-42-0 = pkgs.callPackage ./example/v1.42.0 { };
            #v1-44-4 = pkgs.callPackage ./example/v1.44.4 { };
            #v2-0-0 = pkgs.callPackage ./example/v2.0.0 { };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.ruff.enable = true;
            programs.actionlint.enable = true;
            programs.shellcheck.enable = true;

            settings.formatter.shellcheck.excludes = [
              ".envrc"
            ];
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nil
              ruff
              python311
            ];
          };
        };
    };
}
