SRC_DIR = dss/
OUT_DIR = out/
TMPDIR = $(CURDIR)/tmp

export PATH
export TMPDIR

test_dir = out
tests = $(wildcard $(test_dir)/*)

passing_tests = out/Vat_root_succ.ini \
		out/Vat_dai_succ.ini \
		out/Vat_sin_succ.ini \
		out/Vat_ilks_succ.ini \
		out/Vat_urns_succ.ini \
		out/Vat_Tab_succ.ini \
		out/Vat_vice_succ.ini \
		out/Vat_file_succ.ini \
		out/Vat_move-uint_succ.ini \
		out/Vat_move-int_succ.ini \
		out/Vat_slip_succ.ini \
		out/Vat_slip_fail.ini

all: dapp spec

spec: deps-npm
	./abi2specs specification.md

dapp:
	git submodule update --init --recursive
	cd $(SRC_DIR) && dapp build && cd ../

dapp-clean:
	cd $(SRC_DIR) && dapp clean && cd ../

deps-npm:
	npm install

test:  $(passing_tests:=.test)
	pkill klab

pre-test:
	klab server & mkdir -p $(TMPDIR) 

%.test: pre-test
	klab run --headless --force --spec $*

clean: dapp-clean
	rm -rf $(OUT_DIR)*
