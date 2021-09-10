KLAB_OUT = out
export KLAB_OUT

DEPS_DIR  := deps
BUILD_DIR := .build

INSTALL_PREFIX  := /usr
INSTALL_BIN     ?= $(INSTALL_PREFIX)/bin
INSTALL_LIB     ?= $(INSTALL_PREFIX)/lib/kdss
INSTALL_INCLUDE ?= $(INSTALL_LIB)/include
KDSS_BIN        := $(BUILD_DIR)$(INSTALL_BIN)

KEVM_SUBMODULE      := $(DEPS_DIR)/evm-semantics
KEVM_INSTALL_PREFIX := $(INSTALL_LIB)/kevm
KEVM_BIN            := $(KEVM_INSTALL_PREFIX)/bin
KEVM_MAKE           := $(MAKE) --directory $(KEVM_SUBMODULE) INSTALL_PREFIX=$(KEVM_INSTALL_PREFIX)
KEVM                := kevm

PYTHONPATH := $(CURDIR)/$(BUILD_DIR)/$(INSTALL_LIB)/kevm/lib/kevm/kframework/lib/kframework:$(INSTALL_LIB)/kevm/lib/kevm/kframework/lib/kframework
export PYTHONPATH

KLAB_EVMS_PATH ?= $(CURDIR)/$(KEVM_SUBMODULE)
export KLAB_EVMS_PATH

K_BACKEND := java

PATH := $(CURDIR)/$(KDSS_BIN):$(CURDIR)/$(BUILD_DIR)$(KEVM_BIN):$(PATH)
PATH := $(CURDIR)/deps/klab/bin:$(PATH)
export PATH

kevm-clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(BUILD_DIR)
	$(KEVM_MAKE) distclean

kevm:
	$(KEVM_MAKE) -j4 deps
	$(KEVM_MAKE) -j4 build-$(K_BACKEND)
	$(KEVM_MAKE) -j4 install            DESTDIR=$(CURDIR)/$(BUILD_DIR)

include.mak: src/dss.md
	klab make > include.mak

include include.mak

DAPP_DIR = $(CURDIR)/dss

.PHONY: all deps dapp kevm klab gen-spec gen-gas clean

all: deps spec

deps: dapp kevm klab

dapp:
	cd $(DAPP_DIR) && make build

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

clean: dapp-clean out-clean kevm-clean

out-clean:
	rm -rf $(KLAB_OUT)
