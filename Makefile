SPEC_EXT = .json
SRC_DIR = dss/
SPEC_DIR = specs/
OUT_DIR = out/
SPECS = tune frob

all: $(SPECS)

$(SPECS): dapp
	./abi2specs $(SPEC_DIR)$@$(SPEC_EXT)
dapp:
	git submodule update --init --recursive
	cd $(SRC_DIR) && dapp build && cd ../

dapp-clean:
	cd $(SRC_DIR) && dapp clean && cd ../

clean: dapp-clean
	rm $(OUT_DIR)*
