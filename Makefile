KLAB_OUT = out
export KLAB_OUT

DEPS_DIR  := deps
BUILD_DIR := .build

INSTALL_PREFIX  := /usr
INSTALL_BIN     ?= $(INSTALL_PREFIX)/bin
INSTALL_LIB     ?= $(INSTALL_PREFIX)/lib/kdss
INSTALL_INCLUDE ?= $(INSTALL_LIB)/include

KDSS_BIN     := $(BUILD_DIR)$(INSTALL_BIN)
KDSS_LIB     := $(BUILD_DIR)$(INSTALL_LIB)
KDSS_INCLUDE := $(KDSS_LIB)/include
KDSS_K_BIN   := $(KDSS_LIB)/kframework/bin
KDSS         := kdss
KDSS_PROVE   := $(KDSS) prove

KDSS_VERSION     ?= 1.0.1
KDSS_RELEASE_TAG ?= v$(KDSS_VERSION)-$(shell git rev-parse --short HEAD)

KEVM_SUBMODULE      := $(DEPS_DIR)/evm-semantics
KEVM_INSTALL_PREFIX := $(INSTALL_LIB)/kevm
KEVM_BIN            := $(KEVM_INSTALL_PREFIX)/bin
KEVM_MAKE           := $(MAKE) --directory $(KEVM_SUBMODULE) INSTALL_PREFIX=$(KEVM_INSTALL_PREFIX)
KEVM                := kevm

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
	$(KEVM_MAKE) -j4 build-haskell
	$(KEVM_MAKE) -j4 install       DESTDIR=$(CURDIR)/$(BUILD_DIR)

include.mak: src/dss.md
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
