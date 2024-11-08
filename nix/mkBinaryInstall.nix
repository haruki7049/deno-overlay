{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  libgcc,
}:

{
  pname ? "deno",
  version,
  source-attrset,
}:

let
  srcs = {
    x86_64-linux = fetchurl { url = "https://github.com/denoland/deno/releases/download/v1.42.0/deno-x86_64-unknown-linux-gnu.zip"; sha256 = "0brv6v98jx2b2mwhx8wpv2sqr0zp2bfpiyv4ayziay0029rxldny"; };
    aarch64-linux = fetchurl { url = "https://github.com/denoland/deno/releases/download/v1.42.0/deno-aarch64-unknown-linux-gnu.zip"; sha256 = "0kk35z2ffizaspv9qyz334kn03nxgkms0mqzx639jg1vr1k4rxim"; };
  };
in

stdenv.mkDerivation rec {
  inherit pname version;
  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    libgcc
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 deno $out/bin/deno
  '';

  #postFixup = ''
  #  wrapProgram $out/bin/deno \
  #    --set LD_LIBRARY_PATH ${libraries}
  #'';

  meta = {
    description = "A secure runtime for JavaScript and TypeScript";
    homepage = "https://deno.land/";
    mainProgram = "deno";
    license = lib.licenses.mit;
  };
}
