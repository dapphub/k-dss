KLAB_OUT = out
export KLAB_OUT

PATH := $(CURDIR)/deps/klab/bin:$(PATH)
export PATH

include.mak: Makefile deps/klab/makefile.timestamp
	klab make > include.mak

include include.mak

DAPP_DIR = $(CURDIR)/dss

.PHONY: all deps dapp kevm klab gen-spec gen-gas clean

all: deps spec

deps: dapp kevm klab

dapp:
	dapp --version
	git submodule update --init --recursive -- dss
	cd $(DAPP_DIR) && dapp --use solc:0.5.12 build && cd ../

kevm:
	git submodule update --init --recursive -- deps/evm-semantics
	cd deps/evm-semantics/                                                \
	    && make deps RELEASE=true SKIP_HASKELL=true SKIP_LLVM=true        \
	    && make build-java RELEASE=true -j4 JAVA_KOMPILE_OPTS=--emit-json

klab: deps/klab/makefile.timestamp

deps/klab/makefile.timestamp:
	git submodule update --init --recursive -- deps/klab
	cd deps/klab/                   \
	    && npm install              \
	    && touch makefile.timestamp

specs/%.k: $(KLAB_OUT)/built/%
	cp $(KLAB_OUT)/specs/$$($(HASH) $*).k $@

specs/%.gas: $(KLAB_OUT)/gas/%.raw
	cp $< $@

gen-spec: $(patsubst %, specs/%.k, $(all_specs))
gen-gas:  $(patsubst %, specs/%.gas, $(pass_rough_specs))

dapp-clean:
	cd $(DAPP_DIR) && dapp clean && cd ../

clean: dapp-clean out-clean

out-clean:
	rm -rf $(KLAB_OUT)
