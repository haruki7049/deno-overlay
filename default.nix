self: super:
{
  deno = {
    "1.42.0" = super.stdenv.mkDerivation rec {
      pname = "deno";
      version = "1.42.0";

      src = super.fetchzip {
        url = "https://github.com/denoland/deno/releases/download/v${version}/deno-x86_64-unknown-linux-gnu.zip";
        hash = "";
      };

      installPhase = ''
        mkdir $out/bin
        install -m 0755 deno $out/bin/deno
      '';
    };
  };
}
