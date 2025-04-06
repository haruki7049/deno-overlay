{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,

  unzip,
  libgcc,
}:

{
  pname ? "deno",
  version,
  url,
  sha256,
}:

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl { inherit url sha256; };
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
    libgcc
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 deno $out/bin/deno
  '';

  meta = {
    description = "A secure runtime for JavaScript and TypeScript";
    homepage = "https://deno.land/";
    mainProgram = "deno";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}
