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
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, ... }:
        {
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
