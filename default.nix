self: super: {
  deno =
    let
      lib = super.lib;
      sources = lib.importJSON ./sources.json;
      mkBinaryInstall = super.callPackage ./nix/mkBinaryInstall.nix { };
    in
    builtins.listToAttrs (map (v: { name = v.version; value = mkBinaryInstall { version = v.version; url = v.url; sha256 = v.sha256; }; }) sources.deno);
}
