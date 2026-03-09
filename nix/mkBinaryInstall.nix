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

let
  canExecute = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
in

stdenv.mkDerivation (finalAttrs: {
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

  postIntall = lib.optionalString canExecute ''
    installShellCompletion --cmd deno \
      --bash <($out/bin/deno completions bash) \
      --fish <($out/bin/deno completions fish \
      --zsh <($out/bin/deno completions zsh)
  '';

  doInstallCheck = canExecute;

  installCheckPhase = lib.optionalString canExecute ''
    runHook preInstallCheck

    $out/bin/deno --help
    $out/bin/deno --version | grep "deno ${finalAttrs.version}"

    runHook postInstallCheck
  '';

  meta = {
    description = "A secure runtime for JavaScript and TypeScript";
    homepage = "https://deno.land/";
    mainProgram = "deno";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
})
