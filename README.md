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

`-` means not applicable

`x` means the proof is succeeding

`o` means in development (ask before attacking)

|             | succ | fail |
|-------------|------|------|
| **Vat**     |      |      |
| `root`      | x    | -    |
| `dai`       | x    | -    |
| `sin`       | x    | -    |
| `ilks`      | x    | -    |
| `urns`      | x    | -    |
| `Tab`       | x    | -    |
| `vice`      | x    | -    |
| `file`      | x    | -    |
| `move-uint` | x    | o    |
| `move-int`  | x    | o    |
| `slip`      | x    | x    |
| `tune`      |      |      |
| `grab`      |      |      |
| `fold`      |      |      |
|             |      |      |
| **Pit**     |      |      |
| `live`      |      | -    |
| `Line`      |      | -    |
| `vat`       |      | -    |
| `ilks`      |      | -    |
| `file`      |      | -    |
| `file`      |      | -    |
| `frob`      |      |      |
|             |      |      |
| **Vow**     |      |      |
| `sin`       |      | -    |
| `Sin`       |      | -    |
| `Woe`       |      | -    |
| `Ash`       |      | -    |
| `wait`      |      | -    |
| `lump`      |      | -    |
| `pad`       |      | -    |
| `era`       |      | -    |
| `Awe`       |      | -    |
| `Joy`       |      |      |
| `file`      |      | -    |
| `fess`      |      |      |
| `flog`      |      |      |
| `heal`      |      |      |
| `kiss`      |      |      |
| `flop`      |      |      |
| `flap`      |      |      |
|             |      |      |
| **Cat**     |      |      |
| `vat`       |      | -    |
| `pit`       |      | -    |
| `vow`       |      | -    |
| `lump`      |      | -    |
| `ilks`      |      | -    |
| `nflip`     |      | -    |
| `flips`     |      | -    |
| `file`      |      | -    |
| `file`      |      | -    |
| `bite`      |      |      |
| `flip`      |      |      |
|             |      |      |
| **Adapter** |      |      |
| `vat`       |      | -    |
| `ilk`       |      | -    |
| `gem`       |      | -    |
| `join`      |      |      |
| `exit`      |      |      |


