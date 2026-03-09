{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs =
    inputs:
    let
      deno-overlay = import ./.;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake.overlays = {
        inherit deno-overlay;
      };

      perSystem =
        {
          pkgs,
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

          packages = {
            default = pkgs.deno."2.0.0";
          };

          checks = {
            v0-36-0 = pkgs.deno."0.36.0";
            v1-42-0 = pkgs.deno."1.42.0";
            v1-44-4 = pkgs.deno."1.44.0";
            v2-0-0 = pkgs.deno."2.0.0";
            v2-2-5 = pkgs.deno."2.2.5";
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
