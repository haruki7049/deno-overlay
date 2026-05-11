self: super: {
  deno =
    let
      lib = super.lib;
      sources = lib.importJSON ./sources.json;
      mkBinaryInstall = super.callPackage ./nix/mkBinaryInstall.nix { };
      system = super.stdenv.hostPlatform.system;
      versions = lib.unique (map (source: source.version) sources.deno);
      findSourceForVersion =
        version:
        let
          systemSource = lib.findFirst (
            source: source.version == version && source.arch == system
          ) null sources.deno;
          fallbackSource = lib.findFirst (
            source: source.version == version && source.arch == "x86_64-linux"
          ) null sources.deno;
        in
        if systemSource != null then systemSource else fallbackSource;
    in
    builtins.listToAttrs (
      map (version: {
        name = version;
        value =
          let
            source = findSourceForVersion version;
          in
          mkBinaryInstall {
            inherit version;
            url = source.url;
            arch = source.arch;
            sha256 = source.sha256;
          };
      }) versions
    );
}
