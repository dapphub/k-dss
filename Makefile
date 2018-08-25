SRC_DIR = dss/
OUT_DIR = out/
TMPDIR = $(CURDIR)/tmp

export PATH
export TMPDIR

test_dir = out
tests = $(wildcard $(test_dir)/*)

passing_tests =	out/Vat_wards_succ.ini \
		out/Vat_ilks_succ.ini \
		out/Vat_urns_succ.ini \
		out/Vat_gem_succ.ini  \
		out/Vat_dai_succ.ini  \
		out/Vat_sin_succ.ini  \
		out/Vat_debt_succ.ini \
		out/Vat_vice_succ.ini \
		out/Vat_rely_succ.ini \
		out/Vat_rely_fail.ini \
		out/Vat_deny_succ.ini \
		out/Vat_deny_fail.ini \
		out/Vat_init_succ.ini \
		out/Vat_init_fail.ini \
		out/Vat_move_succ.ini \
		out/Vat_move_fail.ini \
		out/Vat_slip_succ.ini \
		out/Vat_slip_fail.ini \
		out/Vat_flux_succ.ini \
		out/Vat_flux_fail.ini \
		out/Vat_tune_succ.ini \
		out/Vat_tune_fail.ini \
		out/Vat_grab_succ.ini \
		out/Vat_grab_fail.ini \
		out/Vat_heal_succ.ini \
		out/Vat_heal_fail.ini \
		out/Vat_fold_succ.ini \
		out/Vat_fold_fail.ini

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
	rm -f $(OUT_DIR)*
