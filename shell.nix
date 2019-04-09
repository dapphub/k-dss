with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "k-dss";
  buildInputs = [
    git
    gnumake
    nodejs
  ];
  shellHook = ''
    export PATH=$KLAB_DIR/node_modules/.bin/:$KLAB_DIR/bin:$PATH
    export KLAB_EVMS_PATH=$KLAB_DIR/evm-semantics
  '';
}
