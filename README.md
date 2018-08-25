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

`x` means the proof is succeeding

`o` means in development (ask before attacking)

`-` means not applicable

```
-----------------------------------------
| behaviour |   .2.sol    |    .sol     |
|-----------| succ | fail | succ | fail |
| Vat       +------+------+------+------|
| wards     | x    | -    |      | -    |
| ilks      | x    | -    |      | -    |
| urns      | x    | -    |      | -    |
| gem       | x    | -    |      | -    |
| dai       | x    | -    |      | -    |
| sin       | x    | -    |      | -    |
| debt      | x    | -    |      | -    |
| vice      | x    | -    |      | -    |
| rely      | x    | x    |      |      |
| deny      | x    | x    |      |      |
| init      | x    | x    |      |      |
| move      | x    | x    |      |      |
| slip      | x    | x    |      |      |
| flux      | x    | x    |      |      |
| tune      | x    | x    |      |      |
| grab      | x    | x    |      |      |
| fold      | x    | x    |      |      |
| Pit       +------+------+------+------|
| live      |      | -    |      | -    |
| Line      |      | -    |      | -    |
| vat       |      | -    |      | -    |
| ilks      |      | -    |      | -    |
| file      |      |      |      |      |
| file      |      |      |      |      |
| frob      |      |      |      |      |
| Vow       +------+------+------+------|
| sin       | x    | -    |      | -    |
| Sin       | x    | -    |      | -    |
| Woe       | x    | -    |      | -    |
| Ash       | x    | -    |      | -    |
| wait      | x    | -    |      | -    |
| lump      | x    | -    |      | -    |
| pad       | x    | -    |      | -    |
| era       | x    | -    |      | -    |
| Awe       | x    | x    |      |      |
| Joy       | o    | o    |      |      |
| file-risk | o    |      |      |      |
| file-addr | o    |      |      |      |
| heal      | o    | o    |      |      |
| kiss      | o    | o    |      |      |
| fess      | x    | x    |      |      |
| flog      | x    | x    |      |      |
| flop      |      |      |      |      |
| flap      |      |      |      |      |
| Cat       +------+------+------+------|
| vat       |      | -    |      | -    |
| pit       |      | -    |      | -    |
| vow       |      | -    |      | -    |
| lump      |      | -    |      | -    |
| ilks      |      | -    |      | -    |
| nflip     |      | -    |      | -    |
| flips     |      | -    |      | -    |
| file      |      |      |      |      |
| file      |      |      |      |      |
| bite      |      |      |      |      |
| flip      |      |      |      |      |
| Adapter   +------+------+------+------|
| vat       |      | -    |      | -    |
| ilk       |      | -    |      | -    |
| gem       |      | -    |      | -    |
| join      |      |      |      |      |
| exit      |      |      |      |      |
-----------------------------------------
```

