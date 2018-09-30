# k-dss

This repo contains the formal verification of [multicollateral dai](https://github.com/makerdao/dss).

The behavior of the contracts is specified in a literate format at [dss.md](src/dss.md), which generates a series of reachability claims, defining `succeeding` and `reverting` behavior for each function of each contract. These reachability claims are then tested against the [formal semantics of the EVM](https://github.com/kframework/evm-semantics) using the [klab](https://github.com/dapphub/klab) tool for interactive proof inspection and debugging.

More information about the specification format can be found under [Specification format](###Specification-format)

### dependencies
* klab. Installation instructions can be found at [klab](https://github.com/dapphub/klab).

### build
```sh
git clone git@github.com:dapphub/k-dss.git
make
```

This will download and build the target contracts in `dss/`, and compile the literate specifications in `src/` to K specifications, saving the results in `out/specs`.

### usage

To run a proof with [klab](https://github.com/dapphub/klab), you'll need to have a `klab server` running. Then try:
```sh
klab run --spec out/specs/proof-Vat_dai_succ.k
```

This will open an interactive `klab` session exploring the success behaviour of the `dai()` method of the contract `Vat`.

It's also possible to check the behaviours non-interactively, directly using `kprove`, which is much faster. To check all behaviours of the `Vat` contract, executing 4 jobs in parallel:
```sh
make proofs-Vat -j4
```

Specific behaviours can also be checked in this way, for example:
```sh
make out/specs/proof-Vat_dai_succ.k.proof
```

# progress

(proof CI running at [dapp.ci](https://dapp.ci) )

`x` - the proof is succeeding

`?` - expected to succeed but yet to be checked

`o` - in development (ask before attacking)

`-` - no fail behaviour

```
-----------------------------------------
| behaviour |   .2.sol    |    .sol     |
|-----------| succ | fail | succ | fail |
| Vat       +------+------+------+------|
| wards     | x    | -    | x    | -    |
| ilks      | x    | -    | x    | -    |
| urns      | x    | -    | x    | -    |
| gem       | x    | -    | x    | -    |
| dai       | x    | -    | x    | -    |
| sin       | x    | -    | x    | -    |
| debt      | x    | -    | x    | -    |
| vice      | x    | -    | x    | -    |
| rely      | x    | x    | x    | x    |
| deny      | x    | x    | x    | x    |
| init      | x    | x    | x    | x    |
| slip      | x    | x    | x    | x    |
| flux      | x    | x    | x    | x    |
| move      | x    | x    | x    | x    |
| tune      | x    | x    | x    | x    |
| grab      | x    | x    | x    | x    |
| heal      | x    | x    | x    | x    |
| fold      | x    | x    | x    | x    |
| toll      | x    | x    | x    | x    |
| Drip      +------+------+------+------|
| wards     | x    | -    |      | -    |
| ilks      | x    | -    |      | -    |
| vat       | x    | -    |      | -    |
| vow       | x    | -    |      | -    |
| repo      | x    | -    |      | -    |
| era       | x    | -    |      | -    |
| rely      | x    | x    |      |      |
| deny      | x    | x    |      |      |
| init      | x    | x    |      |      |
| file      | x    | x    |      |      |
| file-repo | x    | x    |      | -    |
| file-vow  | x    | x    |      | -    |
| drip      |      |      |      |      |
| Pit       +------+------+------+------|
| wards     | x    | -    |      | -    |
| ilks      | x    | -    |      | -    |
| live      | x    | -    |      | -    |
| Line      | x    | -    |      | -    |
| vat       | x    | -    |      | -    |
| drip      | x    | -    |      | -    |
| rely      | x    | x    |      |      |
| deny      | x    | x    |      |      |
| file-drip | x    | x    |      |      |
| file-ilk  | x    | x    |      |      |
| file-Line | x    | x    |      |      |
| frob      |      |      |      |      |
| Vow       +------+------+------+------|
| wards     | x    | -    |      | -    |
| sin       | x    | -    |      | -    |
| Sin       | x    | -    |      | -    |
| Woe       | x    | -    |      | -    |
| Ash       | x    | -    |      | -    |
| wait      | x    | -    |      | -    |
| sump      | x    | -    |      | -    |
| bump      | x    | -    |      | -    |
| hump      | x    | -    |      | -    |
| era       | x    | -    |      | -    |
| Awe       | x    | x    |      |      |
| Joy       | x    | -    |      |      |
| rely      | x    | x    |      |      |
| deny      | x    | x    |      |      |
| file-data | x    | x    |      |      |
| file-addr | x    | x    |      |      |
| heal      | x    | x    |      |      |
| kiss      | x    | o    |      |      |
| fess      | x    | x    |      |      |
| flog      | x    | x    |      |      |
| flop      | o    | o    |      |      |
| flap      | o    | o    |      |      |
| Cat       +------+------+------+------|
| wards     | x    | -    |      | -    |
| ilks      | x    | -    |      | -    |
| flips     | x    | -    |      | -    |
| nflip     | x    | -    |      | -    |
| live      | x    | -    |      | -    |
| vat       | x    | -    |      | -    |
| pit       | x    | -    |      | -    |
| vow       | x    | -    |      | -    |
| rely      | x    | x    |      |      |
| deny      | x    | x    |      |      |
| file-addr | x    | x    |      |      |
| file      | x    | x    |      |      |
| file-flip | x    | x    |      |      |
| bite      |      |      |      |      |
| flip      |      |      |      |      |
| GemJoin   +------+------+------+------|
| vat       |      | -    |      | -    |
| ilk       |      | -    |      | -    |
| gem       |      | -    |      | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
| ETHJoin   +------+------+------+------|
| vat       |      | -    |      | -    |
| ilk       |      | -    |      | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
| DaiJoin   +------+------+------+------|
| vat       |      | -    |      | -    |
| dai       |      | -    |      | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
-----------------------------------------
```

### specification format
The format used in [dss.md](src/dss.md) provides a concise way of specifying the behavior of a contract method.

Let's break down the specification of the behavior of the function `heal` in the contract `Vat`:
```
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
This snippet of code will generate two reachability claims, `proof-Vat_heal_succ.k` and `proof-Vat_heal_fail.k`. Both of these claims will refer to the bytecode of the contract `Vat` and use the function signature of `heal(bytes32,bytes32,int256)` as the first 4 bytes of calldata (keeping the rest of the calldata abstract). In the `success` spec, the conditions under the `iff` headers are postulated, while in the `fail` spec their negation is.

The interesting part of this particular function happens under the `storage` header. The meaning of the line:
`#Vat.dai(v)           |-> Dai_v => Dai_v - rad`
is that in the `success` case, the value at the storage location which we call `#Vat.dai(v)` will be updated from `Dai_v` to `Dai_v - rad`.

To prove this reachability claim, the k prover explores all possible execution paths starting from the precondition (whats on the left hand side of a `=>`) and the claim is proven if they all end in a state satisfying the postcondition (right hand side of the `=>`).

More information about how the K prover and the K Framework in general works can be found at [Semantics-Based Program Verifiers for All Languages](http://fsl.cs.illinois.edu/FSL/papers/2016/stefanescu-park-yuwen-li-rosu-2016-oopsla/stefanescu-park-yuwen-li-rosu-2016-oopsla-public.pdf) and a detailed description of the semantics of EVM defined in K is given in [KEVM: A Complete Semantics of the Ethereum Virtual Machine](https://www.ideals.illinois.edu/handle/2142/97207).

### license
All applicable work in this repository is licensed under AGPL-3.0. Authors:
* Lev Livnev
* Denis Erfurt
* Martin Lundfall
