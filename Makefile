SPEC_EXT = .json
SRC_DIR = dss/
SPEC_DIR = specs/
OUT_DIR = out/
SPECS = tune frob

all: dapp deps-npm spec

spec:
	./abi2specs specification.md

dapp:
	git submodule update --init --recursive
	cd $(SRC_DIR) && dapp build && cd ../

dapp-clean:
	cd $(SRC_DIR) && dapp clean && cd ../

deps-npm:
	npm install

clean: dapp-clean
	rm $(OUT_DIR)*
