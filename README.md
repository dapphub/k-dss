K-DSS: K Specification of Multi-Collateral Dai
==============================================

This repo contains the formal specification and verification of [multicollateral dai](https://github.com/makerdao/dss).
The behavior of the contracts is specified in a literate format at [dss.md](src/dss.md), which generates a series of reachability claims defining `succeeding` and `reverting` behavior for each function of each contract.
These reachability claims are then tested against [KEVM](https://github.com/kframework/evm-semantics).

Installation
------------

### Dependencies

Install the system dependencies of [KEVM](https://github.com/kframework/evm-semantics) and of [KLab](https://github.com/makerdao/klab).

### Build

Clone and build KEVM and KLab in submodules:

```sh
git clone git@github.com:dapphub/k-dss.git
make dapp
make deps RELEASE=true
```

### Usage

You may use the `Makefile` to do several things (for a given proof `SPEC`):

-   `make out/built/SPEC`: Prove any dependencies of `SPEC` and then construct the specification for `SPEC`.
-   `make out/accept/SPEC`: Additionally prove the specification `SPEC` itself.
-   `make out/gas/SPEC.raw`: Additionally extract a pretty-formatted string with the `<gas>` expression for `SPEC`.
-   `make prove -jN`: Prove all specifications in `src/dss.md`, running `N` at a time.
-   `make SPEC.klab-view`: Open the proof of `SPEC` in the [KLab debugger](https://github.com/makerdao/klab).

### Documentation

To build the literate specification in HTML, run `make doc`.
The output of this process is available at `out/doc`.

### ACT Specification Format

The format used in [dss.md](src/dss.md) provides a concise way of specifying the behavior of a contract method.
See [act-mode](https://github.com/livnev/act-mode) for a simple emacs major mode for `.act` specs.

Let's break down the specification of the behavior of the function `heal` in the contract `Vat`:

```act
behaviour heal of Vat
interface heal(bytes32 u, bytes32 v, int256 rad)

types

    Can   : uint256
    Dai_v : uint256
    Sin_u : uint256
    Debt  : uint256
    Vice  : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.dai(v)           |-> Dai_v => Dai_v - rad
    #Vat.sin(u)           |-> Sin_u => Sin_u - rad
    #Vat.debt             |-> Debt  => Debt - rad
    #Vat.vice             |-> Vice  => Vice - rad

iff

    Can == 1

iff in range uint256

    Dai_v - rad
    Sin_u - rad
    Debt - rad
    Vice - rad
```

This snippet of code will generate two reachability claims, `Vat_heal_succ_pass_rough.k` and `Vat_heal_fail_rough.k`.
Both of these claims will refer to the bytecode of the contract `Vat` and use the function signature of `heal(bytes32,bytes32,int256)` as the first 4 bytes of calldata (keeping the rest of the calldata abstract).
In the `success` spec, the conditions under the `iff` headers are postulated, while in the `fail` spec their negation is.

The interesting part of this particular function happens under the `storage` header.
The meaning of the line `#Vat.dai(v) |-> Dai_v => Dai_v - rad` is that in the `success` case, the value at the storage location which we call `#Vat.dai(v)` will be updated from `Dai_v` to `Dai_v - rad`.

To prove this reachability claim, the K prover explores all possible execution paths starting from the precondition (whats on the left hand side of a `=>`) and the claim is proven if they all end in a state satisfying the postcondition (right hand side of the `=>`).

More information about how the K prover and the K Framework in general works can be found at [Semantics-Based Program Verifiers for All Languages](http://fsl.cs.illinois.edu/FSL/papers/2016/stefanescu-park-yuwen-li-rosu-2016-oopsla/stefanescu-park-yuwen-li-rosu-2016-oopsla-public.pdf).
A detailed description of the semantics of EVM defined in K is given in [KEVM: A Complete Semantics of the Ethereum Virtual Machine](https://www.ideals.illinois.edu/handle/2142/97207).

License
-------

All applicable work in this repository is licensed under AGPL-3.0. Authors:

* Lev Livnev
* Denis Erfurt
* Martin Lundfall
* Everett Hildenbrandt
