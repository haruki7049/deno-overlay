self: super: {
  deno = let
    pname = "deno";
    inherit (super.stdenv.hostPlatform) system;

    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;

    versions = builtins.map (v: lib.strings.removeSuffix "\n" v) (lib.splitString " " (builtins.readFile ./versions.txt));
    downloadURLs = builtins.map (v: lib.strings.removeSuffix "\n" v) (lib.splitString " " (builtins.readFile ./download-links.txt));

    x86_64-linuxURLs =
      builtins.filter (link: super.lib.strings.hasInfix "deno-x86_64-unknown-linux-gnu" link)
      downloadURLs;
    aarch64-linuxURLs =
      builtins.filter (link: super.lib.strings.hasInfix "deno-aarch64-unknown-linux-gnu" link)
      downloadURLs;
    x86_64-linuxUrlFetcher = version:
      builtins.head
      (builtins.filter (url: super.lib.strings.hasInfix version url)
        x86_64-linuxURLs);
    aarch64-linuxUrlFetcher = version:
      builtins.head
      (builtins.filter (url: super.lib.strings.hasInfix version url)
        aarch64-linuxURLs);

    mkBinaryInstall = version: x86_64-linuxHash: aarch64-linuxHash: super.stdenv.mkDerivation rec {
      inherit pname version;

      src = {
        x86_64-linux = super.fetchurl {
          url = x86_64-linuxUrlFetcher version;
          hash = x86_64-linuxHash;
        };
        aarch64-linux = super.fetchurl {
          url = aarch64-linuxUrlFetcher version;
          hash = aarch64-linuxHash;
        };
      }.${system};

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
  in {
    "1.42.0" = mkBinaryInstall "1.42.0" "sha256-3jbacxIAeBW/V2T7eN0S94OMtdiXow55FUt0idI2Oy8=" "";
  };
}
