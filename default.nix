self: super: {
  deno =
    let
      pkgs = import <nixpkgs> { };
      fetchurl = pkgs.fetchurl;
      stdenv = pkgs.stdenv;

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
    {
      "1.42.0" = mkBinaryInstall {
        version = "1.42.0";
        url = "https://github.com/denoland/deno/releases/download/v1.42.0/deno-x86_64-unknown-linux-gnu.zip";
        sha256 = "sha256-3jbacxIAeBW/V2T7eN0S94OMtdiXow55FUt0idI2Oy8=";
      };
      "1.44.4" = mkBinaryInstall {
        version = "1.44.4";
        url = "https://github.com/denoland/deno/releases/download/v1.44.4/deno-x86_64-unknown-linux-gnu.zip";
        sha256 = "";
      };
    };
}
