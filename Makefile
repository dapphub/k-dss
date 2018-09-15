SRC_DIR = dss
OUT_DIR = out
TMPDIR = $(CURDIR)/tmp

SMT_PRELUDE = $(OUT_DIR)/prelude.smt2

KPROVE = $(KLAB_EVMS_PATH)/.build/k/k-distribution/target/release/k/bin/kprove
KPROVE_ARGS = --directory $(KLAB_EVMS_PATH)/.build/java/ --z3-executable --def-module RULES --output-tokenize "\#And _==K_ <k> \#unsigned" --output-omit "<programBytes> <program> <code>" --output-flatten "_Map_ \#And" --output json --smt_prelude $(SMT_PRELUDE) --z3-tactic "(or-else (using-params smt :random-seed 3 :timeout 1000) (using-params smt :random-seed 2 :timeout 2000) (using-params smt :random-seed 1))"

specs_dir = out/specs
specs = $(wildcard $(specs_dir)/*)

vat_specs     = $(wildcard $(specs_dir)/proof-Vat*)
drip_specs    = $(wildcard $(specs_dir)/proof-Drip*)
pit_specs     = $(wildcard $(specs_dir)/proof-Pit*)
vow_specs     = $(wildcard $(specs_dir)/proof-Vow*)
cat_specs     = $(wildcard $(specs_dir)/proof-Cat*)
gemjoin_specs = $(wildcard $(specs_dir)/proof-GemJoin*)
ethjoin_specs = $(wildcard $(specs_dir)/proof-ETHJoin*)
daijoin_specs = $(wildcard $(specs_dir)/proof-DaiJoin*)

all: dapp spec

dapp:
	git submodule update --init --recursive
	cd $(SRC_DIR) && dapp build && cd ../

dapp-clean:
	cd $(SRC_DIR) && dapp clean && cd ../

spec: 
	klab build

clean: dapp-clean
	rm -f $(OUT_DIR)*

test: test-vat

test-vat:      $(vat_specs:=.test)
test-drip:     $(drip_specs:=.test)
test-pit:      $(pit_specs:=.test)
test-vow:      $(vow_specs:=.test)
test-cat:      $(cat_specs:=.test)
test-gemjoin:  $(gemjoin_specs:=.test)
test-ethjoin:  $(ethjoin_specs:=.test)
test-daijoin:  $(daijoin_specs:=.test)

check-env:
ifndef KLAB_EVMS_PATH
  $(error KLAB_EVMS_PATH is undefined)
endif

%.test: check-env
	$(KPROVE) $(KPROVE_ARGS) $*


