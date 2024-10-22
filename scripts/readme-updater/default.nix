{
  stdenv,
  lib,
  bundlerEnv,
  ruby,
}:

let
  gems = bundlerEnv {
    name = "readme-updater";
    inherit ruby;
    gemdir = ./.;
  };
in

stdenv.mkDerivation {
  name = "readme-updater";
  src = lib.cleanSource ./.;

  buildInputs = [
    gems
    ruby
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/readme-updater}
    cp -r * $out/share/readme-updater
    bin=$out/bin/readme-updater

    cat > $bin <<EOF
    #!/bin/sh -e
    exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/readme-updater/main.rb "\$@"
    EOF

    chmod 744 $bin
  '';
}
