{
  stdenv,
  lib,
  bundlerEnv,
  ruby,
}:

let
  gems = bundlerEnv {
    name = "fetch-releases";
    inherit ruby;
    gemdir = ./.;
  };
in

stdenv.mkDerivation {
  name = "fetch-releases";
  src = lib.cleanSource ./.;

  buildInputs = [
    gems
    ruby
  ];

  installPhase = ''
    mkdir -p $out/{bin,share/fetch-releases}
    cp -r * $out/share/fetch-releases
    bin=$out/bin/fetch-releases

    cat > $bin <<EOF
    #!/bin/sh -e
    exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/fetch-releases/main.rb "\$@"
    EOF

    chmod 744 $bin
  '';
}
