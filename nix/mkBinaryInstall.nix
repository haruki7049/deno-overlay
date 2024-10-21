{
  lib,
  stdenv,
  darwin,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  libgcc,
  libiconv,
}:

{
  pname ? "deno",
  version,
  url,
  sha256,
}:

stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchurl { inherit url sha256; };
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    libgcc
  ];

  buildInputs = lib.optionals stdenv.isDarwin (
    [
      libiconv
      darwin.libobjc
    ]
    ++ (with darwin.apple_sdk_11_0.frameworks; [
      Security
      CoreServices
      Metals
      MetalPerformanceShaders
      Foundation
      QuartzCore
    ])
  );

  libraries = lib.makeLibraryPath buildInputs;

  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 deno $out/bin/deno
  '';

  postFixup = ''
    wrapProgram $out/bin/deno \
      --set LD_LIBRARY_PATH ${libraries}
  '';

  meta = {
    description = "A secure runtime for JavaScript and TypeScript";
    homepage = "https://deno.land/";
    mainProgram = "deno";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}
