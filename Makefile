SRC_DIR = dss
OUT_DIR = out
TMPDIR = $(CURDIR)/tmp

ifndef KLAB_EVMS_PATH
	$(error $(red)Error$(reset): KLAB_EVMS_PATH must be defined and point to evm-semantics!)
endif

SMT_PRELUDE = $(OUT_DIR)/prelude.smt2

KPROVE = K_OPTS=-Xmx10G $(KLAB_EVMS_PATH)/.build/k/k-distribution/target/release/k/bin/kprove
KPROVE_ARGS = --directory $(KLAB_EVMS_PATH)/.build/java/ --z3-executable --def-module RULES --output-tokenize "\#And _==K_ <k> \#unsigned" --output-omit "<programBytes> <program> <code>" --output-flatten "_Map_ \#And" --output json --smt_prelude $(SMT_PRELUDE) --z3-tactic "(or-else (using-params smt :random-seed 3 :timeout 1000) (using-params smt :random-seed 2 :timeout 2000) (using-params smt :random-seed 1))"

DEBUG_ARGS = --debugg --debugg-path $(TMPDIR)/klab --debugg-id

# shell output colouring:
red:=$(shell tput setaf 1)
green:=$(shell tput setaf 2)
yellow:=$(shell tput setaf 3)
bold:=$(shell tput bold)
reset:=$(shell tput sgr0)

specs_dir = out/specs
specs = $(wildcard $(specs_dir)/*)

all: dapp spec

dapp:
	git submodule update --init --recursive
	cd $(SRC_DIR) && dapp build && cd ../

dapp-clean:
	cd $(SRC_DIR) && dapp clean && cd ../

$(OUT_DIR)/spec.timestamp:
	mkdir -p $(OUT_DIR) && touch $@
	klab build

spec: $(OUT_DIR)/spec.timestamp

spec-clean:
	rm -rf $(OUT_DIR)/*

clean: dapp-clean spec-clean

proofs: proofs-Vat

# workaround for patsubst in pattern matching target below
PERCENT := %

.SECONDEXPANSION:

proofs-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof,$$(wildcard $(specs_dir)/proof-%*.k))
	$(info $(bold)CHECKED$(reset) all behaviours of contract $*.)

debug-proofs-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof.debug,$$(wildcard $(specs_dir)/proof-%*.k))
	$(info $(bold)CHECKED$(reset) all behaviours of contract $*.)

%.k.proof: %.k
	$(info Proof $(bold)STARTING$(reset): $<)
	@ $(KPROVE) $(KPROVE_ARGS) $< && echo "$(green)Proof $(bold)SUCCESS$(reset): $<"

%.k.proof.debug: %.k
	$(info Proof $(bold)STARTING$(reset): $< (in $(yellow)$(bold)debug mode$(reset)))
	@ $(KPROVE) $(DEBUG_ARGS) `klab hash --spec $<` $(KPROVE_ARGS) $< && echo "$(green)Proof $(bold)SUCCESS$(reset): $<"




