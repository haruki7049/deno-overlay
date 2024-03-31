self: super:
{
  deno = {
    "1.42.0" = super.stdenv.mkDerivation rec {
      pname = "deno";
      version = "1.42.0";

      src = super.fetchzip {
        url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
        hash = "sha256-i/y5T8y4RABYb2b7qAF2eP70tSPeBGtRQVL/zuY2+Ik=";
      };

      nativeBuildInputs = [
        super.autoPatchelfHook
        super.makeWrapper
        super.unzip
        super.libgcc
      ];

      buildInputs = super.lib.optionals super.stdenv.isDarwin (
        [super.libiconv super.darwin.libobjc]
        ++ (with super.darwin.apple_sdk_11_0.frameworks; [
          Security
          CoreServices
          Metals
          MetalPerformanceShaders
          Foundation
          QuartzCore
        ])
      );

      libraries = super.lib.makeLibraryPath buildInputs;

      installPhase = ''
        mkdir -p $out/bin
        install -m 0755 deno $out/bin/deno
      '';

      postFixup = ''
        wrapProgram $out/bin/deno \
          --set LD_LIBRARY_PATH ${libraries}
      '';
    };
  };
}
