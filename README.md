# k-dss

```sh
git submodule update --init --recursive
cd dss && dapp build && cd ../
./abi2specs specs/frob.json
klab run --spec out/frob_success_file_bytes32_bytes32_int256.ini
```
