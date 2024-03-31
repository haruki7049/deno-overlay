{
  description = "An overlay for Godot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = { self, systems, nixpkgs, treefmt-nix }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs (import systems)
        (system: f nixpkgs.legacyPackages.${system});
      treefmtEval =
        eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in {
      # Use `nix fmt`
      formatter =
        eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      # Use `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
