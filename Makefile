DAPP_DIR = $(CURDIR)/dss
SRC_DIR = $(CURDIR)/src
SRCS = $(addprefix $(SRC_DIR)/, dss.md lemmas.k.md storage.k.md prelude.smt2.md)
DAPP_SRCS = $(wildcard $(DAPP_DIR)/src/*)
# if KLAB_OUT isn't defined, default is to use out/
OUT_DIR_LOCAL   = out
KLAB_OUT_LOCAL  = $(OUT_DIR_LOCAL)
OUT_DIR         = $(CURDIR)/$(OUT_DIR_LOCAL)
KLAB_OUT       ?= $(OUT_DIR)
KLAB_EVMS_PATH ?= $(CURDIR)/deps/evm-semantics
export KLAB_OUT
export KLAB_EVMS_PATH
TMPDIR ?= $(CURDIR)/tmp
SPECS_DIR = $(OUT_DIR)/specs
ACTS_DIR = $(OUT_DIR)/acts
DOC_DIR = $(OUT_DIR)/doc

KLAB       = klab
HASH       = klab hash
PROVE      = $(KLAB) prove
BUILD      = $(KLAB) build-spec
GET_GAS    = $(KLAB) get-gas
WRITE_GAS  = python3 write-gas.py
KLAB_MAKE  = $(KLAB) make
PROVE_DUMP = $(KLAB) prove --dump
PROVE_ARGS = --concrete-rules $(shell cat $(KLAB_EVMS_PATH)/tests/specs/mcd/concrete-rules.txt | tr '\n' ',')

SMT_PRELUDE = $(OUT_DIR)/prelude.smt2
RULES = $(OUT_DIR)/rules.k

SPEC_MANIFEST = $(SPECS_DIR)/specs.manifest

.PHONY: all deps spec dapp kevm klab doc gen-spec gen-gas \
        clean dapp-clean spec-clean doc-clean log-clean

PATH := $(CURDIR)/deps/klab/bin:$(KLAB_EVMS_PATH)/deps/k/k-distribution/target/release/k/bin:$(PATH)
export PATH

PYTHONPATH := $(KLAB_EVMS_PATH)/deps/k/k-distribution/target/release/k/lib/kframework
export PYTHONPATH

SPEC_SRCS = src/dss.md $(KLAB_OUT_LOCAL)/specs/verification.k

include.mak: Makefile deps/klab/makefile.timestamp $(SPEC_SRCS)
	$(KLAB_MAKE) > include.mak

include include.mak

all: deps spec

deps: dapp kevm klab

dapp:
	dapp --version
	git submodule update --init --recursive -- dss
	cd $(DAPP_DIR) && dapp --use solc:0.5.12 build && cd ../

kevm:
	git submodule update --init --recursive -- deps/evm-semantics
	cd deps/evm-semantics/                                                \
	    && make deps RELEASE=true                                         \
	    && make build-java RELEASE=true -j4 JAVA_KOMPILE_OPTS=--emit-json

klab: deps/klab/makefile.timestamp

deps/klab/makefile.timestamp:
	git submodule update --init --recursive -- deps/klab
	cd deps/klab/                   \
	    && npm install              \
	    && touch makefile.timestamp

$(KLAB_OUT_LOCAL)/specs/verification.k: src/verification.k
	@mkdir -p $(KLAB_OUT_LOCAL)/specs
	@mkdir -p $(KLAB_OUT_LOCAL)/specs
	@mkdir -p $(KLAB_OUT_LOCAL)/acts
	@mkdir -p $(KLAB_OUT_LOCAL)/gas
	@mkdir -p $(KLAB_OUT_LOCAL)/meta/name
	@mkdir -p $(KLAB_OUT_LOCAL)/meta/data
	@mkdir -p $(KLAB_OUT_LOCAL)/output
	@mkdir -p $(CURDIR)/specs
	cp $< $@

%.hash:
	$(HASH) $*

%.klab-view:
	$(KLAB) debug $$($(HASH) $*)

specs/%.k: out/built/%
	cp out/specs/$$($(HASH) $*).k $@

specs/%.gas: $(KLAB_OUT_LOCAL)/gas/%.raw
	cp $< $@

.SECONDARY: $(patsubst %, specs/%.gas, $(all_specs))                  \
            $(patsubst %, $(KLAB_OUT_LOCAL)/gas/%.json, $(all_specs)) \
            $(patsubst %, $(KLAB_OUT_LOCAL)/gas/%, $(all_specs))

gen-spec: $(patsubst %, specs/%.k, $(all_specs))
gen-gas:  $(patsubst %, specs/%.gas, $(pass_rough_specs))

dapp-clean:
	cd $(DAPP_DIR) && dapp clean && cd ../

$(SPEC_MANIFEST): $(SRCS) $(DAPP_SRCS) $(SPECS_SRCS)
	$(KLAB_FLAGS) klab build

$(SPECS_DIR)/%.k: src/%.k
	cp $< $@

spec: $(SPEC_MANIFEST)

spec-clean:
	rm -f $(SPECS_DIR)/* $(ACTS_DIR)/* $(SPEC_MANIFEST)

$(DOC_DIR)/dss.html: $(SRCS)
	$(info Generating html documentation: $@)
	mkdir -p $(DOC_DIR)
	$(KLAB_FLAGS) klab report > $@

doc: $(DOC_DIR)/dss.html

doc-clean:
	rm -rf $(DOC_DIR)/*

log-clean:
	rm -rf $(TMPDIR)/klab

clean: dapp-clean spec-clean doc-clean
