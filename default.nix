{ pkgs ? import ./nixpkgs.nix {} }: with pkgs;

let
  name = "mvnix";
  version = "0.1.0";
  gen-header = "# This file has been generated by ${name} ${version}.";

  default-tmpl = writeText "default-tmpl.nix" ''
    ${gen-header} Configure the build here!
    { pkgs ? import <nixpkgs> {}
    , mavenix ? pkgs.callPackage (import ./%%env%%) {}
    , src ? ./%%src%%
    , doCheck ? false
    }: mavenix {
      inherit src doCheck;
      infoFile = ./%%info%%;
      # settings = ./settings.xml;
      # deps = [ { path = "org/extra/dependencies"; sha1 = ""; } ];
      # drvs = [ ];
      # buildInputs = [ git ];
      # maven = maven.override { jdk = oraclejdk10; };
    }
  '';
in stdenv.mkDerivation {
  inherit name;
  src = ./.;
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp mvnix-init mvnix-update $out/bin
    wrapProgram $out/bin/mvnix-init \
      --set CONFIG_TEMPLATE ${default-tmpl} \
      --set MAVENIX_SCRIPT  ${./mavenix.nix}
    wrapProgram $out/bin/mvnix-update \
      --prefix PATH : ${lib.makeBinPath [ yq nix mktemp ]}
  '';
}
