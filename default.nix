self: super: {
  deno =
    let
      lib = super.lib;
      sources = lib.importJSON ./sources.json;
      mkBinaryInstall = super.callPackage ./nix/mkBinaryInstall.nix { };
      system = super.stdenv.hostPlatform.system;
      versions = lib.unique (map (source: source.version) sources.deno);
      getSourcesForVersion = version: lib.filter (source: source.version == version) sources.deno;
      findSourceForVersion =
        version:
        let
          versionSources = getSourcesForVersion version;
        in
        if versionSources == [ ] then
          null
        else
          lib.findFirst (source: source.arch == system) (builtins.head versionSources) versionSources;
    in
    builtins.listToAttrs (
      map (version: {
        name = version;
        value =
          let
            versionSources = getSourcesForVersion version;
            source = findSourceForVersion version;
            availableArchs = lib.concatStringsSep ", " (map (entry: entry.arch) versionSources);
          in
          if source == null then
            throw "No source found for version ${version} on architecture ${system}; available architectures: ${availableArchs}"
          else
            mkBinaryInstall {
              inherit version;
              url = source.url;
              arch = source.arch;
              sha256 = source.sha256;
            };
      }) versions
    );
}
