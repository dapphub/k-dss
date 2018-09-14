# k-dss

### dependencies
* `nodejs` V8 or higher

### build
```sh
git clone git@github.com:dapphub/k-dss.git
make
```

### usage
to run a proof with [klab](https://github.com/dapphub/klab):
```sh
klab run --spec out/Vat_dai_succ.ini
```

or any other spec in the `out` dir. You will need a bleeding edge `klab` and `evm-semantics`.

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
| toll      | ?    | ?    | ?    | ?    |
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
| live      | ?    | -    | ?    | -    |
| Line      | ?    | -    | ?    | -    |
| vat       | ?    | -    | ?    | -    |
| ilks      | ?    | -    | ?    | -    |
| file-drip | ?    | ?    | ?    | ?    |
| file-ilk  | ?    | ?    | ?    | ?    |
| file-Line | ?    | ?    | ?    | ?    |
| frob      | ?    | ?    |      |      |
| Vow       +------+------+------+------|
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
| Joy       | o    | o    |      |      |
| file-risk | o    | ?    | ?    |      |
| file-addr | o    | ?    | ?    |      |
| heal      | o    | o    |      |      |
| kiss      | o    | o    |      |      |
| fess      | x    | x    |      |      |
| flog      | x    | x    |      |      |
| flop      |      |      |      |      |
| flap      |      |      |      |      |
| Cat       +------+------+------+------|
| vat       | ?    | -    | ?    | -    |
| pit       | ?    | -    | ?    | -    |
| vow       | ?    | -    | ?    | -    |
| ilks      | ?    | -    | ?    | -    |
| nflip     | ?    | -    | ?    | -    |
| flips     | ?    | -    | ?    | -    |
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

