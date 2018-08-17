SPEC_EXT = .json
SRC_DIR = dss/
SPEC_DIR = specs/
OUT_DIR = out/
SPECS = tune frob
TMPDIR=$(CURDIR)/tmp

export PATH
export TMPDIR

test_dir=out
tests=$(wildcard $(test_dir)/*)

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

test:  $(tests:=.test)
	pkill klab

pre-test:
	klab server & mkdir -p $(TMPDIR) 

%.test: pre-test
	klab run --headless --force --spec $*


clean: dapp-clean
	rm $(OUT_DIR)*
