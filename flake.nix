{
  description = "An overlay for Deno javascript runtime";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, treefmt-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        lib = pkgs.lib;
        treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        fetchurl = pkgs.fetchurl;
        stdenv = pkgs.stdenv;
        deno =
          let
            mkBinaryInstall = { pname ? "deno", version, url, sha256 }:
              stdenv.mkDerivation rec {
                inherit pname version;

                src = fetchurl { inherit url sha256; };
                sourceRoot = ".";

                nativeBuildInputs = with pkgs;
                  [ autoPatchelfHook makeWrapper unzip libgcc ];

                buildInputs = lib.optionals stdenv.isDarwin
                  ([ pkgs.libiconv pkgs.darwin.libobjc ]
                    ++ (with pkgs.darwin.apple_sdk_11_0.frameworks; [
                    Security
                    CoreServices
                    Metals
                    MetalPerformanceShaders
                    Foundation
                    QuartzCore
                  ]));

                libraries = lib.makeLibraryPath buildInputs;

                installPhase = ''
                  mkdir -p $out/bin
                  install -m 0755 deno $out/bin/deno
                '';

                postFixup = ''
                  wrapProgram $out/bin/deno \
                    --set LD_LIBRARY_PATH ${libraries}
                '';

                meta = with lib; {
                  description = "A secure runtime for JavaScript and TypeScript";
                  homepage = "https://deno.land/";
                  mainProgram = "deno";
                  platforms = [ "x86_64-linux" ];
                  license = licenses.mit;
                };
              };
          in {
            "1.42.0" = mkBinaryInstall {
              version = "1.42.0";
              url = "https://github.com/denoland/deno/releases/download/v1.42.0/deno-x86_64-unknown-linux-gnu.zip";
              sha256 = "0brv6v98jx2b2mwhx8wpv2sqr0zp2bfpiyv4ayziay0029rxldny";
            };
            "1.44.4" = mkBinaryInstall {
              version = "1.44.4";
              url = "https://github.com/denoland/deno/releases/download/v1.44.4/deno-x86_64-unknown-linux-gnu.zip";
              sha256 = "0mgfx70crrahpg9rj6q319k8bf3d7122zjik3ygwxl1jm89nv3y4";
            };
          };
      in
      {
        formatter = treefmtEval.config.build.wrapper;
        checks = {
          formatting = treefmtEval.config.build.check self;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nixd
          ];
        };
      });
}
