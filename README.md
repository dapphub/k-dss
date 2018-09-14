# k-dss

This repo contains the formal verification efforts of the [MakerDAO CDP engine featuring multiple collateral types](https://github.com/makerdao/dss). 

The behavior of these contracts is specified in a literate format at [specification.md](specification.md), which generates a series of reachability claims, defining `succeeding` and `reverting` behavior for each function of each contract. These reachability claims are then tested against the [formal semantics of the EVM](https://github.com/kframework/evm-semantics) using the [klab](https://github.com/dapphub/klab) tool for debugging.

More information about the specification format can be found under [Specification format](###Specification-format)

### dependencies
* `nodejs` V8 or higher
* klab. Installation can be found at [klab](https://github.com/dapphub/klab).


### build
```sh
git clone git@github.com:dapphub/k-dss.git
make
```

### usage
to run a proof with [klab](https://github.com/dapphub/klab), try e.g.
```sh
klab run --spec out/Vat_dai_succ.ini
```

or any other spec in the `out` dir. You will need to be up to date with the `master` branch of `klab`.

# Progress

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
| rely      | x    | x    | ?    | x    |
| deny      | x    | x    | ?    | ?    |
| init      | x    | x    | x    | ?    |
| slip      | x    | x    | ?    | ?    |
| flux      | x    | x    | ?    | ?    |
| move      | x    | x    | x    | x    |
| tune      | x    | x    | x    | ?    |
| grab      | x    | x    | x    | ?    |
| heal      | x    | x    | x    | ?    |
| fold      | x    | x    | ?    | ?    |
| toll      | x    | x    | ?    | ?    |
| Drip      +------+------+------+------|
| wards     | ?    | -    | ?    | -    |
| ilks      | ?    | -    | ?    | -    |
| vat       | ?    | -    | ?    | -    |
| repo      | ?    | -    | ?    | -    |
| era       | ?    | -    | ?    | -    |
| rely      | ?    | ?    | ?    | ?    |
| deny      | ?    | ?    | ?    | ?    |
| init      | ?    | ?    | ?    | ?    |
| file      | ?    | ?    | ?    | ?    |
| file-repo | ?    | -    | ?    | -    |
| file-vow  | ?    | -    | ?    | -    |
| drip      | ?    | ?    | ?    | ?    |
| Pit       +------+------+------+------|
| wards     | ?    | -    | ?    | -    |
| ilks      | ?    | -    | ?    | -    |
| live      | ?    | -    | ?    | -    |
| Line      | ?    | -    | ?    | -    |
| vat       | ?    | -    | ?    | -    |
| drip      | ?    | -    | ?    | -    |
| rely      | ?    | ?    | ?    | ?    |
| deny      | ?    | ?    | ?    | ?    |
| file-drip | ?    | ?    | ?    | ?    |
| file-ilk  | ?    | ?    | ?    | ?    |
| file-Line | ?    | ?    | ?    | ?    |
| frob      | ?    | ?    |      |      |
| Vow       +------+------+------+------|
| wards     | ?    | -    | ?    | -    |
| sin       | x    | -    | ?    | -    |
| Sin       | x    | -    | ?    | -    |
| Woe       | x    | -    | ?    | -    |
| Ash       | x    | -    | ?    | -    |
| wait      | x    | -    |      | -    |
| sump      | ?    | -    | ?    | -    |
| bump      | ?    | -    | ?    | -    |
| hump      | x    | -    | ?    | -    |
| era       | x    | -    |      | -    |
| Awe       | x    | x    | ?    |      |
| Joy       | x    | o    |      |      |
| rely      | ?    | ?    | ?    | ?    |
| deny      | ?    | ?    | ?    | ?    |
| file-risk | o    | ?    | ?    |      |
| file-addr | o    | ?    | ?    |      |
| heal      | o    | o    |      |      |
| kiss      | o    | o    |      |      |
| fess      | x    | x    |      |      |
| flog      | x    | x    |      |      |
| flop      |      |      |      |      |
| flap      |      |      |      |      |
| Cat       +------+------+------+------|
| wards     | ?    | -    | ?    | -    |
| ilks      | ?    | -    | ?    | -    |
| flips     | ?    | -    | ?    | -    |
| nflip     | ?    | -    | ?    | -    |
| live      | ?    | -    | ?    | -    |
| vat       | ?    | -    | ?    | -    |
| pit       | ?    | -    | ?    | -    |
| vow       | ?    | -    | ?    | -    |
| rely      | ?    | ?    | ?    | ?    |
| deny      | ?    | ?    | ?    | ?    |
| file-addr | ?    | ?    | ?    |      |
| file      | ?    | ?    | ?    |      |
| file-flip | ?    | ?    | ?    |      |
| bite      |      |      |      |      |
| flip      |      |      |      |      |
| GemJoin   +------+------+------+------|
| vat       | ?    | -    | ?    | -    |
| ilk       | ?    | -    | ?    | -    |
| gem       | ?    | -    | ?    | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
| ETHJoin   +------+------+------+------|
| vat       | ?    | -    | ?    | -    |
| ilk       | ?    | -    | ?    | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
| DaiJoin   +------+------+------+------|
| vat       | ?    | -    | ?    | -    |
| dai       | ?    | -    | ?    | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
-----------------------------------------
```

### Specification format
The format used in [specification.md](specification.md) provides a concise way of specifying the behavior of a contract function.

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
This snippet of code will generate two reachability claims, `Vat_heal_succ.ini` and `Vat_heal_fail.ini`. Both of these claims will refer to the bytecode of the contract `Vat` and use the function signature `heal(bytes32 u, bytes32 v, int256 rad)` as calldata (keeping the arguments abstract). In the `success` spec, the conditions under both `iff` headers are all assumed to be true and in the `fail` spec their negation is assumed.

The interesting part of this particular function happens under the `storage` header. The meaning of the line:
`#Vat.dai(v)           |-> Dai_v => Dai_v - rad`
is that in the `success` case, the value at the storage location which we call `#Vat.dai(v)` will be updated from `Dai_v` to `Dai_v - rad`.

To prove this reachability claim, the k prover explores all possible execution paths starting from the precondition (whats on the left hand side of a `=>`) and the claim is proven if they all end in a state satisfying the postcondition (right hand side of the `=>`). 

More information about how the k prover and the k framework in general works can be found at <http://fsl.cs.illinois.edu/FSL/papers/2016/stefanescu-park-yuwen-li-rosu-2016-oopsla/stefanescu-park-yuwen-li-rosu-2016-oopsla-public.pdf> and a detailed description of the semantics of EVM defined in K is given in <https://www.ideals.illinois.edu/handle/2142/97207>

