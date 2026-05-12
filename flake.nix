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
        "aarch64-linux"
        "aarch64-darwin"
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
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Python
            programs.ruff.enable = true;

            # GitHub Action
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # Deno
            programs.deno.enable = true;
            programs.deno.package = pkgs.deno."2.0.0";
            settings.formatter.deno.includes = [ "*.ts" ];
            settings.formatter.deno.excludes = [
              "*.json"
              "*.yaml"
              "*.yml"
              "*.md"
            ];

            # Shell Script
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.nil # Nix LSP
              pkgs.deno."2.0.0" # Deno JavaScript & TypeScript runtime
            ];
          };
        };
    };
}
