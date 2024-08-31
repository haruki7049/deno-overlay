{
  projectRootFile = "treefmt.nix";
  programs.nixpkgs-fmt.enable = true;
  programs.ruff.enable = true;
  programs.actionlint.enable = true;
  programs.shellcheck.enable = true;
}
