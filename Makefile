build:
	git submodule update --init --recursive
	cd dss && dapp build && cd ../
	./abi2specs specs/frob.json
