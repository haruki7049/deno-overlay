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
  srcs,
}:

let
  src-hash-attrs =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  src = fetchurl {
    inherit (src-hash-attrs) url sha256;
  };
in

stdenv.mkDerivation rec {
  inherit pname version src;

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
    license = lib.licenses.mit;
  };
}
