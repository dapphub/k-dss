# shell output colouring:
red:=$(shell tput setaf 1)
green:=$(shell tput setaf 2)
yellow:=$(shell tput setaf 3)
bold:=$(shell tput bold)
reset:=$(shell tput sgr0)

DAPP_DIR = $(CURDIR)/dss
SRC_DIR = $(CURDIR)/src
SRCS = $(addprefix $(SRC_DIR)/, dss.md lemmas.k.md storage.k.md prelude.smt2.md)
DAPP_SRCS = $(wildcard $(DAPP_DIR)/src/*)
ifdef KLAB_OUT
OUT_DIR = $(KLAB_OUT)
else
OUT_DIR = $(CURDIR)/out
endif
ifndef TMPDIR
TMPDIR = $(CURDIR)/tmp
endif
ifndef KLAB_EVMS_PATH
$(error $(red)Error$(reset): KLAB_EVMS_PATH must be defined and point to evm-semantics!)
endif
SPECS_DIR = $(OUT_DIR)/specs
ACTS_DIR = $(OUT_DIR)/acts
DOC_DIR = $(OUT_DIR)/doc

KLAB_FLAGS = KLAB_OUT=$(OUT_DIR)

SMT_PRELUDE = $(OUT_DIR)/prelude.smt2
RULES = $(OUT_DIR)/rules.k

KPROVE = K_OPTS=-Xmx10G $(KLAB_EVMS_PATH)/.build/k/k-distribution/target/release/k/bin/kprove
KPROVE_ARGS = --directory $(KLAB_EVMS_PATH)/.build/java/ --z3-executable --def-module RULES --output-tokenize "\#And _==K_ <k> \#unsigned" --output-omit "<programBytes> <program> <code>" --output-flatten "_Map_ \#And" --output json --smt_prelude $(SMT_PRELUDE) --z3-tactic "(or-else (using-params smt :random-seed 3 :timeout 1000) (using-params smt :random-seed 2 :timeout 2000) (using-params smt :random-seed 1))"

DEBUG_ARGS = --debugg --debugg-path $(TMPDIR)/klab --debugg-id

all: dapp spec

dapp:
	git submodule update --init --recursive
	cd $(DAPP_DIR) && dapp build && cd ../

dapp-clean:
	cd $(DAPP_DIR) && dapp clean && cd ../

$(SPECS_DIR)/spec.timestamp: $(SRCS) $(DAPP_SRCS)
	mkdir -p $(SPECS_DIR) && touch $@
	$(KLAB_FLAGS) klab build

spec: $(SPECS_DIR)/spec.timestamp

spec-clean:
	rm -f $(SPECS_DIR)/* $(ACTS_DIR)/*

$(DOC_DIR)/dss.html: $(SRCS)
	$(info Generating html documentation: $@)
	mkdir -p $(DOC_DIR)
	$(KLAB_FLAGS) klab report > $@

doc: $(DOC_DIR)/dss.html

doc-publish: $(DOC_DIR)/dss.html
	scp $< root@stablecoin.technology:/var/www/html/index.html

doc-clean:
	rm -rf $(DOC_DIR)/*

clean: dapp-clean spec-clean doc-clean

proofs: proofs-Vat

publish: publish-Vat

# workaround for patsubst in pattern matching target below
PERCENT := %

.SECONDEXPANSION:

proofs-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof.timestamp,$$(wildcard $(SPECS_DIR)/proof-%*.k))
	$(info $(bold)CHECKED$(reset) all behaviours of contract $*.)

debug-proofs-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof.debug.timestamp,$$(wildcard $(SPECS_DIR)/proof-%*.k))
	$(info $(bold)CHECKED$(reset) all behaviours of contract $* (in $(yellow)$(bold)debug mode$(reset)).)

logs-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof.debug.log.timestamp,$$(wildcard $(SPECS_DIR)/proof-%*.k))
	$(info $(bold)COMPILED$(reset) logs for all behaviours of contract $*.)

publish-%: $$(patsubst $$(PERCENT),$$(PERCENT).proof.debug.log.publish,$$(wildcard $(SPECS_DIR)/proof-%*.k))
	$(info $(bold)PUBLISHED$(reset) logs for all behaviours of contract $*.)

%.k.proof.timestamp: %.k $(SMT_PRELUDE) $(RULES)
	$(info Proof $(bold)STARTING$(reset): $<)
	@ $(KPROVE) $(KPROVE_ARGS) $< && echo "$(green)Proof $(bold)SUCCESS$(reset): $<" && touch $@

%.k.proof.debug.timestamp: %.k $(SMT_PRELUDE) $(RULES)
	$(info Proof $(bold)STARTING$(reset): $< (in $(yellow)$(bold)debug mode$(reset)))
	@ $(KPROVE) $(DEBUG_ARGS) `$(KLAB_FLAGS) klab hash --spec $<` $(KPROVE_ARGS) $< && echo "$(green)Proof $(bold)SUCCESS$(reset): $<" && touch $@

%.k.proof.debug.log.timestamp: %.k %.k.proof.debug.timestamp
	$(info $(bold)Compiling$(reset) proof logs for $<)
	klab compile --spec $< && touch $@

%.k.proof.debug.log.publish: %.k %.k.proof.debug.log.timestamp
	$(info $(bold)Publishing$(reset) proof logs for $<)
	test -n "$(KLAB_PUBLISH_ID)"  # $$KLAB_PUBLISH_ID must be set
	test -n "$(KLAB_PUBLISH_SECRET)"  # $$KLAB_PUBLISH_SECRET must be set
	$(KLAB_FLAGS) klab publish --spec $<

# needed to keep the dummy timestamp files from getting removed
.SECONDARY:
