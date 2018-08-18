SRC_DIR = dss/
OUT_DIR = out/
TMPDIR=$(CURDIR)/tmp

export PATH
export TMPDIR

test_dir=out
tests=$(wildcard $(test_dir)/*)

passingtests=out/Vat_dai_succ.ini out/Vat_slip_succ.ini out/Vat_sin_succ.ini

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

test:  $(passingtests:=.test)
	pkill klab

pre-test:
	klab server & mkdir -p $(TMPDIR) 

%.test: pre-test
	klab run --headless --force --spec $*


clean: dapp-clean
	rm $(OUT_DIR)*
