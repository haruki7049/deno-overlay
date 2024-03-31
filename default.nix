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

      installPhase = ''
        mkdir $out/bin
        install -m 0755 deno $out/bin/deno
      '';
    };
  };
}
