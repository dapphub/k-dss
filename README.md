# k-dss

```sh
git submodule update --init --recursive
cd dss && dapp build && cd ../
./abi2specs specs/frob.json
klab run --spec out/success_frob_bytes32_int256_int256.ini
```
