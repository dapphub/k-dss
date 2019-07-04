with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "k-dss";
  buildInputs = [
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
    z3
  ];
  shellHook = ''
    if [ -z "$KLAB_PATH" ]; then echo "WARNING: The environment variable KLAB_PATH should be set to point to the klab repo. Please fix and reënter the nix shell."; fi
    export PATH=$KLAB_PATH/node_modules/.bin/:$KLAB_PATH/bin:$PATH
    export KLAB_EVMS_PATH=$KLAB_PATH/evm-semantics
  '';
}
