self: super: {
  deno =
    let
      lib = super.lib;
      fetchurl = super.fetchurl;
      stdenv = super.stdenv;
      sources = lib.importJSON ./sources.json;

      mkBinaryInstall = { pname ? "deno", version, url, sha256 }:
        stdenv.mkDerivation rec {
          inherit pname version;

          src = fetchurl { inherit url sha256; };
          sourceRoot = ".";

          nativeBuildInputs =
            [ super.autoPatchelfHook super.makeWrapper super.unzip super.libgcc ];

          buildInputs = super.lib.optionals super.stdenv.isDarwin
            ([ super.libiconv super.darwin.libobjc ]
              ++ (with super.darwin.apple_sdk_11_0.frameworks; [
              Security
              CoreServices
              Metals
              MetalPerformanceShaders
              Foundation
              QuartzCore
            ]));

          libraries = super.lib.makeLibraryPath buildInputs;

          installPhase = ''
            mkdir -p $out/bin
            install -m 0755 deno $out/bin/deno
          '';

          postFixup = ''
            wrapProgram $out/bin/deno \
              --set LD_LIBRARY_PATH ${libraries}
          '';

          meta = with super.lib; {
            description = "A secure runtime for JavaScript and TypeScript";
            homepage = "https://deno.land/";
            mainProgram = "deno";
            platforms = [ "x86_64-linux" ];
            license = licenses.mit;
          };
        };
    in
    builtins.listToAttrs (map (v: { name = v.version; value = mkBinaryInstall { version = v.version; url = v.url; sha256 = v.sha256; }; }) sources.deno);
}
