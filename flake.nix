{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
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

      perSystem = { pkgs, ... }: {
        treefmt = {
          projectRootFile = "flake.nix";
          programs.nixpkgs-fmt.enable = true;
          programs.ruff.enable = true;
          programs.actionlint.enable = true;
          programs.shellcheck.enable = true;
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
