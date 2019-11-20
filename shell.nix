with import <nixpkgs> {};
let
  pkgs-6ec8fe0 = import (fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    rev = "6ec8fe0408d8940dcbeea6b01cab071062fd8f2d";
  }) {};
in
stdenv.mkDerivation {
  name = "k-dss";
  buildInputs = [
    bc
    flex
    getopt
    utillinux
    git
    gnumake
    jq
    nodejs
    openjdk8
    parallel
    wget
    zip
    pkgs-6ec8fe0.z3
  ];
  shellHook = ''
    if [ -z "$KLAB_PATH" ]; then echo "WARNING: The environment variable KLAB_PATH should be set to point to the klab repo. Please fix and reënter the nix shell."; fi
    export PATH=$KLAB_PATH/node_modules/.bin/:$KLAB_PATH/bin:$PATH
    export KLAB_EVMS_PATH=$KLAB_PATH/evm-semantics
  '';
}
