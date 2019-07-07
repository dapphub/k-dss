What follows is an executable K specification of the smart contracts of multicollateral dai.

# Vat

The `Vat` stores the core dai, CDP, and collateral state, and tracks the system's accounting invariants. The `Vat` is where all dai is created and destroyed. The `Vat` provides `frob`: the core interface for interacting with CDPs.

## Specification of behaviours

### Accessors

#### owners

The contracts use a multi-owner only-owner authorisation scheme. In the case of the `Vat`, all mutating methods can only be called by owners.

```act
behaviour wards of Vat
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### allowances

```act
behaviour can of Vat
interface can(address src, address dst)

for all

    Can : uint256

storage

    can[src][dst] |-> Can

iff

    VCallValue == 0

returns Can
```

#### collateral type data

An `ilk` is a collateral type.

```act
behaviour ilks of Vat
interface ilks(bytes32 ilk)

for all

    Ilk_Art  : uint256
    Ilk_rate : uint256
    Ilk_spot : uint256
    Ilk_line : uint256
    Ilk_dust : uint256

storage

    ilks[ilk].Art  |-> Ilk_Art
    ilks[ilk].rate |-> Ilk_rate
    ilks[ilk].spot |-> Ilk_spot
    ilks[ilk].line |-> Ilk_line
    ilks[ilk].dust |-> Ilk_dust

iff

    VCallValue == 0

returns Ilk_Art : Ilk_rate : Ilk_spot : Ilk_line : Ilk_dust
```

#### `urn` data

An `urn` is a collateralised debt position.

```act
behaviour urns of Vat
interface urns(bytes32 ilk, address urn)

for all

    Ink_iu : uint256
    Art_iu : uint256

storage

    urns[ilk][urn].ink |-> Ink_iu
    urns[ilk][urn].art |-> Art_iu

iff

    VCallValue == 0

returns Ink_iu : Art_iu
```

#### internal unencumbered collateral balances

A `gem` is a token used as collateral in some `ilk`.

```act
behaviour gem of Vat
interface gem(bytes32 ilk, address usr)

for all

    Gem : uint256

storage

    gem[ilk][usr] |-> Gem

iff

    VCallValue == 0

returns Gem
```

#### internal dai balances

`dai` is a stablecoin.

```act
behaviour dai of Vat
interface dai(address usr)

for all

    Rad : uint256

storage

    dai[usr] |-> Rad

iff

    VCallValue == 0

returns Rad
```

#### internal sin balances

`sin`, or "system debt", is used to track debt which is no longer assigned to a particular CDP, and is carried by the system during the liquidation process.

```act
behaviour sin of Vat
interface sin(address usr)

for all

    Rad : uint256

storage

    sin[usr] |-> Rad

iff

    VCallValue == 0

returns Rad
```

#### total debt

```act
behaviour debt of Vat
interface debt()

for all

    Debt : uint256

storage

    debt |-> Debt

iff

    VCallValue == 0

returns Debt
```

#### total bad debt

```act
behaviour vice of Vat
interface vice()

for all

    Vice : uint256

storage

    vice |-> Vice

iff

    VCallValue == 0

returns Vice
```

#### debt ceiling

```act
behaviour Line of Vat
interface Line()

for all

    Line : uint256

storage

    Line |-> Line

iff

    VCallValue == 0

returns Line
```

#### system liveness flag

```act
behaviour live of Vat
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

### Lemmas

#### Arithmetic

```act
behaviour addui of Vat
interface add(uint256 x, int256 y) internal

stack

   #unsigned(y) : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

   x + y

if

   #sizeWordStack(WS) <= 1015
```

```act
behaviour subui of Vat
interface sub(uint256 x, int256 y) internal

stack

    #unsigned(y) : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    #sizeWordStack(WS) <= 1015
```

```act
behaviour mului of Vat
interface mul(uint256 x, int256 y) internal

stack

    #unsigned(y) : x : JMPTO : WS => JMPTO : #unsigned(x * y) : WS

iff in range int256

    x
    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```
```act
behaviour adduu of Vat
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour subuu of Vat
interface sub(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```


```act
behaviour muluu of Vat
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

### Mutators

#### Set global settlement

Freezes the price of all positions.


```act
behaviour cage of Vat
interface cage()

for all

    May   : uint256
    Lives : uint256

storage

    wards[CALLER_ID] |-> May
    live             |-> Lives => 0

iff

    VCallValue == 0
    May == 1
```



#### adding and removing owners

Any owner can add and remove owners.

```act
behaviour rely-diff of Vat
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Vat
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Vat
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Vat
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

```act
behaviour hope of Vat
interface hope(address usr)

storage

    can[CALLER_ID][usr] |-> _ => 1

iff

    VCallValue == 0
```

```act
behaviour nope of Vat
interface nope(address usr)

storage

    can[CALLER_ID][usr] |-> _ => 0

iff

    VCallValue == 0
```

#### initialising an `ilk`

An `ilk` starts with `Rate` set to (fixed-point) one.

```act
behaviour init of Vat
interface init(bytes32 ilk)

for all

    May  : uint256
    Rate : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].rate   |-> Rate => #Ray

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: `Rate` is `. ? : not` zero
    Rate == 0
    VCallValue == 0
```

#### setting the debt ceiling

```act
behaviour file of Vat
interface file(bytes32 what, uint256 data)

for all

    May  : uint256
    Line : uint256

storage

    wards[CALLER_ID] |-> May
    Line             |-> Line => (#if what == #string2Word("Line") #then data #else Line #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting `Ilk` data

```act
behaviour file-ilk of Vat
interface file(bytes32 ilk, bytes32 what, uint256 data)

for all

    May  : uint256
    Spot : uint256
    Line : uint256
    Dust : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].spot   |-> Spot => (#if what == #string2Word("spot") #then data #else Spot #fi)
    ilks[ilk].line   |-> Line => (#if what == #string2Word("line") #then data #else Line #fi)
    ilks[ilk].dust   |-> Dust => (#if what == #string2Word("dust") #then data #else Dust #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### assigning unencumbered collateral

Collateral coming from outside of the system must be assigned to a user before it can be locked in a CDP.

```act
behaviour slip of Vat
interface slip(bytes32 ilk, address usr, int256 wad)

for all

    May : uint256
    Gem : uint256

storage

    wards[CALLER_ID] |-> May
    gem[ilk][usr]    |-> Gem => Gem + wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

iff in range uint256

    Gem + wad

calls

    Vat.addui
```

#### moving unencumbered collateral

```act
behaviour flux-diff of Vat
interface flux(bytes32 ilk, address src, address dst, uint256 wad)

for all

    May     : uint256
    Gem_src : uint256
    Gem_dst : uint256

storage

    can[src][CALLER_ID] |-> May
    gem[ilk][src]       |-> Gem_src => Gem_src - wad
    gem[ilk][dst]       |-> Gem_dst => Gem_dst + wad

iff

    // act: caller is `. ? : not` authorised
    (May == 1 or src == CALLER_ID)
    VCallValue == 0

iff in range uint256

    Gem_src - wad
    Gem_dst + wad

if

    src =/= dst

calls

    Vat.subuu
    Vat.adduu
```

```act
behaviour flux-same of Vat
interface flux(bytes32 ilk, address src, address dst, uint256 wad)

for all

    May     : uint256
    Gem_src : uint256

storage

    can[src][CALLER_ID] |-> May
    gem[ilk][src]       |-> Gem_src => Gem_src

iff

    // act: caller is `. ? : not` authorised
    (May == 1 or src == CALLER_ID)
    VCallValue == 0

iff in range uint256

    Gem_src - wad

if

    src == dst

calls

    Vat.subuu
    Vat.adduu
```

#### transferring dai balances

```act
behaviour move-diff of Vat
interface move(address src, address dst, uint256 rad)

for all

    Dai_dst : uint256
    Dai_src : uint256
    May     : uint256

storage

    can[src][CALLER_ID] |-> May
    dai[src]            |-> Dai_src => Dai_src - rad
    dai[dst]            |-> Dai_dst => Dai_dst + rad

iff

    // act: caller is `. ? : not` authorised
    (May == 1 or src == CALLER_ID)
    VCallValue == 0

iff in range uint256

    Dai_src - rad
    Dai_dst + rad

if

    src =/= dst

calls

  Vat.adduu
  Vat.subuu
```

```act
behaviour move-same of Vat
interface move(address src, address dst, uint256 rad)

for all

    Dai_src : uint256
    May     : uint256

storage

    can[src][CALLER_ID] |-> May
    dai[src]            |-> Dai_src => Dai_src

iff

    // act: caller is `. ? : not` authorised
    (May == 1 or src == CALLER_ID)
    VCallValue == 0

iff in range uint256

    Dai_src - rad

if

    src == dst

calls

    Vat.subuu
    Vat.adduu
```

#### administering a position

This is the core method that opens, manages, and closes a collateralised debt position. This method has the ability to issue or delete dai while increasing or decreasing the position's debt, and to deposit and withdraw "encumbered" collateral from the position. The caller specifies the ilk `i` to interact with, and identifiers `u`, `v`, and `w`, corresponding to the sources of the debt, unencumbered collateral, and dai, respectively. The collateral and debt unit adjustments `dink` and `dart` are specified incrementally.

```act
behaviour frob-diff of Vat
interface frob(bytes32 i, address u, address v, address w, int dink, int dart)

for all

    Ilk_rate : uint256
    Ilk_line : uint256
    Ilk_spot : uint256
    Ilk_dust : uint256
    Ilk_Art  : uint256
    Urn_ink  : uint256
    Urn_art  : uint256
    Gem_iv   : uint256
    Dai_w    : uint256
    Debt     : uint256
    Line     : uint256
    Can_u    : uint256
    Can_v    : uint256
    Can_w    : uint256
    Live     : uint256

storage

    ilks[i].rate      |-> Ilk_rate
    ilks[i].line      |-> Ilk_line
    ilks[i].spot      |-> Ilk_spot
    ilks[i].dust      |-> Ilk_dust
    Line              |-> Line
    can[u][CALLER_ID] |-> Can_u
    can[v][CALLER_ID] |-> Can_v
    can[w][CALLER_ID] |-> Can_w
    urns[i][u].ink    |-> Urn_ink  => Urn_ink + dink
    urns[i][u].art    |-> Urn_art  => Urn_art + dart
    ilks[i].Art       |-> Ilk_Art  => Ilk_Art + dart
    gem[i][v]         |-> Gem_iv   => Gem_iv  - dink
    dai[w]            |-> Dai_w    => Dai_w + (Ilk_rate * dart)
    debt              |-> Debt     => Debt  + (Ilk_rate * dart)
    live              |-> Live

iff in range uint256

    Urn_ink + dink
    Urn_art + dart
    Ilk_Art + dart
    Gem_iv  - dink
    Dai_w + (Ilk_rate * dart)
    Debt  + (Ilk_rate * dart)
    (Urn_art + dart) * Ilk_rate
    (Urn_ink + dink) * Ilk_spot

iff in range int256

    Ilk_rate
    Ilk_rate * dart

iff
    VCallValue == 0
    (dart <= 0) or (((Ilk_Art + dart) * Ilk_rate <= Ilk_line) and ((Debt + Ilk_rate * dart) <= Line))
    (dart <= 0 and dink >= 0) or ((((Urn_art + dart) * Ilk_rate) <= ((Urn_ink + dink) * Ilk_spot)))
    (dart <= 0 and dink >= 0) or (u == CALLER_ID or Can_u == 1)
    (dink <= 0) or (v == CALLER_ID or Can_v == 1)
    (dart >= 0) or (w == CALLER_ID or Can_w == 1)
    ((Urn_art + dart) == 0) or (((Urn_art + dart) * Ilk_rate) >= Ilk_dust)
    Ilk_rate =/= 0
    Live == 1

if

    u =/= v
    v =/= w
    u =/= w

calls

    Vat.addui
    Vat.subui
    Vat.mului
    Vat.muluu
```

note: failing due to timeout. A single path through `frob`.

```act
behaviour lock of Vat
interface frob(bytes32 i, address u, address v, address w, int dink, int dart)

for all

    Ilk_rate : uint256
    Ilk_line : uint256
    Ilk_spot : uint256
    Ilk_dust : uint256
    Ilk_Art  : uint256
    Urn_ink  : uint256
    Urn_art  : uint256
    Gem_iv   : uint256
    Dai_w    : uint256
    Debt     : uint256
    Line     : uint256
    Can_u    : uint256
    Can_v    : uint256
    Can_w    : uint256
    Live     : uint256

storage

    ilks[i].rate      |-> Ilk_rate
    ilks[i].line      |-> Ilk_line
    ilks[i].spot      |-> Ilk_spot
    ilks[i].dust      |-> Ilk_dust
    Line              |-> Line
    can[u][CALLER_ID] |-> Can_u
    can[v][CALLER_ID] |-> Can_v
    can[w][CALLER_ID] |-> Can_w
    urns[i][u].ink    |-> Urn_ink  => Urn_ink + dink
    urns[i][u].art    |-> Urn_art  => Urn_art
    ilks[i].Art       |-> Ilk_Art  => Ilk_Art
    gem[i][v]         |-> Gem_iv   => Gem_iv  - dink
    dai[w]            |-> Dai_w    => Dai_w
    debt              |-> Debt     => Debt
    live              |-> Live

iff
    VCallValue == 0
    Gem_iv >= dink
    Urn_art <= maxSInt256
    Ilk_rate <= maxSInt256
    Urn_ink + dink <= maxSInt256
    (Urn_art * Ilk_rate) <= maxUInt256
    (dink == 0) or (v == CALLER_ID or Can_v == 1)
    (Urn_art == 0) or ((Urn_art * Ilk_rate) >= Ilk_dust)
    Ilk_rate =/= 0
    Live == 1

if
    dart == 0
    dink >= 0
    u =/= v
    v =/= w
    u =/= w

calls

    Vat.addui
    Vat.subui
    Vat.mului
    Vat.muluu
```

```act
behaviour frob-same of Vat
interface frob(bytes32 i, address u, address v, address w, int dink, int dart)

for all

    Ilk_rate : uint256
    Ilk_line : uint256
    Ilk_spot : uint256
    Ilk_dust : uint256
    Ilk_Art  : uint256
    Urn_ink  : uint256
    Urn_art  : uint256
    Gem_iu   : uint256
    Dai_u    : uint256
    Debt     : uint256
    Line     : uint256
    Can_u    : uint256
    Live     : uint256

storage

    ilks[i].rate      |-> Ilk_rate
    ilks[i].line      |-> Ilk_line
    ilks[i].spot      |-> Ilk_spot
    ilks[i].dust      |-> Ilk_dust
    Line              |-> Line
    can[u][CALLER_ID] |-> Can_u
    urns[i][u].ink    |-> Urn_ink  => Urn_ink + dink
    urns[i][u].art    |-> Urn_art  => Urn_art + dart
    ilks[i].Art       |-> Ilk_Art  => Ilk_Art + dart
    gem[i][u]         |-> Gem_iu   => Gem_iu  - dink
    dai[u]            |-> Dai_u    => Dai_u + (Ilk_rate * dart)
    debt              |-> Debt     => Debt  + (Ilk_rate * dart)
    live              |-> Live

iff in range uint256

    Urn_ink + dink
    Urn_art + dart
    Ilk_Art + dart
    Gem_iv  - dink
    Dai_w + (Ilk_rate * dart)
    Debt  + (Ilk_rate * dart)
    (Urn_art + dart) * Ilk_rate

iff in range int256

    Ilk_rate
    Ilk_rate * dart

if

    u == v
    v == w
    u == w

iff

    VCallValue == 0
    (dart <= 0) or (((Ilk_Art + dart) * Ilk_rate <= Ilk_line) and ((Debt + Ilk_rate * dart) <= Line))
    (dart <= 0 and dink >= 0) or ((((Urn_art + dart) * Ilk_rate) <= ((Urn_ink + dink) * Ilk_spot)) and (Urn_ink + ABI_dink) * Ilk_spot <= maxSInt256)
    u == CALLER_ID or Can_u == 1
    ((Urn_art + dart) == 0) or (((Urn_art + dart) * Ilk_rate) >= Ilk_dust)
    Ilk_rate =/= 0
    Live == 1

calls

    Vat.addui
    Vat.subui
    Vat.mului
    Vat.muluu
```

#### forking a position

```act
behaviour fork-diff of Vat
interface fork(bytes32 ilk, address src, address dst, int256 dink, int256 dart)

for all

    Can_src : uint256
    Can_dst : uint256
    Rate    : uint256
    Spot    : uint256
    Dust    : uint256
    Ink_u   : uint256
    Art_u   : uint256
    Ink_v   : uint256
    Art_v   : uint256

storage

    can[src][CALLER_ID] |-> Can_src
    can[dst][CALLER_ID] |-> Can_dst
    ilks[ilk].rate      |-> Rate
    ilks[ilk].spot      |-> Spot
    ilks[ilk].dust      |-> Dust
    urns[ilk][src].ink  |-> Ink_u => Ink_u - dink
    urns[ilk][src].art  |-> Art_u => Art_u - dart
    urns[ilk][dst].ink  |-> Ink_v => Ink_v + dink
    urns[ilk][dst].art  |-> Art_v => Art_v + dart

iff
    VCallValue == 0

    (src == CALLER_ID) or (Can_src == 1)
    (dst == CALLER_ID) or (Can_dst == 1)

    (Art_u - dart) * Rate <= (Ink_u - dink) * Spot
    (Art_v + dart) * Rate <= (Ink_v + dink) * Spot

    ((Art_u - dart) * Rate >= Dust) or (Art_u - dart == 0)
    ((Art_v + dart) * Rate >= Dust) or (Art_v + dart == 0)

iff in range uint256

    Ink_u - dink
    Ink_v + dink
    Art_u - dart
    Art_v + dart
    (Ink_u - dink) * Spot
    (Ink_v + dink) * Spot

if

    src =/= dst

calls

    Vat.addui
    Vat.subui
    Vat.muluu
```

```act
behaviour fork-same of Vat
interface fork(bytes32 ilk, address src, address dst, int256 dink, int256 dart)

for all

    Can_src : uint256
    Rate    : uint256
    Spot    : uint256
    Dust    : uint256
    Ink_u   : uint256
    Art_u   : uint256

storage

    can[src][CALLER_ID] |-> Can_src
    ilks[ilk].rate      |-> Rate
    ilks[ilk].spot      |-> Spot
    ilks[ilk].dust      |-> Dust
    urns[ilk][src].ink  |-> Ink_u => Ink_u
    urns[ilk][src].art  |-> Art_u => Art_u


iff
    VCallValue == 0

    (dink >= 0) or (Ink_u - dink <= maxUInt256)
    (dink <= 0) or (Ink_u - dink >= 0)
    (dart >= 0) or (Art_u - dart <= maxUInt256)
    (dart <= 0) or (Art_u - dart >= 0)

    Ink_u * Spot <= maxUInt256

    (src == CALLER_ID) or (Can_src == 1)

    Art_u * Rate <= Ink_u * Spot
    (Art_u * Rate >= Dust) or (Art_u == 0)

if

    src == dst

calls

    Vat.addui
    Vat.subui
    Vat.muluu
```

#### confiscating a position

When a position of a user `u` is seized, both the collateral and debt are deleted from the user's account and assigned to the system's balance sheet, with the debt reincarnated as `sin` and assigned to some agent of the system `w`, while collateral goes to `v`.

```act
behaviour grab of Vat
interface grab(bytes32 i, address u, address v, address w, int256 dink, int256 dart)

for all

    May    : uint256
    Rate   : uint256
    Ink_iu : uint256
    Art_iu : uint256
    Art_i  : uint256
    Gem_iv : uint256
    Sin_w  : uint256
    Vice   : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[i].Art      |-> Art_i  => Art_i  + dart
    ilks[i].rate     |-> Rate
    urns[i][u].ink   |-> Ink_iu => Ink_iu + dink
    urns[i][u].art   |-> Art_iu => Art_iu + dart
    gem[i][v]        |-> Gem_iv => Gem_iv - dink
    sin[w]           |-> Sin_w  => Sin_w  - (Rate * dart)
    vice             |-> Vice   => Vice   - (Rate * dart)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

iff in range uint256

    Ink_iu + dink
    Art_iu + dart
    Art_i  + dart
    Gem_iv - dink
    Sin_w  - (Rate * dart)
    Vice   - (Rate * dart)

iff in range int256

    Rate
    Rate * dart

calls

    Vat.mului
    Vat.addui
    Vat.subui
```

#### annihilating system debt and surplus

`dai` and `sin` are two sides of the same coin. When the system has surplus `dai`, it can be cancelled with `sin`.

```act
behaviour heal of Vat
interface heal(uint256 rad)

for all

    Dai  : uint256
    Sin  : uint256
    Debt : uint256
    Vice : uint256

storage

    dai[CALLER_ID]   |-> Dai => Dai - rad
    sin[CALLER_ID]   |-> Sin => Sin - rad
    debt             |-> Debt  => Debt  - rad
    vice             |-> Vice  => Vice  - rad

iff

    VCallValue == 0

iff in range uint256

    Dai - rad
    Sin - rad
    Debt  - rad
    Vice  - rad

calls

    Vat.subuu
```
#### Creating system debt and surplus

Authorized actors can increase system debt to generate more dai.
```act
behaviour suck of Vat
interface suck(address u, address v, uint256 rad)

for all

    May   : uint256
    Dai_v : uint256
    Sin_u : uint256
    Debt  : uint256
    Vice  : uint256

storage

    wards[CALLER_ID] |-> May
    sin[u]           |-> Sin_u => Sin_u + rad
    dai[v]           |-> Dai_v => Dai_v + rad
    debt             |-> Debt  => Debt  + rad
    vice             |-> Vice  => Vice  + rad

iff

    May == 1
    VCallValue == 0

iff in range uint256

    Dai_v + rad
    Sin_u + rad
    Debt  + rad
    Vice  + rad

calls

    Vat.adduu
```

#### applying interest to an `ilk`

Interest is charged on an `ilk` `i` by adjusting the debt unit `Rate`, which says how many units of `dai` correspond to a unit of `art`. To preserve a key invariant, dai must be created or destroyed, depending on whether `Rate` is increasing or decreasing. The beneficiary/benefactor of the dai is `u`.

```act
behaviour fold of Vat
interface fold(bytes32 i, address u, int256 rate)

for all

    May    : uint256
    Rate_i : uint256
    Dai_u  : uint256
    Art_i  : uint256
    Debt   : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[i].rate     |-> Rate_i => Rate_i + rate
    ilks[i].Art      |-> Art_i
    dai[u]           |-> Dai_u => Dai_u + Art_i * rate
    debt             |-> Debt  => Debt  + Art_i * rate
    live             |-> Live

iff

    VCallValue == 0
    May == 1
    Live == 1
    Art_i <= maxSInt256

iff in range int256

    Art_i * rate

iff in range uint256

    Rate_i + rate
    Dai_u  + (Art_i * rate)
    Debt   + (Art_i * rate)

calls

    Vat.addui
    Vat.mului
```

# Dai

The `Dai` contract is the user facing ERC20 contract maintaining the accounting for external Dai balances. Most functions are standard for a token with changing supply, but it also notably features the ability to issue approvals for transferFroms based on signed messages, called `Permit`s.

## Specification of behaviours

### Accessors

```act
behaviour wards of Dai
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

```act
behaviour allowance of Dai
interface allowance(address holder, address spender)

types

    Allowed : uint256

storage

    allowance[holder][spender] |-> Allowed

iff

    VCallValue == 0

returns Allowed
```

```act
behaviour balanceOf of Dai
interface balanceOf(address who)

types

    Balance : uint256

storage

    balanceOf[who] |-> Balance

iff

    VCallValue == 0

returns Balance
```

```act
behaviour totalSupply of Dai
interface totalSupply()

types

    Supply : uint256

storage

    totalSupply |-> Supply

iff

    VCallValue == 0

returns Supply
```

```act
behaviour nonces of Dai
interface nonces(address who)

types

    Nonce : uint256

storage

    nonces[who] |-> Nonce

iff

    VCallValue == 0

returns Nonce
```

```act
behaviour decimals of Dai
interface decimals()

iff

    VCallValue == 0

returns 18
```

```act
behaviour name of Dai
interface name()

iff

    VCallValue == 0

returnsRaw #asByteStackInWidthaux(32, 31, 32, #enc(#string("Dai Stablecoin")))
```

```act
behaviour version of Dai
interface version()

iff

    VCallValue == 0

returnsRaw #asByteStackInWidthaux(32, 31, 32, #enc(#string("1")))
```

```act
behaviour symbol of Dai
interface symbol()

iff

    VCallValue == 0

returnsRaw #asByteStackInWidthaux(32, 31, 32, #enc(#string("DAI")))
```

```act
behaviour PERMIT_TYPEHASH of Dai
interface PERMIT_TYPEHASH()

iff

    VCallValue == 0

returns keccak(#parseByteStackRaw("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)"))
```

```act
behaviour DOMAIN_SEPARATOR of Dai
interface DOMAIN_SEPARATOR()

for all

    Dom : uint256

storage

    DOMAIN_SEPARATOR |-> Dom

iff

    VCallValue == 0

returns Dom
```

### Mutators


#### adding and removing owners

Any owner can add and remove owners.

```act
behaviour rely-diff of Dai
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Dai
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Dai
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Dai
interface deny(address usr)

for all

    Could : uint256

storage

    wards[CALLER_ID] |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Could == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

```act
behaviour adduu of Dai
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour subuu of Dai
interface sub(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour transfer-diff of Dai
interface transfer(address dst, uint wad)

types

    SrcBal : uint256
    DstBal : uint256

storage

    balanceOf[CALLER_ID] |-> SrcBal => SrcBal - wad
    balanceOf[dst]        |-> DstBal => DstBal + wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff

    VCallValue == 0

if
    CALLER_ID =/= dst

returns 1

calls

    Dai.adduu
    Dai.subuu
```

```act
behaviour transfer-same of Dai
interface transfer(address dst, uint wad)

types

    SrcBal : uint256

storage

    balanceOf[CALLER_ID] |-> SrcBal => SrcBal

iff in range uint256

    SrcBal - wad

iff

    VCallValue == 0

if

    CALLER_ID == dst

returns 1

calls

    Dai.adduu
    Dai.subuu
```

```act
behaviour transferFrom-diff of Dai
interface transferFrom(address src, address dst, uint wad)

types

    SrcBal  : uint256
    DstBal  : uint256
    Allowed : uint256

storage

    allowance[src][CALLER_ID] |-> Allowed => #if (src == CALLER_ID or Allowed == maxUInt256) #then Allowed #else Allowed - wad #fi
    balanceOf[src]            |-> SrcBal  => SrcBal  - wad
    balanceOf[dst]            |-> DstBal  => DstBal  + wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff
    wad <= Allowed or src == CALLER_ID
    VCallValue == 0

if
    src =/= dst

returns 1

calls

    Dai.adduu
    Dai.subuu
```

```act
behaviour move-diff of Dai
interface move(address src, address dst, uint wad)

types

    SrcBal  : uint256
    DstBal  : uint256
    Allowed : uint256

storage

    allowance[src][CALLER_ID] |-> Allowed => #if (src == CALLER_ID or Allowed == maxUInt256) #then Allowed #else Allowed - wad #fi
    balanceOf[src]            |-> SrcBal  => SrcBal  - wad
    balanceOf[dst]            |-> DstBal  => DstBal  + wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff
    wad <= Allowed or src == CALLER_ID
    VCallValue == 0

if
    src =/= dst

calls

    Dai.transferFrom-diff
```

```act
behaviour push of Dai
interface push(address dst, uint wad)

types

    SrcBal  : uint256
    DstBal  : uint256

storage

    balanceOf[CALLER_ID]      |-> SrcBal  => SrcBal  - wad
    balanceOf[dst]            |-> DstBal  => DstBal  + wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff
    VCallValue == 0

if
    CALLER_ID =/= dst

calls

    Dai.transferFrom-diff
```

```act
behaviour pull of Dai
interface pull(address src, uint wad)

types

    SrcBal  : uint256
    DstBal  : uint256
    Allowed : uint256

storage

    allowance[src][CALLER_ID] |-> Allowed => #if (src == CALLER_ID or Allowed == maxUInt256) #then Allowed #else Allowed - wad #fi
    balanceOf[src]            |-> SrcBal  => SrcBal  - wad
    balanceOf[CALLER_ID]      |-> DstBal  => DstBal  + wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff
    wad <= Allowed or src == CALLER_ID
    VCallValue == 0

if
    src =/= CALLER_ID

calls

    Dai.transferFrom-diff
```

```act
behaviour transferFrom-same of Dai
interface transferFrom(address src, address dst, uint wad)

types

    SrcBal  : uint256
    Allowed : uint256

storage

    allowance[src][CALLER_ID] |-> Allowed => #if (src == CALLER_ID or Allowed == maxUInt256) #then Allowed #else Allowed - wad #fi
    balanceOf[src]            |-> SrcBal  => SrcBal

iff in range uint256

    SrcBal - wad

iff
    wad <= Allowed or src == CALLER_ID
    VCallValue == 0

if
    src == dst

returns 1

calls

    Dai.adduu
    Dai.subuu
```

```act
behaviour mint of Dai
interface mint(address dst, uint wad)

types

    DstBal      : uint256
    TotalSupply : uint256

storage

    wards[CALLER_ID] |-> May
    balanceOf[dst]   |-> DstBal => DstBal + wad
    totalSupply      |-> TotalSupply => TotalSupply + wad

iff in range uint256

    DstBal + wad
    TotalSupply + wad

iff

    May == 1
    VCallValue == 0

calls

    Dai.adduu
```

```act
behaviour burn of Dai
interface burn(address src, uint wad)

types

    SrcBal      : uint256
    TotalSupply : uint256
    Allowed     : uint256

storage

    allowance[src][CALLER_ID] |-> Allowed => #if (src == CALLER_ID or Allowed == maxUInt256) #then Allowed #else Allowed - wad #fi
    balanceOf[src]            |-> SrcBal => SrcBal - wad
    totalSupply               |-> TotalSupply => TotalSupply - wad

iff in range uint256

    SrcBal - wad
    TotalSupply - wad

iff

    (Allowed == maxUInt256) or (wad <= Allowed) or (src == CALLER_ID)
    VCallValue == 0

calls

    Dai.subuu
```


```act
behaviour approve of Dai
interface approve(address usr, uint wad)

types

    Allowed : uint256

storage

    allowance[CALLER_ID][usr] |-> Allowed => wad

iff
    VCallValue == 0

returns 1
```

```act
behaviour permit of Dai
interface permit(address hodler, address ombudsman, uint256 n, uint256 ttl, bool may, uint8 v, bytes32 r, bytes32 s)

types

    Nonce   : uint256
    Allowed : uint256
    Domain_separator : bytes32

storage

    nonces[hodler]               |-> Nonce => 1 + Nonce
    DOMAIN_SEPARATOR             |-> Domain_separator
    allowance[hodler][ombudsman] |-> Allowed => (#if may == 0 #then 0 #else maxUInt256 #fi)

iff

    hodler == #symEcrec(keccakIntList(#asWord(#parseHexWord("0x19") : #parseHexWord("0x1") : .WordStack) Domain_separator keccakIntList(keccak(#parseByteStackRaw("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)")) hodler ombudsman n ttl may)), v, r, s)
    ttl == 0 or TIME <= ttl
    VCallValue == 0
    n == Nonce
    VCallDepth < 1024

if

    #rangeUInt(256, Nonce + 1)
```

# Jug

The `Jug` updates each collateral type's debt unit `rate` while the offsetting dai is supplied to/by a `vow`. The effect of this is to apply interest to outstanding positions.

## Specification of behaviours

### Accessors

#### owners


```act
behaviour wards of Jug
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### `ilk` data


```act
behaviour ilks of Jug
interface ilks(bytes32 ilk)

for all

    Vow : bytes32
    Duty : uint256
    Rho : uint48

storage

    ilks[ilk].duty |-> Duty
    ilks[ilk].rho  |-> Rho

iff

    VCallValue == 0

returns Duty : Rho
```

#### `vat` address

```act
behaviour vat of Jug
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### `vow` address

```act
behaviour vow of Jug
interface vow()

for all

    Vow : address

storage

    vow |-> Vow

iff

    VCallValue == 0

returns Vow
```

#### global interest rate

```act
behaviour base of Jug
interface base()

for all

    Base : uint256

storage

    base |-> Base

iff

    VCallValue == 0

returns Base
```


### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Jug
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Jug
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Jug
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Jug
interface deny(address usr)

for all

    Could : uint256

storage

    wards[CALLER_ID] |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Could == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### initialising an `ilk`


```act
behaviour init of Jug
interface init(bytes32 ilk)

for all

    May  : uint256
    Duty : uint256
    Rho  : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].duty   |-> Duty => #Ray
    ilks[ilk].rho    |-> Rho => TIME

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: `Duty` is `. ? : not` zero
    Duty == 0
    VCallValue == 0

```

#### setting `ilk` data


```act
behaviour file of Jug
interface file(bytes32 ilk, bytes32 what, uint256 data)

for all

    May : uint256
    Duty : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].duty   |-> Duty => (#if what == #string2Word("duty") #then data #else Duty #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting the base rate

```act
behaviour file-base of Jug
interface file(bytes32 what, uint256 data)

for all

    May  : uint256
    Base : uint256

storage

    wards[CALLER_ID] |-> May
    base             |-> Base => (#if what == #string2Word("base") #then data #else Base #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting the `vow`

```act
behaviour file-vow of Jug
interface file(bytes32 what, address data)

for all

    May : uint256
    Vow : address

storage

    wards[CALLER_ID] |-> May
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### updating the rates

```act
behaviour drip of Jug
interface drip(bytes32 ilk)

for all

    Vat    : address VatLike
    Base   : uint256
    Vow    : bytes32
    Duty   : uint256
    Rho    : uint48
    May    : uint256
    Rate   : uint256
    Art_i  : uint256
    Dai    : uint256
    Debt   : uint256

storage

    vat            |-> Vat
    vow            |-> Vow
    base           |-> Base
    ilks[ilk].duty |-> Duty
    ilks[ilk].rho  |-> Rho => TIME

storage Vat

    wards[ACCT_ID] |-> May
    ilks[ilk].rate |-> Rate => Rate + (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)
    ilks[ilk].Art  |-> Art_i
    dai[Vow]       |-> Dai  => Dai  + Art_i * (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)
    debt           |-> Debt => Debt + Art_i * (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range uint256

    Base + Duty
    TIME - Rho
    #rpow(Base + Duty, TIME - Rho, #Ray) * #Ray
    #rpow(Base + Duty, TIME - Rho, #Ray) * Rate
    Rate + (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)
    Dai  + Art_i * (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)
    Debt + Art_i * (#rmul(#rpow(Base + Duty, TIME - Rho, #Ray), Rate) - Rate)

iff in range int256

    Art_i
    #rmul(#rpow(Repo + Duty, TIME - Rho, #Ray), Rate) - Rate
    Art_i * (#rmul(#rpow(Repo + Duty, TIME - Rho, #Ray), Rate) - Rate)

calls

    Jug.adduu
    Jug.rpow
```

## `rpow`

```act
behaviour adduu of Jug
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

This is the coinductive lemma.
```
0.    n % 2 == 0
      case: n >= 2
            n even
      gas: 178

1.    n % 2 == 1
1.0.  n / 2 == 0
      case: n == 1
      terminate loop
      gas: 194

1.1.  n / 2 == 1
      case: n >= 3
            n odd
      coinductive step
      gas: 293


num0 n := "number of 0 in n"
num1 n := "number of 1 in n"

gas = 194 + num0(n) * 178 + num1(n) * 293
```

```act
behaviour rpow-loop of Jug
lemma

//  0a3a => 0a7e
pc

    2618 => 2686

for all

    Half   : uint256
    Z      : uint256
    Base   : uint256
    N      : uint256
    X      : uint256

stack

    _ : _ : Half : _ : Z : Base : N : X : WS => Half : _ : #rpow(Z, X, N, Base) : Base : 0 : _ : WS

gas

    194 + ((num0(N) * 172) + (num1(N) * 287))

if

    Half == Base / 2
    0 <= #rpow(Z, X, N, Base)
    #rpow(Z, X, N, Base) * Base < pow256
    N =/= 0
    Base =/= 0
    #sizeWordStack(WS) <= 1000
    num0(N) >= 0
    num1(N) >= 0
```


```act
behaviour rpow of Jug
interface rpow(uint256 x, uint256 n, uint256 b) internal

stack

    b : n : x : JMPTO : WS => JMPTO : #rpow(b, x, n, b) : WS

gas

    3000000 +Int ((num0(ABI_n) *Int 172) +Int (num1(ABI_n) *Int 287))

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 999
    num0(n) >= 0
    num1(n) >= 0
    b =/= 0
    0 <= #rpow(b, x, n, b)
    #rpow(b, x, n, b) * b < pow256

calls

    Jug.rpow-loop
```

# Pot

The `Pot` implements savings interest on dai balances. It allows any user to deposit and withdraw dai on demand, with the deposited dai earning interest from the `Vow`.

## Specification of behaviours

### Arithmetic lemmas

```act
behaviour adduu of Pot
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour subuu of Pot
interface sub(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```
```act
behaviour muluu of Pot
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    #sizeWordStack(WS) <= 1000
```

```act
behaviour rmul of Pot
interface rmul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : (x * y) / #Ray : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```


### Accessors

#### owners

```act
behaviour wards of Pot
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### deposit balances

```act
behaviour pie of Pot
interface pie(address usr)

for all

    Pie_usr : uint256

storage

    pie[usr] |-> Pie_usr

iff

    VCallValue == 0

returns Pie_usr
```

#### total deposits

```act
behaviour Pie of Pot
interface Pie()

for all

    Pie_tot : uint256

storage

    Pie |-> Pie_tot

iff

    VCallValue == 0

returns Pie_tot
```

#### savings interest rate

```act
behaviour dsr of Pot
interface dsr()

for all

    Dsr : uint256

storage

    dsr |-> Dsr

iff

    VCallValue == 0

returns Dsr
```

#### savings interest rate accumulator

```act
behaviour chi of Pot
interface chi()

for all

    Chi : uint256

storage

    chi |-> Chi

iff

    VCallValue == 0

returns Chi
```

#### `Vat` address

```act
behaviour vat of Pot
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### `Vow` address

```act
behaviour vow of Pot
interface vow()

for all

    Vow : address

storage

    vow |-> Vow

iff

    VCallValue == 0

returns Vow
```

#### last `drip` time

```act
behaviour rho of Pot
interface rho()

for all

    Rho : uint256

storage

    rho |-> Rho

iff

    VCallValue == 0

returns Rho
```

### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Pot
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Pot
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Pot
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Pot
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### setting the savings rate

```act
behaviour file-dsr of Pot
interface file(bytes32 what, uint256 data)

for all

    May : uint256
    Dsr : uint256

storage

    wards[CALLER_ID] |-> May
    dsr              |-> Dsr => (#if what == #string2Word("dsr") #then data #else Dsr #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting the `Vow` address

```act
behaviour file-vow of Pot
interface file(bytes32 what, address addr)

for all

    May : uint256
    Vow : address

storage

    wards[CALLER_ID] |-> May
    vow              |-> Vow => (#if what == #string2Word("vow") #then addr #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### `rpow`

```act
behaviour rpow-loop of Pot
lemma

//  0e01 => 0e45
pc

    3585 => 3653

for all

    Half   : uint256
    Z      : uint256
    Base   : uint256
    N      : uint256
    X      : uint256

stack

    _ : _ : Half : _ : Z : Base : N : X : WS => Half : _ : #rpow(Z, X, N, Base) : Base : 0 : _ : WS

gas

    194 + ((num0(N) * 172) + (num1(N) * 287))

if

    Half == Base / 2
    0 <= #rpow(Z, X, N, Base)
    #rpow(Z, X, N, Base) * Base < pow256
    N =/= 0
    Base =/= 0
    #sizeWordStack(WS) <= 1000
    num0(N) >= 0
    num1(N) >= 0
```


```act
behaviour rpow of Pot
interface rpow(uint256 x, uint256 n, uint256 b) internal

stack

    b : n : x : JMPTO : WS => JMPTO : #rpow(b, x, n, b) : WS

gas

    3000000 +Int ((num0(ABI_n) *Int 172) +Int (num1(ABI_n) *Int 287))

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 999
    num0(n) >= 0
    num1(n) >= 0
    b =/= 0
    0 <= #rpow(b, x, n, b)
    #rpow(b, x, n, b) * b < pow256

calls

    Pot.rpow-loop
```

#### accumulating interest

```act
behaviour drip of Pot
interface drip()

for all

    Rho  : uint256
    Chi  : uint256
    Dsr  : uint256
    Pie  : uint256
    Vow  : address
    Vat  : address
    May  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    rho |-> Rho => TIME
    chi |-> Chi => #rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi)
    dsr |-> Dsr
    Pie |-> Pie
    vow |-> Vow
    vat |-> Vat

storage Vat

    wards[ACCT_ID] |-> May
    dai[ACCT_ID]   |-> Dai  => Dai + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    sin[Vow]       |-> Sin  => Sin + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    vice           |-> Vice => Vice + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    debt           |-> Debt => Debt + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)

iff

    Rho <= TIME
    May == 1

iff in range uint256

    #rpow(Dsr, TIME - Rho, #Ray)* Chi
    #rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi
    Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    Dai + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    Sin + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    Vice + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)
    Debt + Pie * (#rmul(#rpow(Dsr, TIME - Rho, #Ray), Chi) - Chi)

calls

    Pot.rmul
    Pot.rpow
    Pot.adduu
    Pot.subuu
    Pot.muluu
```

#### deposits and withdrawals

```act
behaviour join of Pot
interface join(uint256 wad)

for all

    Pie_u   : uint256
    Pie_tot : uint256
    Chi     : uint256
    Vat     : address VatLike
    Can     : uint256
    Dai_u   : uint256
    Dai_p   : uint256

storage

    pie[CALLER_ID] |-> Pie_u   => Pie_u + wad
    Pie            |-> Pie_tot => Pie_tot + wad
    chi            |-> Chi
    vat            |-> Vat

storage Vat

    can[ACCT_ID][CALLER_ID] |-> Can
    dai[CALLER_ID]          |-> Dai_u => Dai_u - Chi * wad
    dai[ACCT_ID]            |-> Dai_p => Dai_p + Chi * wad

iff

    Can == 1
    VCallValue == 0

iff in range uint256

    Pie_u + wad
    Pie_tot + wad
    Chi * wad
    Dai_u - Chi * wad
    Dai_p + Chi * wad

calls

    Pot.adduu
    Pot.muluu
```

```act
behaviour exit of Pot
interface exit(uint256 wad)

for all

    Pie_u   : uint256
    Pie_tot : uint256
    Chi     : uint256
    Vat     : address VatLike
    Dai_u   : uint256
    Dai_p   : uint256

storage

    pie[CALLER_ID] |-> Pie_u   => Pie_u - wad
    Pie            |-> Pie_tot => Pie_tot - wad
    chi            |-> Chi
    vat            |-> Vat

storage Vat

    dai[CALLER_ID]          |-> Dai_u => Dai_u + Chi * wad
    dai[ACCT_ID]            |-> Dai_p => Dai_p - Chi * wad

iff

    VCallValue == 0

iff in range uint256

    Pie_u - wad
    Pie_tot - wad
    Chi * wad
    Dai_u + Chi * wad
    Dai_p - Chi * wad

calls

    Pot.subuu
    Pot.muluu
```

# Vow

The `Vow` is the system's fiscal organ, the recipient of both system surplus and system debt. Its function is to cover deficits via [debt auctions](#starting-a-debt-auction) and discharge surpluses via [surplus auctions](#starting-a-surplus-auction).

## Specification of behaviours

### Lemmas

```act
behaviour adduu of Vow
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour subuu of Vow
interface sub(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour minuu of Vow
interface min(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : #if x > y #then y #else x #fi : WS

if

    #sizeWordStack(WS) <= 1000
```

### Accessors

#### owners

```act
behaviour wards of Vow
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### getting the `Vat`

```act
behaviour vat of Vow
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### getting the `Flapper`

```act
behaviour flapper of Vow
interface flapper()

for all

    Flapper : address

storage

    flapper |-> Flapper

iff

    VCallValue == 0

returns Flapper
```

#### getting the `Flopper`

```act
behaviour flopper of Vow
interface flopper()

for all

    Flopper : address

storage

    flopper |-> Flopper

iff

    VCallValue == 0

returns Flopper
```

#### getting a `sin` packet

```act
behaviour sin of Vow
interface sin(uint256 era)

for all

    Sin_era : uint256

storage

    sin[era] |-> Sin_era

iff

    VCallValue == 0

returns Sin_era
```

#### getting the `Sin`

```act
behaviour Sin of Vow
interface Sin()

for all

    Sin : uint256

storage

    Sin |-> Sin

iff

    VCallValue == 0

returns Sin
```

#### getting the `Ash`

```act
behaviour Ash of Vow
interface Ash()

for all

    Ash : uint256

storage

    Ash |-> Ash

iff

    VCallValue == 0

returns Ash
```

#### getting the `wait`

```act
behaviour wait of Vow
interface wait()

for all

    Wait : uint256

storage

    wait |-> Wait

iff

    VCallValue == 0

returns Wait
```

#### getting the `sump`

```act
behaviour sump of Vow
interface sump()

for all

    Sump : uint256

storage

    sump |-> Sump

iff

    VCallValue == 0

returns Sump
```

#### getting the `bump`

```act
behaviour bump of Vow
interface bump()

for all

    Bump : uint256

storage

    bump |-> Bump

iff

    VCallValue == 0

returns Bump
```

#### getting the `hump`

```act
behaviour hump of Vow
interface hump()

for all

    Hump : uint256

storage

    hump |-> Hump

iff

    VCallValue == 0

returns Hump
```

#### getting the `live` flag

```act
behaviour live of Vow
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Vow
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Vow
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Vow
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Vow
interface deny(address usr)

for all

    Could : uint256

storage

    wards[CALLER_ID] |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Could == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### setting `Vow` parameters

```act
behaviour file-data of Vow
interface file(bytes32 what, uint256 data)

for all

    May  : uint256
    Wait : uint256
    Sump : uint256
    Bump : uint256
    Hump : uint256

storage

    wards[CALLER_ID] |-> May
    wait             |-> Wait => (#if what == #string2Word("wait") #then data #else Wait #fi)
    sump             |-> Sump => (#if what == #string2Word("sump") #then data #else Sump #fi)
    bump             |-> Bump => (#if what == #string2Word("bump") #then data #else Bump #fi)
    hump             |-> Hump => (#if what == #string2Word("hump") #then data #else Hump #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### cancelling bad debt and surplus

```act
behaviour heal of Vow
interface heal(uint256 rad)

for all

    Vat  : address VatLike
    Ash  : uint256
    Sin  : uint256
    Joy  : uint256
    Awe  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat
    Ash |-> Ash
    Sin |-> Sin

storage Vat

    dai[ACCT_ID] |-> Joy  => Joy  - rad
    sin[ACCT_ID] |-> Awe  => Awe  - rad
    vice         |-> Vice => Vice - rad
    debt         |-> Debt => Debt - rad

iff

    rad <= Joy
    rad <= (Awe - Sin) - Ash
    VCallValue == 0
    VCallDepth < 1024

iff in range uint256

    (Awe - Sin) - Ash
    Joy  - rad
    Awe  - rad
    Vice - rad
    Debt - rad

calls

  Vow.subuu
  Vat.dai
  Vat.sin
  Vat.heal
```

```act
behaviour kiss of Vow
interface kiss(uint256 rad)

for all

    Vat  : address VatLike
    Ash  : uint256
    Joy  : uint256
    Awe  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat
    Ash |-> Ash => Ash - rad

storage Vat

    dai[ACCT_ID] |-> Joy  => Joy  - rad
    sin[ACCT_ID] |-> Awe  => Awe  - rad
    vice         |-> Vice => Vice - rad
    debt         |-> Debt => Debt - rad

iff

    rad <= Joy
    rad <= Ash
    VCallValue == 0
    VCallDepth < 1024

iff in range uint256

    Ash  - rad
    Joy  - rad
    Awe  - rad
    Vice - rad
    Debt - rad

calls

  Vow.subuu
  Vat.dai
  Vat.heal
```

#### adding to the `sin` queue

```act
behaviour fess of Vow
interface fess(uint256 tab)

for all

    May     : uint256
    Sin_era : uint256
    Sin     : uint256

storage

    wards[CALLER_ID] |-> May
    sin[TIME]        |-> Sin_era => Sin_era + tab
    Sin              |-> Sin     => Sin     + tab

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

iff in range uint256

    Sin_era + tab
    Sin     + tab

calls

  Vow.adduu
```

#### processing `sin` queue

```act
behaviour flog of Vow
interface flog(uint256 t)

for all

    Wait  : uint256
    Sin_t : uint256
    Sin   : uint256

storage

    wait   |-> Wait
    Sin    |-> Sin   => Sin - Sin_t
    sin[t] |-> Sin_t => 0

iff

    // act: `sin` has `. ? : not` matured
    t + Wait <= TIME
    VCallValue == 0

iff in range uint256

    t   + Wait
    Sin - Sin_t

calls

  Vow.adduu
  Vow.subuu
```

#### starting a debt auction

```act
behaviour flop of Vow
interface flop()

for all

    Flopper  : address Flopper
    Vat      : address VatLike
    MayFlop  : uint256
    Sin      : uint256
    Ash      : uint256
    Awe      : uint256
    Joy      : uint256
    Sump     : uint256
    Kicks    : uint256
    FlopLive : uint256
    Ttl      : uint48
    Tau      : uint48
    Bid      : uint256
    Lot      : uint256
    Guy      : address
    Tic      : uint48
    End      : uint48

storage

    flopper |-> Flopper
    vat     |-> Vat
    Sin     |-> Sin
    Ash     |-> Ash => Ash + Sump
    sump    |-> Sump

storage Flopper

    live                        |-> FlopLive
    wards[ACCT_ID]              |-> MayFlop
    kicks                       |-> Kicks => 1 + Kicks
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    bids[1 + Kicks].bid         |-> Bid => Sump
    bids[1 + Kicks].lot         |-> Lot => maxUInt256
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic, TIME + Tau)

storage Vat

    dai[ACCT_ID] |-> Joy
    sin[ACCT_ID] |-> Awe

iff

    FlopLive == 1
    MayFlop == 1
    (Awe - Sin) - Ash >= Sump
    Joy == 0
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range uint48

    TIME + Tau

iff in range uint256

    Ash + Sump
    Awe - Sin
    (Awe - Sin) - Ash
    1 + Kicks

if

    #rangeUInt(48, TIME)


returns 1 + Kicks

calls

  Vow.subuu
  Vow.adduu
  Vat.sin
  Vat.dai
  Flopper.kick
```

#### starting a surplus auction

```act
behaviour flap of Vow
interface flap()

for all

    Flapper  : address Flapper
    Vat      : address VatLike
    Sin      : uint256
    Ash      : uint256
    Awe      : uint256
    Joy      : uint256
    Bump     : uint256
    Hump     : uint256
    Can      : uint256
    Dai_a    : uint256
    FlapLive : uint256
    Kicks    : uint256
    Ttl      : uint48
    Tau      : uint48
    Bid      : uint256
    Lot      : uint256
    Guy      : address
    Tic      : uint48
    End      : uint48
    Gal      : address

storage

    vat     |-> Vat
    flapper |-> Flapper
    bump    |-> Bump
    hump    |-> Hump
    Sin     |-> Sin
    Ash     |-> Ash

storage Flapper

    vat                         |-> Vat
    kicks                       |-> Kicks   => 1 + Kicks
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    bids[1 + Kicks].bid         |-> Bid => 0
    bids[1 + Kicks].lot         |-> Lot => Bump
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic, TIME + Tau)
    bids[1 + Kicks].gal         |-> Gal => 0
    live                        |-> FlapLive

storage Vat

    can[ACCT_ID][Flapper] |-> Can
    sin[ACCT_ID]          |-> Awe
    dai[ACCT_ID]          |-> Joy   => Joy   - Bump
    dai[Flapper]          |-> Dai_a => Dai_a + Bump

iff

    VCallValue == 0
    VCallDepth < 1023
    Joy >= (Awe + Bump) + Hump
    (Awe - Sin) - Ash == 0
    FlapLive == 1
    Can == 1

iff in range uint256

    1 + Kicks
    Dai_a + Bump

iff in range uint48

    TIME + Tau

if

    #rangeUInt(48, TIME)
    Flapper =/= Vat
    ACCT_ID =/= Vat
    ACCT_ID =/= Flapper

calls

    Vow.subuu
    Vow.adduu
    Vat.dai
    Vat.sin
    Flapper.kick

returns 1 + Kicks
```

#### system lock down

```act
behaviour cage-surplus of Vow
interface cage()

for all

    Vat      : address VatLike
    Flapper  : address Flapper
    Flopper  : address Flopper
    FlapVat  : address
    MayFlap  : uint256
    MayFlop  : uint256
    Dai_v    : uint256
    Sin_v    : uint256
    Dai_f    : uint256
    Debt     : uint256
    Vice     : uint256
    Live     : uint256
    Sin      : uint256
    Ash      : uint256
    FlapLive : uint256
    FlopLive : uint256

storage

    wards[CALLER_ID] |-> Can
    vat |-> Vat
    flopper |-> Flopper
    flapper |-> Flapper
    live |-> Live => 0
    Sin  |-> Sin  => 0
    Ash  |-> Ash  => 0

storage Vat

    can[Flapper][Flapper] |-> _
    dai[Flapper] |-> Dai_f => 0
    dai[ACCT_ID] |-> Dai_v => (Dai_v + Dai_f) - Sin_v
    sin[ACCT_ID] |-> Sin_v => 0
    debt |-> Debt => Debt - Sin_v
    vice |-> Vice => Vice - Sin_v

storage Flapper

    wards[ACCT_ID] |-> MayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[ACCT_ID] |-> MayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1023
    Can == 1
    MayFlap == 1
    MayFlop == 1

iff in range uint256

    Dai_v + Dai_f
    Debt - Sin_v
    Vice - Sin_v

if

    Dai_v + Dai_f > Sin_v
    Flapper =/= ACCT_ID
    Flapper =/= Vat
    Flopper =/= ACCT_ID
    Flopper =/= Vat
    Flopper =/= Flapper
    FlapVat ==  Vat

calls

  Vow.minuu
  Vat.dai
  Vat.sin
  Vat.heal
  Flapper.cage
  Flopper.cage
```

```act
behaviour cage-deficit of Vow
interface cage()

for all

    Vat     : address VatLike
    Flapper : address Flapper
    Flopper : address Flopper
    FlapVat : address
    MayFlap : uint256
    MayFlop : uint256
    Dai_v   : uint256
    Sin_v   : uint256
    Dai_f   : uint256
    Debt    : uint256
    Vice    : uint256
    Live     : uint256
    Sin      : uint256
    Ash      : uint256
    FlapLive : uint256
    FlopLive : uint256

storage

    wards[CALLER_ID] |-> Can
    vat |-> Vat
    flopper |-> Flopper
    flapper |-> Flapper
    live |-> Live => 0
    Sin  |-> Sin => 0
    Ash  |-> Ash => 0

storage Vat

    can[Flapper][Flapper] |-> _
    dai[Flapper] |-> Dai_f => 0
    dai[ACCT_ID] |-> Dai_v => 0
    sin[ACCT_ID] |-> Sin_v => Sin_v - (Dai_v + Dai_f)
    debt |-> Debt => Debt - (Dai_v + Dai_f)
    vice |-> Vice => Vice - (Dai_v + Dai_f)

storage Flapper

    wards[ACCT_ID] |-> MayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[ACCT_ID] |-> MayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1023
    Can == 1
    MayFlap == 1
    MayFlop == 1

iff in range uint256

    Debt - (Dai_v + Dai_f)
    Vice - (Dai_v + Dai_f)

if

    Dai_v + Dai_f < Sin_v
    Flapper =/= ACCT_ID
    Flapper =/= Vat
    Flopper =/= ACCT_ID
    Flopper =/= Vat
    Flopper =/= Flapper
    FlapVat ==  Vat

calls

  Vow.minuu
  Vat.dai
  Vat.sin
  Vat.heal
  Flapper.cage
  Flopper.cage
```

```act
behaviour cage-balance of Vow
interface cage()

for all

    Vat     : address VatLike
    Flapper : address Flapper
    Flopper : address Flopper
    FlapVat : address
    MayFlap : uint256
    MayFlop : uint256
    Dai_v   : uint256
    Sin_v   : uint256
    Dai_f   : uint256
    Debt    : uint256
    Vice    : uint256
    Live     : uint256
    Sin      : uint256
    Ash      : uint256
    FlapLive : uint256
    FlopLive : uint256

storage

    wards[CALLER_ID] |-> Can
    vat |-> Vat
    flopper |-> Flopper
    flapper |-> Flapper
    live |-> Live => 0
    Sin  |-> Sin => 0
    Ash  |-> Ash => 0

storage Vat

    can[Flapper][Flapper] |-> _
    dai[Flapper] |-> Dai_f => 0
    dai[ACCT_ID] |-> Dai_v => 0
    sin[ACCT_ID] |-> Sin_v => 0
    debt |-> Debt => Debt - (Dai_v + Dai_f)
    vice |-> Vice => Vice - Sin_v

storage Flapper

    wards[ACCT_ID] |-> MayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[ACCT_ID] |-> MayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1023
    Can == 1
    MayFlap == 1
    MayFlop == 1

iff in range uint256

    Dai_v + Dai_f
    Debt - (Dai_v + Dai_f)
    Vice - Sin_v

if

    Dai_v + Dai_f == Sin_v
    Flapper =/= ACCT_ID
    Flapper =/= Vat
    Flopper =/= ACCT_ID
    Flopper =/= Vat
    Flopper =/= Flapper
    FlapVat ==  Vat

calls

  Vow.minuu
  Vat.dai
  Vat.sin
  Vat.heal
  Flapper.cage
  Flopper.cage
```

# Cat

The `Cat` is the system's liquidation agent: it decides when a position is unsafe and allows it to be seized and sent off to auction.

## Specification of behaviours

### Accessors

#### owners

```act
behaviour wards of Cat
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### `ilk` data

```act
behaviour ilks of Cat
interface ilks(bytes32 ilk)

for all

    Chop : uint256
    Flip : address
    Lump : uint256

storage

    ilks[ilk].flip |-> Flip
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump

iff

    VCallValue == 0

returns Flip : Chop : Lump
```

#### liveness

```act
behaviour live of Cat
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

#### `vat` address

```act
behaviour vat of Cat
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### `vow` address

```act
behaviour vow of Cat
interface vow()

for all

    Vow : address

storage

    vow |-> Vow

iff

    VCallValue == 0

returns Vow
```

### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Cat
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Cat
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Cat
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Cat
interface deny(address usr)

for all

    Could : uint256

storage

    wards[CALLER_ID] |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Could == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### setting contract addresses

```act
behaviour file-addr of Cat
interface file(bytes32 what, address data)

for all

    May : uint256
    Vow : address

storage

    wards[CALLER_ID] |-> May
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting liquidation auction

```act
behaviour file-flip of Cat
interface file(bytes32 ilk, bytes32 what, address data)

for all

    Vat  : address VatLike
    May  : uint256
    Flip : address
    Can  : uint256

storage

    vat              |-> Vat
    wards[CALLER_ID] |-> May
    ilks[ilk].flip   |-> Flip => (#if what == #string2Word("flip") #then data #else Flip #fi)

storage Vat

    can[ACCT_ID][data] |-> Can => (#if what == #string2Word("flip") #then 1 #else Can #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
    what =/= #string2Word("flip") or VCallDepth < 1024

calls
  Vat.hope
```

#### setting liquidation data

```act
behaviour file of Cat
interface file(bytes32 ilk, bytes32 what, uint256 data)

for all

    May  : uint256
    Chop : uint256
    Lump : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].chop   |-> Chop => (#if what == #string2Word("chop") #then data #else Chop #fi)
    ilks[ilk].lump   |-> Lump => (#if what == #string2Word("lump") #then data #else Lump #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

#### setting liquidator address

```
behaviour file-flip of Cat
interface file(bytes32 ilk, bytes32 what, address data)

for all

    Vat  : address VatLike
    May  : uint256
    Flip : address
    Hope : uint256

storage

    vat |-> Vat
    wards[CALLER_ID] |-> May
    ilks[ilk].flip   |-> Flip => (#if what == #string2Word("flip") #then data #else Flip #fi)

storage Vat

    can[ACCT_ID][data] |-> Hope => (#if what == #string2Word("flip") #then 1 #else Hope #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

calls

  Vat.hope
```

#### liquidating a position

```act
behaviour muluu of Cat
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    #sizeWordStack(WS) <= 1000
```

```act
behaviour minuu of Cat
interface min(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : #if x > y #then y #else x #fi : WS

if

    #sizeWordStack(WS) <= 1000
```

```act
behaviour bite-full of Cat
interface bite(bytes32 ilk, address urn)

for all

    Vat     : address VatLike
    Vow     : address VowLike
    Flipper : address Flipper
    Live    : uint256
    Art_i   : uint256
    Rate_i  : uint256
    Spot_i  : uint256
    Line_i  : uint256
    Dust_i  : uint256
    Ink_iu  : uint256
    Art_iu  : uint256
    Gem_iv  : uint256
    Sin_w   : uint256
    Vice    : uint256
    Sin     : uint256
    Sin_era : uint256
    Chop    : uint256
    Lump    : uint256
    Kicks   : uint256
    Ttl     : uint48
    Tau     : uint48
    Bid     : uint256
    Lot     : uint256
    Guy     : address
    Tic     : uint48
    End     : uint48
    Gal     : address
    Tab     : uint256
    Usr     : address

storage

    vat            |-> Vat
    vow            |-> Vow
    live           |-> Live
    ilks[ilk].flip |-> Flipper
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump

storage Vat
    ilks[ilk].Art      |-> Art_i => Art_i - Art_iu
    ilks[ilk].rate     |-> Rate_i
    ilks[ilk].spot     |-> Spot_i
    ilks[ilk].line     |-> Line_i
    ilks[ilk].dust     |-> Dust_i

    wards[ACCT_ID]     |-> CatMayVat
    urns[ilk][urn].ink |-> Ink_iu => 0
    urns[ilk][urn].art |-> Art_iu => 0
    gem[ilk][Flipper]  |-> Gem_iv => Gem_iv + Ink_iu
    sin[Vow]           |-> Sin_w  => Sin_w  + (Rate_i * Art_iu)
    vice               |-> Vice   => Vice   + (Rate_i * Art_iu)

storage Vow

    wards[ACCT_ID]     |-> CatMayVow
    sin[TIME]          |-> Sin_era => Sin_era + Rate_i * Art_iu
    Sin                |-> Sin     => Sin     + Rate_i * Art_iu

storage Flipper

    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid => 0
    bids[1 + Kicks].lot         |-> Lot => Ink_iu
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic, TIME + Tau)
    bids[1 + Kicks].usr         |-> Usr => urn
    bids[1 + Kicks].gal         |-> Gal => Vow
    bids[1 + Kicks].tab         |-> Tab => (Chop * (Rate_i * Art_iu)) / #Ray


iff

    VCallValue == 0
    VCallDepth < 1023
    CatMayVat == 1
    CatMayVow == 1
    Live == 1
    Ink_iu * Spot_i < Art_iu * Rate_i
    Art_iu <= posMinSInt256
    Ink_iu <= posMinSInt256
    Ink_iu =/= 0

iff in range int256

    Rate_i
    Rate_i * Art_iu

iff in range uint256

    Art_i  - Art_iu
    Gem_iv + Ink_iu
    Sin_w   + Rate_i * Art_iu
    Vice    + Rate_i * Art_iu
    Sin_era + Rate_i * Art_iu
    Sin     + Rate_i * Art_iu
    Chop * (Rate_i * Art_iu)
    Lump * Art_iu
    Ink_iu * Art_iu

if

    Ink_iu < Lump


returns 1 + Kicks

calls

  Cat.muluu
  Cat.minuu
  Vat.grab
  Vat.ilks
  Vat.urns
  Vow.fess
  Flipper.kick
```

```act
behaviour bite-lump of Cat
interface bite(bytes32 ilk, address urn)

for all

    Vat     : address VatLike
    Vow     : address VowLike
    Flipper : address Flipper
    Live    : uint256
    Art_i   : uint256
    Rate_i  : uint256
    Spot_i  : uint256
    Line_i  : uint256
    Dust_i  : uint256
    Ink_iu  : uint256
    Art_iu  : uint256
    Gem_iv  : uint256
    Sin_w   : uint256
    Vice    : uint256
    Sin     : uint256
    Sin_era : uint256
    Chop    : uint256
    Lump    : uint256
    Kicks   : uint256
    Ttl     : uint48
    Tau     : uint48
    Bid     : uint256
    Lot     : uint256
    Guy     : address
    Tic     : uint48
    End     : uint48
    Gal     : address
    Tab     : uint256
    Usr     : address

storage

    vat            |-> Vat
    vow            |-> Vow
    live           |-> Live
    ilks[ilk].flip |-> Flipper
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump

storage Vat

    ilks[ilk].Art      |-> Art_i  => Art_i - ((Lump * Art_iu) / Ink_iu)
    ilks[ilk].rate     |-> Rate_i
    ilks[ilk].spot     |-> Spot_i
    ilks[ilk].line     |-> Line_i
    ilks[ilk].dust     |-> Dust_i

    wards[ACCT_ID]     |-> CatMayVat
    urns[ilk][urn].ink |-> Ink_iu => Ink_iu - Lump
    urns[ilk][urn].art |-> Art_iu => Art_iu - ((Lump * Art_iu) / Ink_iu)
    gem[ilk][Flipper]  |-> Gem_iv => Gem_iv + Lump
    sin[Vow]           |-> Sin_w  => Sin_w  + Rate_i * ((Lump * Art_iu) / Ink_iu)
    vice               |-> Vice   => Vice   + Rate_i * ((Lump * Art_iu) / Ink_iu)

storage Vow

    wards[ACCT_ID]     |-> CatMayVow
    sin[TIME]          |-> Sin_era => Sin_era + Rate_i * ((Lump * Art_iu) / Ink_iu)
    Sin                |-> Sin     => Sin     + Rate_i * ((Lump * Art_iu) / Ink_iu)

storage Flipper

    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid => 0
    bids[1 + Kicks].lot         |-> Lot => Lump
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic, TIME + Tau)
    bids[1 + Kicks].usr         |-> Usr => urn
    bids[1 + Kicks].gal         |-> Gal => Vow
    bids[1 + Kicks].tab         |-> Tab => (Chop * (Rate_i * ((Lump * Art_iu) / Ink_iu)) / #Ray)


iff

    VCallValue == 0
    VCallDepth < 1023
    CatMayVat == 1
    CatMayVow == 1
    Live == 1
    Ink_iu * Spot_i < Art_iu * Rate_i
    (Lump * Art_iu) / Ink_iu <= posMinSInt256
    Lump <= posMinSInt256
    Ink_iu =/= 0

iff in range int256

    Rate_i
    Rate_i * ((Lump * Art_iu) / Ink_iu)

iff in range uint256

    Rate_i * Art_iu
    Lump * Art_iu
    Ink_iu * Art_iu
    Art_i - ((Lump * Art_iu) / Ink_iu)
    Ink_iu - Lump
    Art_iu - ((Lump * Art_iu) / Ink_iu)
    Gem_iv + Lump
    Sin_w   + Rate_i * ((Lump * Art_iu) / Ink_iu)
    Vice    + Rate_i * ((Lump * Art_iu) / Ink_iu)
    Sin_era + Rate_i * ((Lump * Art_iu) / Ink_iu)
    Sin     + Rate_i * ((Lump * Art_iu) / Ink_iu)
    Chop * (Rate_i * ((Lump * Art_iu) / Ink_iu))

if

    Ink_iu >= Lump

returns 1 + Kicks

calls

  Cat.muluu
  Cat.minuu
  Vat.grab
  Vat.ilks
  Vat.urns
  Vow.fess
  Flipper.kick
```

```act
behaviour cage of Cat
interface cage()

for all
  Ward : uint256
  Live : uint256

storage
  wards[CALLER_ID] |-> Ward
  live |-> Live => 0

iff
  Ward == 1
  VCallValue == 0
```

## Flip: liquidation auction

```act
behaviour wards of Flipper
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

#### bid data

```act
behaviour bids of Flipper
interface bids(uint256 n)

for all

    Bid : uint256
    Lot : uint256
    Guy : address
    Tic : uint48
    End : uint48
    Usr : address
    Gal : address
    Tab : uint256

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End)
    bids[n].usr         |-> Usr
    bids[n].gal         |-> Gal
    bids[n].tab         |-> Tab

iff

    VCallValue == 0

returns Bid : Lot : Guy : Tic : End : Usr : Gal : Tab
```

#### cdp engine

```act
behaviour vat of Flipper
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### collateral type

```act
behaviour ilk of Flipper
interface ilk()

for all

    Ilk : uint256

storage

    ilk |-> Ilk

iff

    VCallValue == 0

returns Ilk
```

#### minimum bid increment

```act
behaviour beg of Flipper
interface beg()

for all

    Beg : uint256

storage

    beg |-> Beg

iff

    VCallValue == 0

returns Beg
```

#### auction time-to-live

```act
behaviour ttl of Flipper
interface ttl()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Ttl
```

#### maximum auction duration

```act
behaviour tau of Flipper
interface tau()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Tau
```

#### kick counter

```act
behaviour kicks of Flipper
interface kicks()

for all

    Kicks : uint256

storage

    kicks |-> Kicks

iff

    VCallValue == 0

returns Kicks
```

### Mutators

#### Auth

Any owner can add and remove owners.

```act
behaviour rely-diff of Flipper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Flipper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Flipper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Flipper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### Auction parameters

```act
behaviour file of Flipper
interface file(bytes32 what, uint256 data)

for all

    May : uint256
    Beg : uint256
    Ttl : uint48
    Tau : uint48

storage

    wards[CALLER_ID] |-> May
    beg |-> Beg => (#if what == #string2Word("beg") #then data #else Beg #fi)
    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau) => (#if what == #string2Word("ttl") #then #WordPackUInt48UInt48(data, Tau) #else (#if what == #string2Word("tau") #then #WordPackUInt48UInt48(Ttl, data) #else #WordPackUInt48UInt48(Ttl, Tau) #fi) #fi)

iff

    May == 1
    VCallValue == 0

if

    (what =/= #string2Word("ttl") and what =/= #string2Word("tau")) or #rangeUInt(48, data)
```

```act
behaviour addu48u48 of Flipper
interface add(uint48 x, uint48 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint48

    x + y

if

    #sizeWordStack(WS) <= 100
```

```act
behaviour muluu of Flipper
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

```act
behaviour kick of Flipper
interface kick(address usr, address gal, uint256 tab, uint256 lot, uint256 bid)

for all

    Vat      : address VatLike
    Ilk      : uint256
    Kicks    : uint256
    Ttl      : uint48
    Tau      : uint48
    Bid      : uint256
    Lot      : uint256
    Guy      : address
    Tic      : uint48
    End      : uint48
    Usr      : address
    Gal      : address
    Tab      : uint256
    CanFlux  : uint256
    Gem_v    : uint256
    Gem_c    : uint256

storage

    vat                         |-> Vat
    ilk                         |-> Ilk
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid => bid
    bids[1 + Kicks].lot         |-> Lot => lot
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, Tic, TIME + Tau)
    bids[1 + Kicks].usr         |-> Usr => usr
    bids[1 + Kicks].gal         |-> Gal => gal
    bids[1 + Kicks].tab         |-> Tab => tab

storage Vat

    can[CALLER_ID][ACCT_ID] |-> CanFlux
    gem[Ilk][CALLER_ID]     |-> Gem_v => Gem_v - lot
    gem[Ilk][ACCT_ID]       |-> Gem_c => Gem_c + lot

iff

    CanFlux == 1
    VCallDepth < 1024
    VCallValue == 0

iff in range uint256

    Kicks + 1
    Gem_v - lot
    Gem_c + lot

iff in range uint48

    TIME + Tau

if

    CALLER_ID =/= ACCT_ID
    #rangeUInt(48, TIME)

calls

  Flipper.addu48u48
  Vat.flux-diff

returns 1 + Kicks
```

```act
behaviour tick of Flipper
interface tick(uint256 id)

for all
  Tau : uint48
  Ttl : uint48
  Guy : address
  Tic : uint48
  End : uint48

storage
  ttl_tau              |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(Guy, Tic, TIME + Tau)

iff
  End < TIME
  Tic == 0
  VCallValue == 0

iff in range uint48
  TIME + Tau

if
  #rangeUInt(48, TIME)

calls
  Flipper.addu48u48
```

note: currently failing due to timeout

```act
behaviour tend of Flipper
interface tend(uint256 id, uint256 lot, uint256 bid)

for all
  Vat : address VatLike
  Beg : uint256
  Bid : uint256
  Lot : uint256
  Tab : uint256
  Gal : address
  Ttl : uint48
  Tau : uint48
  Guy : address
  Tic : uint48
  End : uint48
  Can   : uint256
  Dai_c : uint256
  Dai_u : uint256
  Dai_g : uint256

storage
  vat          |-> Vat
  beg          |-> Beg
  ttl_tau      |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].bid |-> Bid => bid
  bids[id].lot |-> Lot => lot
  bids[id].tab |-> Tab
  bids[id].gal |-> Gal
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, TIME + Ttl, End)

storage Vat
  can[CALLER_ID][ACCT_ID] |-> Can
  dai[CALLER_ID] |-> Dai_c => Dai_c - bid
  dai[Guy]       |-> Dai_u => Dai_u + Bid
  dai[Gal]       |-> Dai_g => Dai_g + (bid - Bid)

iff
  VCallValue == 0
  VCallDepth < 1024
  Guy =/= 0
  Can == 1
  Tic > TIME or Tic == 0
  End > TIME
  TIME + Ttl <= maxUInt48
  lot == Lot
  bid >  Bid
  bid <= Dai_c
  Dai_u + Bid <= maxUInt256
  Dai_g + (bid - Bid) <= maxUInt256
  bid * #Ray <= maxUInt256
  ((bid < Tab) and (bid * #Ray >= Beg * Bid)) or ((bid == Tab) and (Beg * Bid <= maxUInt256))

if
  CALLER_ID =/= ACCT_ID
  CALLER_ID =/= Guy
  CALLER_ID =/= Gal
  Guy =/= Gal

calls
  Flipper.muluu
  Vat.move-diff
```

note: currently failing due to timeout

```act
behaviour dent of Flipper
interface dent(uint256 id, uint256 lot, uint256 bid)

for all
  Vat : address VatLike
  Ilk : bytes32
  Ttl : uint48
  Tau : uint48
  Beg : uint256
  Bid : uint256
  Lot : uint256
  Guy : address
  Tic : uint48
  End : uint48
  Gal : address
  Usr : address
  Tab : uint256
  Dai_c : uint256
  Dai_g : uint256
  Gem_a : uint256
  Gem_u : uint256

storage
  vat          |-> Vat
  ilk          |-> Ilk
  beg          |-> Beg
  ttl_tau      |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].bid |-> Bid
  bids[id].lot |-> Lot => lot
  bids[id].tab |-> Tab
  bids[id].usr |-> Usr
  bids[id].gal |-> Gal
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, TIME + Ttl, End)

storage Vat
  can[CALLER_ID][ACCT_ID] |-> Can
  can[ACCT_ID][ACCT_ID]   |-> _
  dai[CALLER_ID]    |-> Dai_c => Dai_c - bid
  dai[Guy]          |-> Dai_g => Dai_g + bid
  gem[Ilk][ACCT_ID] |-> Gem_a => Gem_a - (Lot - lot)
  gem[Ilk][Usr]     |-> Gem_u => Gem_u + (Lot - lot)

iff
  VCallValue == 0
  VCallDepth < 1024
  Guy =/= 0
  Can == 1
  Tic > TIME or Tic == 0
  End > TIME
  TIME + Ttl <= maxUInt48
  bid == Bid
  bid == Tab
  lot <  Lot
  Gem_u + (Lot - lot) <= maxUInt256
  Gem_a >= (Lot - lot)
  bid <= Dai_c
  Dai_g + bid <= maxUInt256
  Lot * #Ray >= lot * Beg
  Lot * #Ray <= maxUInt256

if
  #rangeUInt(48, TIME)
  CALLER_ID =/= ACCT_ID
  CALLER_ID =/= Guy
  ACCT_ID   =/= Usr

calls
  Flipper.muluu
  Vat.move-diff
  Vat.flux-diff
```

```act
behaviour deal of Flipper
interface deal(uint256 id)

for all
  Vat : address VatLike
  Ilk : bytes32
  Bid : uint256
  Lot : uint256
  Guy : address
  Tic : uint48
  End : uint48
  Tab : uint256
  Gem_a : uint256
  Gem_u : uint256
  Old_gal : address
  Old_usr : address

storage
  vat                  |-> Vat
  ilk                  |-> Ilk
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].usr         |-> Old_usr => 0
  bids[id].gal         |-> Old_gal => 0
  bids[id].tab         |-> Tab => 0

storage Vat
  can[ACCT_ID][ACCT_ID] |-> _
  gem[Ilk][ACCT_ID] |-> Gem_a => Gem_a - Lot
  gem[Ilk][Guy]     |-> Gem_u => Gem_u + Lot

iff
  Tic =/= 0
  Tic < TIME or End < TIME
  VCallValue == 0
  VCallDepth < 1024

if
  ACCT_ID =/= Guy

iff in range uint256
  Gem_a - Lot
  Gem_u + Lot

calls
  Vat.flux-diff
```

```act
behaviour yank of Flipper
interface yank(uint256 id)

for all
  Vat : address VatLike
  Ttl : uint48
  Tau : uint48
  Ilk : bytes32
  Bid : uint256
  Lot : uint256
  Guy : address
  Tic : uint48
  End : uint48
  Usr : address
  Gal : address
  Tab : uint256
  Dai_c : uint256
  Dai_g : uint256
  Gem_a : uint256
  Gem_c : uint256

storage
  wards[CALLER_ID]     |-> May
  vat                  |-> Vat
  ilk                  |-> Ilk
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].tab         |-> Tab => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].usr         |-> Usr => 0
  bids[id].gal         |-> Gal => 0

storage Vat
  can[CALLER_ID][ACCT_ID] |-> Can
  can[ACCT_ID][ACCT_ID]   |-> _
  gem[Ilk][ACCT_ID]   |-> Gem_a => Gem_a - Lot
  gem[Ilk][CALLER_ID] |-> Gem_c => Gem_c + Lot
  dai[CALLER_ID]      |-> Dai_c => Dai_c - Bid
  dai[Guy]            |-> Dai_g => Dai_g + Bid

iff
  May == 1
  Guy =/= 0
  Can == 1
  Bid < Tab
  VCallValue == 0
  VCallDepth < 1024

if
  CALLER_ID =/= ACCT_ID
  CALLER_ID =/= Guy

iff in range uint256
  Gem_a - Lot
  Gem_c + Lot
  Dai_c - Bid
  Dai_g + Bid

calls
  Vat.flux-diff
  Vat.move-diff
```

# GemJoin

The `GemJoin` adapter allows standard ERC20 tokens to be deposited for use with the system.

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of GemJoin
interface vat()

for all

    Vat : address VatLike

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### the associated `ilk`

```act
behaviour ilk of GemJoin
interface ilk()

for all

    Ilk : bytes32

storage

    ilk |-> Ilk

iff

    VCallValue == 0

returns Ilk
```

#### gem address

```act
behaviour gem of GemJoin
interface gem()

for all

    Gem : address

storage

    gem |-> Gem

iff

    VCallValue == 0

returns Gem
```

### Mutators

#### depositing into the system

```act
behaviour join of GemJoin
interface join(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    DSToken     : address DSToken
    May         : uint256
    Vat_bal     : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256
    Owner       : address
    Stopped     : bool
    Allowed     : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> DSToken

storage Vat

    wards[ACCT_ID]      |-> May
    gem[Ilk][usr]       |-> Vat_bal => Vat_bal + wad

storage DSToken

    allowance[CALLER_ID][ACCT_ID] |-> Allowed => #if Allowed == maxUInt256 #then Allowed #else Allowed - wad #fi
    balances[CALLER_ID] |-> Bal_usr     => Bal_usr     - wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad
    owner_stopped       |-> #WordPackAddrUInt8(Owner, Stopped)

iff

    VCallDepth < 1024
    VCallValue == 0
    wad <= Allowed
    Stopped == 0
    May == 1
    wad <= maxSInt256

iff in range uint256

    Vat_bal + wad
    Bal_usr     - wad
    Bal_adapter + wad

if

    CALLER_ID =/= ACCT_ID

calls

  Vat.slip
  DSToken.transferFrom
```

#### withdrawing from the system

```act
behaviour exit of GemJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    DSToken     : address DSToken
    May         : uint256
    Wad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256
    Owner       : address
    Stopped     : bool

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> DSToken

storage Vat

    wards[ACCT_ID]      |-> May
    gem[Ilk][CALLER_ID] |-> Wad => Wad - wad

storage DSToken

    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad
    balances[usr]       |-> Bal_usr     => Bal_usr     + wad
    owner_stopped       |-> #WordPackAddrUInt8(Owner, Stopped)

iff

    VCallValue == 0
    VCallDepth < 1024
    Stopped == 0
    May == 1
    wad <= posMinSInt256

iff in range uint256

    Wad         - wad
    Bal_adapter - wad
    Bal_usr     + wad

if

    ACCT_ID =/= usr

calls
  Vat.slip
  DSToken.transfer
```

# DaiJoin

The `DaiJoin` adapter allows users to withdraw their dai from the system into a standard ERC20 token.

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of DaiJoin
interface vat()

for all

    Vat : address VatLike

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### dai address

```act
behaviour dai of DaiJoin
interface dai()

for all

    Dai : address

storage

    dai |-> Dai

iff

    VCallValue == 0

returns Dai
```

### Mutators

#### depositing into the system

```act
behaviour muluu of DaiJoin
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

```act
behaviour join of DaiJoin
interface join(address usr, uint256 wad)

for all

    Vat     : address VatLike
    Dai     : address Dai
    Supply  : uint256
    Dai_c   : uint256
    Dai_a   : uint256
    Dai_u   : uint256
    Allowed : uint256
    Can     : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    can[ACCT_ID][ACCT_ID] |-> Can
    dai[ACCT_ID] |-> Dai_a => Dai_a - (#Ray * wad)
    dai[usr]     |-> Dai_u => Dai_u + (#Ray * wad)

storage Dai

    balanceOf[CALLER_ID]          |-> Dai_c   => Dai_c - wad
    totalSupply                   |-> Supply  => Supply - wad
    allowance[CALLER_ID][ACCT_ID] |-> Allowed => #if Allowed == maxUInt256 #then Allowed #else Allowed - wad #fi

iff

    VCallValue == 0
    VCallDepth < 1024
    (Allowed == maxUInt256) or (wad <= Allowed)

iff in range uint256

    #Ray * wad
    Dai_a - #Ray * wad
    Dai_u + #Ray * wad
    Dai_c - wad
    Supply - wad

if

    ACCT_ID =/= CALLER_ID
    ACCT_ID =/= usr

calls

    DaiJoin.muluu
    Vat.move-diff
    Dai.burn
```

#### withdrawing from the system

```act
behaviour exit of DaiJoin
interface exit(address usr, uint256 wad)

for all

    Vat    : address VatLike
    Dai    : address Dai
    May    : uint256
    Can    : uint256
    Dai_c  : uint256
    Dai_u  : uint256
    Dai_a  : uint256
    Supply : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    can[CALLER_ID][ACCT_ID] |-> Can
    dai[CALLER_ID] |-> Dai_c => Dai_c - #Ray * wad
    dai[ACCT_ID]   |-> Dai_a => Dai_a + #Ray * wad

storage Dai

    wards[ACCT_ID] |-> May
    balanceOf[usr] |-> Dai_u  => Dai_u  + wad
    totalSupply    |-> Supply => Supply + wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range uint256

    #Ray * wad
    Dai_c - #Ray * wad
    Dai_a + #Ray * wad
    Dai_u + wad
    Supply + wad

if

    CALLER_ID =/= ACCT_ID

calls

    DaiJoin.muluu
    Vat.move-diff
    Dai.mint
```

# Flapper

The `Flapper` is an auction contract that receives `dai` tokens and starts an auction, accepts bids of `gem` (with `tend`), and after completion settles with the winner.

## Specification of behaviours

### Accessors

#### Auth

```act
behaviour wards of Flapper
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```



#### bid data

```act
behaviour bids of Flapper
interface bids(uint256 n)

for all

    Bid : uint256
    Lot : uint256
    Guy : address
    Tic : uint48
    End : uint48
    Gal : address

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End)
    bids[n].gal         |-> Gal

iff

  VCallValue == 0

returns Bid : Lot : Guy : Tic : End : Gal
```

#### CDP Engine

```act
behaviour vat of Flapper
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### MKR Token

```act
behaviour gem of Flapper
interface gem()

for all

    Gem : address

storage

    gem |-> Gem

iff

    VCallValue == 0

returns Gem
```

#### minimum bid increment

```act
behaviour beg of Flapper
interface beg()

for all

    Beg : uint256

storage

    beg |-> Beg

iff

    VCallValue == 0

returns Beg
```

#### auction time-to-live

```act
behaviour ttl of Flapper
interface ttl()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Ttl
```

#### maximum auction duration

```act
behaviour tau of Flapper
interface tau()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Tau
```

#### kick counter

```act
behaviour kicks of Flapper
interface kicks()

for all

    Kicks : uint256

storage

    kicks |-> Kicks

iff

    VCallValue == 0

returns Kicks
```

#### liveness flag

```act
behaviour live of Flapper
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

### Mutators

#### Auth

Any owner can add and remove owners.

```act
behaviour rely-diff of Flapper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Flapper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Flapper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Flapper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

#### Auction parameters

```act
behaviour file of Flapper
interface file(bytes32 what, uint256 data)

for all

    May : uint256
    Beg : uint256
    Ttl : uint48
    Tau : uint48

storage

    wards[CALLER_ID] |-> May
    beg |-> Beg => (#if what == #string2Word("beg") #then data #else Beg #fi)
    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau) => (#if what == #string2Word("ttl") #then #WordPackUInt48UInt48(data, Tau) #else (#if what == #string2Word("tau") #then #WordPackUInt48UInt48(Ttl, data) #else #WordPackUInt48UInt48(Ttl, Tau) #fi) #fi)

iff

    May == 1
    VCallValue == 0

if

    (what =/= #string2Word("ttl") and what =/= #string2Word("tau")) or #rangeUInt(48, data)
```

#### starting an auction

```act
behaviour addu48u48 of Flapper
interface add(uint48 x, uint48 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint48

    x + y

if

    #sizeWordStack(WS) <= 100
```

```act
behaviour muluu of Flapper
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

```act
behaviour kick of Flapper
interface kick(address gal, uint256 lot, uint256 bid)

for all

    Vat      : address VatLike
    Kicks    : uint256
    Ttl      : uint48
    Tau      : uint48
    Bid      : uint256
    Lot      : uint256
    Old_guy  : address
    Old_tic  : uint48
    Old_end  : uint48
    Old_gal  : address
    CanMove  : uint256
    Dai_v    : uint256
    Dai_c    : uint256
    Live     : uint256

storage

    vat                         |-> Vat
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid => bid
    bids[1 + Kicks].lot         |-> Lot => lot
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Old_guy, Old_tic, Old_end) => #WordPackAddrUInt48UInt48(CALLER_ID, Old_tic, TIME + Tau)
    bids[1 + Kicks].gal         |-> Old_gal => gal
    live                        |-> Live

storage Vat

    can[CALLER_ID][ACCT_ID] |-> CanMove
    dai[ACCT_ID]   |-> Dai_v => Dai_v + lot
    dai[CALLER_ID] |-> Dai_c => Dai_c - lot

iff

    Live == 1
    CanMove == 1
    VCallValue == 0
    VCallDepth < 1024

iff in range uint256

    Kicks + 1
    Dai_v + lot
    Dai_c - lot

iff in range uint48

    TIME + Tau

if

    CALLER_ID =/= ACCT_ID
    #rangeUInt(48, TIME)

returns 1 + Kicks

calls

    Vat.move-diff
    Flapper.addu48u48
```

#### Bidding on an auction (tend phase)

note: currently failing due to timeout

```act
behaviour tend of Flapper
interface tend(uint256 id, uint256 lot, uint256 bid)

for all

    DSToken  : address DSToken
    Live     : uint256
    Ttl      : uint48
    Tau      : uint48
    Beg      : uint256
    Bid      : uint256
    Lot      : uint256
    Guy      : address
    Tic      : uint48
    End      : uint48
    Gal      : address
    Can      : uint256
    Bal_usr  : uint256
    Bal_gal  : uint256
    Bal_caller : uint256
    Owner      : address
    Stopped    : bool
    Allowed    : uint256

storage

    gem                  |-> DSToken
    ttl_tau              |-> #WordPackUInt48UInt48(Ttl, Tau)
    bids[id].bid         |-> Bid => bid
    bids[id].lot         |-> Lot
    bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, TIME + Ttl, End)
    bids[id].gal         |-> Gal
    live                 |-> Live
    beg                  |-> Beg

storage DSToken

    balances[CALLER_ID] |-> Bal_caller  => Bal_caller - bid
    balances[Guy]       |-> Bal_usr => Bal_usr + Bid
    balances[Gal]       |-> Bal_gal => Bal_gal + (bid - Bid)
    allowance[CALLER_ID][ACCT_ID] |-> Allowed => #if (Allowed == maxUInt256) #then Allowed #else Allowed - bid #fi
    owner_stopped       |-> #WordPackAddrUInt8(Owner, Stopped)

iff
    VCallValue == 0
    VCallDepth < 1024
    Guy =/= 0
    Stopped == 0
    Live    == 1
    Tic > TIME or Tic == 0
    End > TIME
    Lot == lot
    TIME + Ttl <= maxUInt48
    Bal_usr + Bid <= maxUInt256
    Bal_gal + (bid - Bid) <= maxUInt256
    bid > Bid
    (Allowed == maxUInt256) or (bid <= Allowed)
    bid <= Bal_caller
    bid * #Ray >= Bid * Beg
    bid * #Ray <= maxUInt256

if
    #rangeUInt(48, TIME)
    CALLER_ID =/= ACCT_ID
    CALLER_ID =/= Guy
    CALLER_ID =/= Gal
    Gal =/= Guy

calls
    DSToken.move
    Flapper.muluu
    Flapper.addu48u48
```

```act
behaviour deal of Flapper
interface deal(uint256 id)

for all
  Vat   : address VatLike
  Live  : uint256
  Bid   : uint256
  Lot   : uint256
  Guy   : address
  Tic   : uint48
  End   : uint48
  Gal   : address
  Dai_a : uint256
  Dai_g : uint256

storage
  vat                  |-> Vat
  live                 |-> Live
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].gal         |-> Gal => 0

storage Vat
  can[ACCT_ID][ACCT_ID] |-> _
  dai[ACCT_ID] |-> Dai_a => Dai_a - Lot
  dai[Guy]     |-> Dai_g => Dai_g + Lot

iff
  Live == 1
  (Tic < TIME and Tic =/= 0) or (End < TIME)
  VCallValue == 0
  VCallDepth < 1024

if
  ACCT_ID =/= Guy

iff in range uint256
  Dai_a - Lot
  Dai_g + Lot

calls
  Vat.move-diff
```

```act
behaviour cage of Flapper
interface cage(uint256 rad)

for all
  Vat   : address VatLike
  Ward  : uint256
  Live  : uint256
  Dai_a : uint256
  Dai_u : uint256

storage
  wards[CALLER_ID] |-> Ward
  vat              |-> Vat
  live             |-> Live => 0

iff
  Ward == 1
  VCallDepth < 1024
  VCallValue == 0

if
  CALLER_ID =/= ACCT_ID

storage Vat
  can[ACCT_ID][ACCT_ID] |-> _
  dai[ACCT_ID]   |-> Dai_a => Dai_a - rad
  dai[CALLER_ID] |-> Dai_u => Dai_u + rad

iff in range uint256
  Dai_a - rad
  Dai_u + rad

calls
  Vat.move-diff
```

```act
behaviour yank of Flapper
interface yank(uint256 id)

for all
  Live    : uint256
  DSToken : address DSToken
  Bid     : uint256
  Lot     : uint256
  Guy     : address
  Tic     : uint48
  End     : uint48
  Gal     : address
  Gem_a   : uint256
  Gem_g   : uint256
  Stopped : bool
  Owner   : address

storage
  live |-> Live
  gem  |-> DSToken
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].gal         |-> Gal => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0

storage DSToken
  balances[ACCT_ID] |-> Gem_a => Gem_a - Bid
  balances[Guy]     |-> Gem_g => Gem_g + Bid
  owner_stopped     |-> #WordPackAddrUInt8(Owner, Stopped)

iff
  Live == 0
  Guy =/= 0
  Stopped == 0
  VCallDepth < 1024
  VCallValue == 0

iff in range uint256
  Gem_a - Bid
  Gem_g + Bid

calls
  DSToken.move

if
  ACCT_ID =/= Guy
```

# Flopper

The `Flopper` is an auction contract.

## Specification of behaviours

### Accessors

#### Auth

```act
behaviour wards of Flopper
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```



#### bid data

```act
behaviour bids of Flopper
interface bids(uint256 n)

for all

    Bid : uint256
    Lot : uint256
    Guy : address
    Tic : uint48
    End : uint48

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End)

iff

    VCallValue == 0

returns Bid : Lot : Guy : Tic : End
```

#### CDP Engine

```act
behaviour vat of Flopper
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

#### MKR Token

```act
behaviour gem of Flopper
interface gem()

for all

    Gem : address

storage

    gem |-> Gem

iff

    VCallValue == 0

returns Gem
```

#### minimum bid increment

```act
behaviour beg of Flopper
interface beg()

for all

    Beg : uint256

storage

    beg |-> Beg

iff

    VCallValue == 0

returns Beg
```

#### auction time-to-live

```act
behaviour ttl of Flopper
interface ttl()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Ttl
```

#### maximum auction duration

```act
behaviour tau of Flopper
interface tau()

for all

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

iff

    VCallValue == 0

returns Tau
```

#### kick counter

```act
behaviour kicks of Flopper
interface kicks()

for all

    Kicks : uint256

storage

    kicks |-> Kicks

iff

    VCallValue == 0

returns Kicks
```

#### liveness flag

```act
behaviour live of Flopper
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

### Mutators

#### Auth

Any owner can add and remove owners.

```act
behaviour rely-diff of Flopper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of Flopper
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Flopper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of Flopper
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

```act
behaviour addu48u48 of Flopper
interface add(uint48 x, uint48 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint48

    x + y

if

    #sizeWordStack(WS) <= 100
```

```act
behaviour muluu of Flopper
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

#### Auction parameters

```act
behaviour file of Flopper
interface file(bytes32 what, uint256 data)

for all

    May : uint256
    Beg : uint256
    Ttl : uint48
    Tau : uint48

storage

    wards[CALLER_ID] |-> May
    beg |-> Beg => (#if what == #string2Word("beg") #then data #else Beg #fi)
    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau) => (#if what == #string2Word("ttl") #then #WordPackUInt48UInt48(data, Tau) #else (#if what == #string2Word("tau") #then #WordPackUInt48UInt48(Ttl, data) #else #WordPackUInt48UInt48(Ttl, Tau) #fi) #fi)

iff

    May == 1
    VCallValue == 0

if

    (what =/= #string2Word("ttl") and what =/= #string2Word("tau")) or #rangeUInt(48, data)
```

#### starting an auction

```act
behaviour kick of Flopper
interface kick(address gal, uint256 lot, uint256 bid)

for all
  Live     : uint256
  Kicks    : uint256
  Ttl      : uint48
  Tau      : uint48
  Old_lot  : uint256
  Old_bid  : uint256
  Old_guy  : address
  Old_tic  : uint48
  Old_end  : uint48
  Ward     : uint256

storage
  wards[CALLER_ID]            |-> Ward
  live                        |-> Live
  kicks                       |-> Kicks => 1 + Kicks
  ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[1 + Kicks].bid         |-> Old_bid => bid
  bids[1 + Kicks].lot         |-> Old_lot => lot
  bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Old_guy, Old_tic, Old_end) => #WordPackAddrUInt48UInt48(gal, Old_tic, TIME + Tau)

iff
  Ward == 1
  Live == 1
  VCallValue == 0

iff in range uint256
  Kicks + 1

iff in range uint48
  TIME + Tau

if
  #rangeUInt(48, TIME)

returns 1 + Kicks

calls
  Flapper.addu48u48
```

```act
behaviour dent of Flopper
interface dent(uint id, uint lot, uint bid)

for all
  Live : uint256
  Vat  : address VatLike
  Beg  : uint256
  Ttl  : uint48
  Tau  : uint48
  Bid  : uint256
  Lot  : uint256
  Guy  : address
  Tic  : uint48
  End  : uint48
  CanMove : uint256
  Dai_a   : uint256
  Dai_g   : uint256

storage
  live |-> Live
  vat  |-> Vat
  beg  |-> Beg
  ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].bid         |-> Bid
  bids[id].lot         |-> Lot => lot
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, TIME + Ttl, End)

storage Vat
  can[CALLER_ID][ACCT_ID] |-> CanMove
  dai[CALLER_ID] |-> Dai_a => Dai_a - bid
  dai[Guy]       |-> Dai_g => Dai_g + bid

iff
  Live == 1
  Guy =/= 0
  Tic > TIME or Tic == 0
  End > TIME
  bid == Bid
  lot <  Lot
  (Beg * lot) / #Ray <= Lot
  CanMove == 1
  VCallValue == 0
  VCallDepth < 1024

iff in range uint256
  Dai_a - bid
  Dai_g + bid
  Beg * lot

iff in range uint48
  TIME + Ttl

if
  CALLER_ID =/= ACCT_ID
  CALLER_ID =/= Guy
  #rangeUInt(48, TIME)

calls
  Flopper.muluu
  Flopper.addu48u48
  Vat.move-diff
```

```act
behaviour deal of Flopper
interface deal(uint256 id)

for all
  Live    : uint256
  Bid     : uint256
  Lot     : uint256
  Guy     : address
  Tic     : uint48
  End     : uint48
  DSToken : address DSToken
  Gem_g   : uint256
  Stopped : bool
  Supply  : uint256
  Owner   : address

storage
  gem  |-> DSToken
  live |-> Live
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0

storage DSToken
  balances[Guy] |-> Gem_g  => Gem_g  + Lot
  supply        |-> Supply => Supply + Lot
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

iff
  Live == 1
  Tic < TIME or End < TIME
  Tic =/= 0  or End < TIME
  Stopped == 0
  VCallValue == 0
  VCallDepth < 1024

iff in range uint256
  Gem_g  + Lot
  Supply + Lot

if
  Owner == ACCT_ID

calls
  DSToken.mint
```

```act
behaviour cage of Flopper
interface cage()

for all
  Ward : uint256
  Live : uint256

storage
  wards[CALLER_ID] |-> Ward
  live |-> Live => 0

iff
  Ward == 1
  VCallValue == 0
```

```act
behaviour yank of Flopper
interface yank(uint256 id)

for all
  Live   : uint256
  Vat    : address VatLike
  Bid    : uint256
  Lot    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48
  Dai_a  : uint256
  Dai_g  : uint256

storage
  live |-> Live
  vat  |-> Vat
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0

storage Vat
  can[ACCT_ID][ACCT_ID] |-> _
  dai[ACCT_ID] |-> Dai_a => Dai_a - Bid
  dai[Guy]     |-> Dai_g => Dai_g + Bid

iff
  Live == 0
  Guy =/= 0
  VCallDepth < 1024
  VCallValue == 0

if
  ACCT_ID =/= Guy

iff in range uint256
  Dai_a - Bid
  Dai_g + Bid

calls
  Vat.move-diff
```

# End

The `End` coordinates the process of Global Settlement. It has many specs.

### Authorisation

Any owner can add and remove owners.

```act
behaviour rely-diff of End
interface rely(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour rely-same of End
interface rely(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of End
interface deny(address usr)

for all

    May   : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> _ => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID =/= usr
```

```act
behaviour deny-same of End
interface deny(address usr)

for all

    May : uint256

storage

    wards[CALLER_ID] |-> May => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

if

    CALLER_ID == usr
```

### Math Lemmas

```act
behaviour adduu of End
interface add(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x + y : WS

iff in range uint256

    x + y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```

```act
behaviour subuu of End
interface sub(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x - y : WS

iff in range uint256

    x - y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 100
```


```act
behaviour muluu of End
interface mul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : x * y : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

```act
behaviour minuu of End
interface min(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : #if x <= y #then x #else y #fi : WS

if

    #sizeWordStack(WS) <= 1000
```

```act
behaviour rmul of End
interface rmul(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : (x * y) / #Ray : WS

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

```act
behaviour rdiv of End
interface rdiv(uint256 x, uint256 y) internal

stack

    y : x : JMPTO : WS => JMPTO : (x * #Ray) / y : WS

iff

    y =/= 0

iff in range uint256

    x * #Ray

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```


### Accessors

```act
behaviour wards of End
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

iff

    VCallValue == 0

returns May
```

```act
behaviour vat of End
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

iff

    VCallValue == 0

returns Vat
```

```act
behaviour cat of End
interface cat()

for all

    Cat : address

storage

    cat |-> Cat

iff

    VCallValue == 0

returns Cat
```

#### `vow` address

```act
behaviour vow of End
interface vow()

for all

    Vow : address

storage

    vow |-> Vow

iff

    VCallValue == 0

returns Vow
```


#### `spot` address

```act
behaviour spot of End
interface spot()

for all

    Spot : address

storage

    spot |-> Spot

iff

    VCallValue == 0

returns Spot
```

#### liveness

```act
behaviour live of End
interface live()

for all

    Live : uint256

storage

    live |-> Live

iff

    VCallValue == 0

returns Live
```

### Setting `End` parameters

```act
behaviour file-wait of End
interface file(bytes32 what, uint256 data)

for all

    May  : uint256
    Wait : uint256

storage

    wards[CALLER_ID] |-> May
    wait |-> Wait => (#if what == #string2Word("wait") #then data #else Wait #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

```act
behaviour file-addr of End
interface file(bytes32 what, address data)

for all

    May  : uint256
    Vat  : address
    Cat  : address
    Vow  : address
    Spot : address

storage

    wards[CALLER_ID] |-> May
    vat  |-> Vat  => (#if what == #string2Word("vat")  #then data #else Vat #fi)
    cat  |-> Cat  => (#if what == #string2Word("cat")  #then data #else Cat #fi)
    vow  |-> Vow  => (#if what == #string2Word("vow")  #then data #else Vow #fi)
    spot |-> Spot => (#if what == #string2Word("spot") #then data #else Spot #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0
```

### Time of cage

```act
behaviour when of End
interface when()

for all

    When : uint256

storage

    when |-> When

iff

    VCallValue == 0

returns When
```

### Processing period

```act
behaviour wait of End
interface wait()

for all

    Wait : uint256

storage

    wait |-> Wait

iff

    VCallValue == 0

returns Wait
```

### Total Outstanding Debt

```act
behaviour debt of End
interface debt()

for all

    Debt : uint256

storage

    debt |-> Debt

iff

    VCallValue == 0

returns Debt
```

### Ilk Data

```act
behaviour tag of End
interface tag(bytes32 ilk)

for all

    Ray : uint256

storage

    tag[ilk] |-> Ray

iff

    VCallValue == 0

returns Ray
```

```act
behaviour gap of End
interface gap(bytes32 ilk)

for all

    Wad : uint256

storage

    gap[ilk] |-> Wad

iff

    VCallValue == 0

returns Wad
```

```act
behaviour Art of End
interface Art(bytes32 ilk)

for all

    Wad : uint256

storage

    Art[ilk] |-> Wad

iff

    VCallValue == 0

returns Wad
```

```act
behaviour fix of End
interface fix(bytes32 ilk)

for all

    Ray : uint256

storage

    fix[ilk] |-> Ray

iff

    VCallValue == 0

returns Ray
```

```act
behaviour bag of End
interface bag(address usr)

for all

    Wad : uint256

storage

    bag[usr] |-> Wad

iff

    VCallValue == 0

returns Wad
```

```act
behaviour out of End
interface out(bytes32 ilk, address usr)

for all

    Wad : uint256

storage

    out[ilk][usr] |-> Wad

iff

    VCallValue == 0

returns Wad
```

## Behaviours

```act
behaviour cage-surplus of End
interface cage()

for all

    Vat : address VatLike
    Cat : address Cat
    Vow : address VowLike
    Flapper : address Flapper
    Flopper : address Flopper
    FlapVat : address

    Live : uint256
    When : uint256

    VatLive  : uint256
    CatLive  : uint256
    VowLive  : uint256
    FlapLive : uint256
    FlopLive : uint256

    CallerMay : uint256
    EndMayVat : uint256
    EndMayCat : uint256
    EndMayVow : uint256
    VowMayFlap : uint256
    VowMayFlop : uint256

    Dai_f : uint256
    Awe   : uint256
    Joy   : uint256
    Sin   : uint256
    Ash   : uint256

storage

    live |-> Live => 0
    when |-> When => TIME
    vat |-> Vat
    cat |-> Cat
    vow |-> Vow
    wards[CALLER_ID] |-> CallerMay

storage Vat

    can[Flapper][Flapper] |-> _
    live |-> VatLive => 0
    wards[ACCT_ID] |-> EndMayVat
    dai[Flapper]   |-> Dai_f => 0
    sin[Vow]       |-> Awe   => 0
    dai[Vow]       |-> Joy   => (Joy + Dai_f) - Awe

storage Cat

    live |-> CatLive => 0
    wards[ACCT_ID] |-> EndMayCat

storage Vow

    live |-> VowLive => 0
    wards[ACCT_ID] |-> EndMayVow
    flapper |-> Flapper
    flopper |-> Flopper
    Sin |-> Sin => 0
    Ash |-> Ash => 0

storage Flapper

    wards[Vow] |-> VowMayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[Vow] |-> VowMayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1022
    Live == 1
    CallerMay == 1
    EndMayVat == 1
    EndMayCat == 1
    EndMayVow == 1
    VowMayFlap == 1
    VowMayFlop == 1

if
    Joy + Dai_f > Awe
    FlapVat == Vat

calls

  Vat.cage
  Cat.cage
  Vow.cage-surplus
```

```act
behaviour cage-deficit of End
interface cage()

for all

    Vat : address VatLike
    Cat : address Cat
    Vow : address VowLike
    Flapper : address Flapper
    Flopper : address Flopper
    FlapVat : address

    Live : uint256
    When : uint256

    VatLive  : uint256
    CatLive  : uint256
    VowLive  : uint256
    FlapLive : uint256
    FlopLive : uint256

    CallerMay : uint256
    EndMayVat : uint256
    EndMayCat : uint256
    EndMayVow : uint256
    VowMayFlap : uint256
    VowMayFlop : uint256

    Dai_f : uint256
    Awe   : uint256
    Joy   : uint256
    Sin   : uint256
    Ash   : uint256

storage

    live |-> Live => 0
    when |-> When => TIME
    vat |-> Vat
    cat |-> Cat
    vow |-> Vow
    wards[CALLER_ID] |-> CallerMay

storage Vat

    live |-> VatLive => 0
    wards[ACCT_ID] |-> EndMayVat
    dai[Flap] |-> Dai_f => 0
    sin[Vow]  |-> Awe   => (Awe - Joy) - Dai_f
    dai[Vow]  |-> Joy   => 0

storage Cat

    live |-> CatLive => 0
    wards[ACCT_ID] |-> EndMayCat

storage Vow

    live |-> VowLive => 0
    wards[ACCT_ID] |-> EndMayVow
    flapper |-> Flapper
    flopper |-> Flopper
    Sin |-> Sin => 0
    Ash |-> Ash => 0

storage Flapper

    wards[Vow] |-> VowMayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[Vow] |-> VowMayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1022
    Live == 1
    CallerMay == 1
    EndMayVat == 1
    EndMayCat == 1
    EndMayVow == 1
    VowMayFlap == 1
    VowMayFlop == 1

if
    Joy + Dai_f < Awe
    FlapVat == Vat

calls

  Vat.cage
  Cat.cage
  Vow.cage-deficit
```

```act
behaviour cage-balance of End
interface cage()

for all

    Vat : address VatLike
    Cat : address Cat
    Vow : address VowLike
    Flapper : address Flapper
    Flopper : address Flopper
    FlapVat : address

    Live : uint256
    When : uint256

    VatLive  : uint256
    CatLive  : uint256
    VowLive  : uint256
    FlapLive : uint256
    FlopLive : uint256

    CallerMay : uint256
    EndMayVat : uint256
    EndMayCat : uint256
    EndMayVow : uint256
    VowMayFlap : uint256
    VowMayFlop : uint256

    Dai_f : uint256
    Awe   : uint256
    Joy   : uint256
    Sin   : uint256
    Ash   : uint256

storage

    live |-> Live => 0
    when |-> When => TIME
    vat |-> Vat
    cat |-> Cat
    vow |-> Vow
    wards[CALLER_ID] |-> CallerMay

storage Vat

    can[Flapper][Flapper] |-> _
    live |-> VatLive => 0
    wards[ACCT_ID] |-> EndMayVat
    dai[Flapper]   |-> Dai_f => 0
    sin[Vow]       |-> Awe   => 0
    dai[Vow]       |-> Joy   => 0

storage Cat

    live |-> CatLive => 0
    wards[ACCT_ID] |-> EndMayCat

storage Vow

    live |-> VowLive => 0
    wards[ACCT_ID] |-> EndMayVow
    flapper |-> Flapper
    flopper |-> Flopper
    Sin |-> Sin => 0
    Ash |-> Ash => 0

storage Flapper

    wards[Vow] |-> VowMayFlap
    vat  |-> FlapVat
    live |-> FlapLive => 0

storage Flopper

    wards[Vow] |-> VowMayFlop
    live |-> FlopLive => 0

iff

    VCallValue == 0
    VCallDepth < 1022
    Live == 1
    CallerMay == 1
    EndMayVat == 1
    EndMayCat == 1
    EndMayVow == 1
    VowMayFlap == 1
    VowMayFlop == 1

if
    Joy + Dai_f == Awe
    FlapVat ==  Vat

calls

  Vat.cage
  Cat.cage
  Vow.cage-balance
```

```act
behaviour cage-ilk of End
interface cage(bytes32 ilk)

for all
  Live    : uint256
  Tag_i   : uint256
  Art_i   : uint256
  Rate_i  : uint256
  Spot_i  : uint256
  Line_i  : uint256
  Dust_i  : uint256
  Mat_i   : uint256
  Vat     : address VatLike
  Spotter : address Spotter
  DSValue : address DSValue
  Price   : uint256
  Owner   : address
  Ok      : bool

storage
  live     |-> Live
  vat      |-> Vat
  spot     |-> Spotter
  Art[ilk] |-> Art_i
  tag[ilk] |-> Tag_i => (#Wad * #Ray) / Price

storage Spotter
  ilks[ilk].pip |-> DSValue
  ilks[ilk].mat |-> Mat_i

storage Vat
  ilks[ilk].Art  |-> Art_i
  ilks[ilk].rate |-> Rate_i
  ilks[ilk].spot |-> Spot_i
  ilks[ilk].line |-> Line_i
  ilks[ilk].dust |-> Dust_i

storage DSValue
  1 |-> #WordPackAddrUInt8(Owner, Ok)
  2 |-> Price

iff
  VCallValue == 0
  VCallDepth < 1024
  Live == 0
  Tag_i == 0
  Ok == 1
  Price =/= 0

iff in range uint256
  #Wad * #Ray

calls
  End.rdiv
  Vat.ilks
  Spotter.ilks
  DSValue.read
```

```act
behaviour skip of End
interface skip(bytes32 ilk, uint256 id)

for all
  Vat        : address VatLike
  Cat        : address Cat
  Vow        : address
  Tag        : uint256
  Art        : uint256
  Flipper    : address Flipper
  Lump       : uint256
  Chop       : uint256
  EndMayYank : uint256
  Bid        : uint256
  Lot        : uint256
  Guy        : address
  Tic        : uint48
  End        : uint48
  Usr        : address
  Gal        : address
  Tab        : uint256
  EndMayVat  : uint256
  Art_i      : uint256
  Rate_i     : uint256
  Spot_i     : uint256
  Line_i     : uint256
  Dust_i     : uint256
  FlipCan    : uint256
  Dai_e      : uint256
  Dai_g      : uint256
  Joy        : uint256
  Debt       : uint256
  Awe        : uint256
  Vice       : uint256
  Gem_a      : uint256
  Gem_f      : uint256
  Ink_iu     : uint256
  Art_iu     : uint256

storage
  vat      |-> Vat
  cat      |-> Cat
  vow      |-> Vow
  tag[ilk] |-> Tag
  Art[ilk] |-> Art => Art + (Tab / Rate_i)

storage Cat
  ilks[ilk].flip |-> Flipper
  ilks[ilk].lump |-> Lump
  ilks[ilk].chop |-> Chop

storage Flipper
  wards[ACCT_ID]       |-> EndMayYank
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].usr         |-> Usr => 0
  bids[id].gal         |-> Gal => 0
  bids[id].tab         |-> Tab => 0

storage Vat
  wards[ACCT_ID] |-> EndMayVat
  ilks[ilk].Art  |-> Art_i
  ilks[ilk].rate |-> Rate_i
  ilks[ilk].spot |-> Spot_i
  ilks[ilk].line |-> Line_i
  ilks[ilk].dust |-> Dust_i

  can[ACCT_ID][Flipper] |-> FlipCan => 1

  dai[ACCT_ID] |-> Dai_e
  dai[Guy] |-> Dai_g => Dai_g + Bid
  dai[Vow] |-> Joy   => (Joy  + Tab)
  debt     |-> Debt  => (Debt + Tab) + Bid
  sin[Vow] |-> Awe   => (Awe  + Bid)
  vice     |-> Vice  => (Vice + Bid)

  gem[ilk][ACCT_ID]  |-> Gem_a
  gem[ilk][Flipper]  |-> Gem_f  => Gem_f  - Lot
  urns[ilk][Urn].ink |-> Ink_iu => Ink_iu + Lot
  urns[ilk][Urn].art |-> Art_iu => Art_iu + (Tab / Rate_i)

iff
  VCallValue == 0
  VCallDepth < 1023
  Tag =/= 0
  EndMayVat == 1
  EndMayYank == 1
  Guy =/= 0
  Bid < Tab
  Lot <= posMinSInt256
  Tab / Rate_i <= posMinSInt256

iff in range uint256
  Joy + Tab
  (Awe  + Tab) + Bid
  (Vice + Tab) + Bid
  (Debt + Tab) + Bid
  Gem_f - Lot
  Gem_a + Lot
  Dai_e + Bid
  Dai_e - Bid
  Dai_g + Bid
  Art    + (Tab / Rate_i)
  Ink_iu + Lot
  Art_iu + (Tab / Rate_i)
  Art_i  + (Tab / Rate_i)

iff in range int256
  Rate_i
  Rate_i * (Tab / Rate_i)

if
  Flipper =/= ACCT_ID
  Flipper =/= Guy
  Guy =/= Vow
  Guy =/= ACCT_ID
  Vow =/= ACCT_ID

calls
  End.adduu
  Vat.ilks
  Vat.suck
  Vat.hope
  Vat.grab
  Cat.ilks
  Flipper.bids
  Flipper.yank
```

```act
behaviour skim of End
interface skim(bytes32 ilk, address urn)

for all
  Vat    : address VatLike
  Vow    : address
  Tag    : uint256
  Gap    : uint256
  Ward   : uint256
  Art_i  : uint256
  Rate_i : uint256
  Spot_i : uint256
  Line_i : uint256
  Dust_i : uint256
  Gem_a  : uint256
  Ink_iu : uint256
  Art_iu : uint256
  Awe    : uint256
  Vice   : uint256

storage
  vat      |-> Vat
  vow      |-> Vow
  tag[ilk] |-> Tag
  gap[ilk] |-> Gap

storage Vat
  wards[ACCT_ID]     |-> Ward
  ilks[ilk].Art      |-> Art_i => Art_i - Art_iu
  ilks[ilk].rate     |-> Rate_i
  ilks[ilk].spot     |-> Spot_i
  ilks[ilk].line     |-> Line_i
  ilks[ilk].dust     |-> Dust_i

  gem[ilk][ACCT_ID]  |-> Gem_a  => Gem_a  + ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray)
  urns[ilk][urn].ink |-> Ink_iu => Ink_iu - ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray)
  urns[ilk][urn].art |-> Art_iu => 0
  sin[Vow]           |-> Awe  => Awe  + (Rate_i * Art_iu)
  vice               |-> Vice => Vice + (Rate_i * Art_iu)

iff
  VCallValue == 0
  VCallDepth < 1024
  Tag =/= 0
  ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray) <= posMinSInt256
  Art_iu <= posMinSInt256
  Ward == 1

iff in range int256
  Rate_i
  Rate_i * Art_iu

iff in range uint256
  Art_i - Art_iu
  ((Rate_i * Art_iu) / #Ray) * Tag
  Gem_a  + ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray)
  Awe  + (Rate_i * Art_iu)
  Vice + (Rate_i * Art_iu)

if
  Ink_iu > ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray)

calls
  End.adduu
  End.subuu
  End.rmul
  End.minuu
  Vat.urns
  Vat.ilks
  Vat.grab
```

```act
behaviour bail of End
interface skim(bytes32 ilk, address urn)

for all
  Vat    : address VatLike
  Vow    : address
  Tag    : uint256
  Gap    : uint256
  Ward   : uint256
  Art_i  : uint256
  Rate_i : uint256
  Spot_i : uint256
  Line_i : uint256
  Dust_i : uint256
  Gem_a  : uint256
  Ink_iu : uint256
  Art_iu : uint256
  Awe    : uint256
  Vice   : uint256

storage
  vat      |-> Vat
  vow      |-> Vow
  tag[ilk] |-> Tag
  gap[ilk] |-> Gap => Gap + (((((Art_iu * Rate_i) / #Ray) * Tag) / #Ray) - Ink_iu)

storage Vat
  wards[ACCT_ID]     |-> Ward
  ilks[ilk].Art      |-> Art_i => Art_i - Art_iu
  ilks[ilk].rate     |-> Rate_i
  ilks[ilk].spot     |-> Spot_i
  ilks[ilk].line     |-> Line_i
  ilks[ilk].dust     |-> Dust_i

  gem[ilk][ACCT_ID]  |-> Gem_a  => Gem_a  + Ink_iu
  urns[ilk][urn].ink |-> Ink_iu => 0
  urns[ilk][urn].art |-> Art_iu => 0
  sin[Vow]           |-> Awe  => Awe  + (Rate_i * Art_iu)
  vice               |-> Vice => Vice + (Rate_i * Art_iu)

iff
  VCallValue == 0
  VCallDepth < 1024
  Tag =/= 0
  Ink_iu <= posMinSInt256
  Art_iu <= posMinSInt256
  Ward == 1

iff in range int256

  Rate_i
  Rate_i * Art_iu

iff in range uint256
  Gap + (((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray) - Ink_iu)
  Art_i - Art_iu
  ((Rate_i * Art_iu) / #Ray) * Tag
  Gem_a + Ink_iu
  Awe  + (Rate_i * Art_iu)
  Vice + (Rate_i * Art_iu)

if

  Ink_iu <= ((((Rate_i * Art_iu) / #Ray) * Tag) / #Ray)

calls
  End.adduu
  End.subuu
  End.rmul
  End.minuu
  Vat.urns
  Vat.ilks
  Vat.grab
```

```act
behaviour thaw of End
interface thaw()

for all
  Vat  : address VatLike
  Vow  : address
  Live : uint256
  Debt : uint256
  When : uint256
  Wait : uint256
  Joy  : uint256
  FinalDebt : uint256

storage
  vat  |-> Vat
  vow  |-> Vow
  live |-> Live
  debt |-> Debt => FinalDebt
  when |-> When
  wait |-> Wait

storage Vat
  dai[Vow] |-> Joy
  debt     |-> FinalDebt

iff
  Live == 0
  Debt == 0
  Joy  == 0
  TIME >= When + Wait
  VCallValue == 0
  VCallDepth < 1024

calls
  End.adduu
  Vat.dai
  Vat.debt
```

```act
behaviour free of End
interface free(bytes32 ilk)

for all
  Vat    : address VatLike
  Vow    : address
  Ward   : uint256
  Live   : uint256
  Ink_iu : uint256
  Art_iu : uint256
  Gem_iu : uint256
  Art_i  : uint256
  Rate_i : uint256
  Sin_w  : uint256
  Vice   : uint256

storage
  live |-> Live
  vow  |-> Vow
  vat  |-> Vat

storage Vat
  wards[ACCT_ID]           |-> Ward
  urns[ilk][CALLER_ID].ink |-> Ink_iu => 0
  urns[ilk][CALLER_ID].art |-> Art_iu
  gem[ilk][CALLER_ID]      |-> Gem_iu => Gem_iu + Ink_iu
  ilks[ilk].Art            |-> Art_i
  ilks[ilk].rate           |-> Rate_i
  sin[Vow]                 |-> Sin_w
  vice                     |-> Vice

iff
  VCallValue == 0
  VCallDepth < 1024
  Live == 0
  Ward == 1
  Art_iu == 0
  Ink_iu <= posMinSInt256

iff in range uint256
  Gem_iu + Ink_iu

iff in range int256
  Rate_i

calls
  Vat.urns
  Vat.grab
```


```act
behaviour flow of End
interface flow(bytes32 ilk)

for all
  Vat    : address VatLike
  Debt   : uint256
  Fix    : uint256
  Gap    : uint256
  Art    : uint256
  Tag    : uint256
  Art_i  : uint256
  Rate_i : uint256
  Spot_i : uint256
  Line_i : uint256
  Dust_i : uint256


storage
  vat      |-> Vat
  debt     |-> Debt
  gap[ilk] |-> Gap
  Art[ilk] |-> Art
  tag[ilk] |-> Tag
  fix[ilk] |-> Fix => (((((((Art * Rate_i) / #Ray) * Tag) / #Ray) - Gap) * #Ray) * #Ray) / Debt

storage Vat
  ilks[ilk].Art  |-> Art_i
  ilks[ilk].rate |-> Rate_i
  ilks[ilk].spot |-> Spot_i
  ilks[ilk].line |-> Line_i
  ilks[ilk].dust |-> Dust_i

iff
  Debt =/= 0
  Fix == 0
  VCallValue == 0
  VCallDepth < 1024

iff in range uint256
  Art * Rate_i
  ((Art * Rate_i) / #Ray) * Tag
  ((((Art * Rate_i) / #Ray) * Tag) / #Ray) - Gap
  (((((Art * Rate_i) / #Ray) * Tag) / #Ray) - Gap) * #Ray
  ((((((Art * Rate_i) / #Ray) * Tag) / #Ray) - Gap) * #Ray) * #Ray

calls
  End.muluu
  End.subuu
  End.rmul
  End.rdiv
  Vat.ilks
```

```act
behaviour pack of End
interface pack(uint256 wad)

for all
  Vat  : address VatLike
  Vow  : address
  Debt : uint256
  Bag  : uint256
  Joy  : uint256
  Dai  : uint256
  Can  : uint256

storage
  vat  |-> Vat
  vow  |-> Vow
  debt |-> Debt
  bag[CALLER_ID] |-> Bag => Bag + wad

storage Vat
  can[CALLER_ID][ACCT_ID] |-> Can
  dai[CALLER_ID]          |-> Dai => Dai - wad * #Ray
  dai[Vow]                |-> Joy => Joy + wad * #Ray

iff
  Debt =/= 0
  Can  == 1
  VCallValue == 0
  VCallDepth < 1024

if
  CALLER_ID =/= Vow
  CALLER_ID =/= ACCT_ID

iff in range uint256
  Bag + wad
  wad * #Ray
  Dai - (wad * #Ray)
  Joy + (wad * #Ray)

calls
  End.muluu
  End.adduu
  Vat.move-diff
```

```act
behaviour cash of End
interface cash(bytes32 ilk, uint wad)

for all
  Vat   : address VatLike
  Fix   : uint256
  Bag   : uint256
  Out   : uint256
  Gem_e : uint256
  Gem_c : uint256

storage
  vat                 |-> Vat
  fix[ilk]            |-> Fix
  bag[CALLER_ID]      |-> Bag
  out[ilk][CALLER_ID] |-> Out => Out + wad

storage Vat
  can[ACCT_ID][ACCT_ID] |-> _
  gem[ilk][ACCT_ID]   |-> Gem_e => Gem_e - #rmul(wad, Fix)
  gem[ilk][CALLER_ID] |-> Gem_c => Gem_c + #rmul(wad, Fix)

iff
  Fix =/= 0
  Out + wad <= Bag
  VCallValue == 0
  VCallDepth < 1024

iff in range uint256
  wad * Fix
  Gem_e - ((wad * Fix) / #Ray)
  Gem_c + ((wad * Fix) / #Ray)

if
  ACCT_ID =/= CALLER_ID

calls
  End.adduu
  End.rmul
  Vat.flux-diff
```


# DSToken

Reference implementation of an ERC20 token, as used by e.g. MKR and Dai v1.

```act
behaviour totalSupply of DSToken
interface totalSupply()

for all
  Supply : uint256

storage
  supply |-> Supply

iff
  VCallValue == 0

returns Supply
```

```act
behaviour balanceOf of DSToken
interface balanceOf(address usr)

for all
  BalanceOf : uint256

storage
  balances[usr] |-> BalanceOf

iff
  VCallValue == 0

returns BalanceOf
```

```act
behaviour allowance of DSToken
interface allowance(address src, address usr)

for all
  Allowance : uint256

storage
  allowance[src][usr] |-> Allowance

iff
  VCallValue == 0

returns Allowance
```

```act
behaviour approve of DSToken
interface approve(address usr, uint256 wad)

for all
  Allowed : uint256
  Stopped : bool
  Owner   : address

storage
  allowance[CALLER_ID][usr] |-> Allowed => wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

iff
  Stopped == 0
  VCallValue == 0

returns 1
```

```act
behaviour transfer of DSToken
interface transfer(address usr, uint256 wad)

for all
  Gem_c : uint256
  Gem_u : uint256
  Owner : address
  Stopped : bool

storage
  balances[CALLER_ID] |-> Gem_c => Gem_c - wad
  balances[usr]       |-> Gem_u => Gem_u + wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

if
  usr =/= CALLER_ID

iff in range uint256
  Gem_c - wad
  Gem_u + wad

iff
  Stopped == 0
  VCallValue == 0

returns 1
```

```act
behaviour transfer-self of DSToken
interface transfer(address usr, uint256 wad)

for all
  Gem_u : uint256
  Owner : address
  Stopped : bool

storage
  balances[usr] |-> Gem_u => Gem_u
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

if
  usr == CALLER_ID

iff
  wad <= Gem_u
  Stopped == 0
  VCallValue == 0

returns 1
```

```act
behaviour transferFrom of DSToken
interface transferFrom(address src, address dst, uint wad)

for all
  Gem_s     : uint256
  Gem_d     : uint256
  Allowance : uint256
  Owner     : address
  Stopped   : bool

storage
  allowance[src][CALLER_ID] |-> Allowance => #if (src == CALLER_ID or Allowance == maxUInt256) #then Allowance #else Allowance - wad #fi
  balances[src] |-> Gem_s => Gem_s - wad
  balances[dst] |-> Gem_d => Gem_d + wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

iff in range uint256
  Gem_s - wad
  Gem_d + wad

iff
  (Allowance == maxUInt256) or (wad <= Allowance)
  VCallValue == 0
  Stopped == 0

if
  src =/= dst
  src =/= CALLER_ID

returns 1
```

```act
behaviour move of DSToken
interface move(address src, address dst, uint wad)

for all
  Gem_s     : uint256
  Gem_d     : uint256
  Allowance : uint256
  Owner     : address
  Stopped   : bool

storage
  allowance[src][CALLER_ID] |-> Allowance => #if (src == CALLER_ID or Allowance == maxUInt256) #then Allowance #else Allowance - wad #fi
  balances[src] |-> Gem_s => Gem_s - wad
  balances[dst] |-> Gem_d => Gem_d + wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

iff in range uint256
  Gem_s - wad
  Gem_d + wad

iff
  (Allowance == maxUInt256) or (wad <= Allowance)
  VCallValue == 0
  Stopped == 0

if
  src =/= dst
  src =/= CALLER_ID
```

```act
behaviour mint of DSToken
interface mint(address dst, uint wad)

types
  Owner   : address
  Gem_d   : uint256
  Supply  : uint256
  Stopped : bool

storage
  balances[dst] |-> Gem_d  => Gem_d  + wad
  supply        |-> Supply => Supply + wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stopped)

iff in range uint256
  Gem_d + wad
  Supply + wad

iff
  Stopped == 0
  VCallValue == 0

if
  Owner == CALLER_ID
  ACCT_ID =/= CALLER_ID
```

```act
behaviour burn of DSToken
interface burn(address src, uint wad)

types
  Gem_s     : uint256
  Supply    : uint256
  Allowance : uint256
  Stoppedd   : bool
  Owner     : address

storage
  allowance[src][CALLER_ID] |-> Allowance => #if (src == CALLER_ID or Allowance == maxUInt256) #then Allowance #else Allowance - wad #fi
  balances[src]             |-> Gem_s  => Gem_s  - wad
  supply                    |-> Supply => Supply - wad
  owner_stopped |-> #WordPackAddrUInt8(Owner, Stoppedd)

iff in range uint256
  Gem_s  - wad
  Supply - wad

iff
  (Allowance == maxUInt256) or (wad <= Allowance)
  VCallValue == 0
  Stoppedd == 0

if
  CALLER_ID == Owner
  CALLER_ID =/= ACCT_ID
  CALLER_ID =/= src
```

# DSValue

```act
behaviour peek of DSValue
interface peek()

types
  Owner : address
  Value : bytes32
  Ok    : bool

storage
  1 |-> #WordPackAddrUInt8(Owner, Ok)
  2 |-> Value

iff
  VCallValue == 0

returns Value : Ok
```

```act
behaviour read of DSValue
interface read()

types
  Owner : address
  Value : bytes32
  Ok    : bool

storage
  1 |-> #WordPackAddrUInt8(Owner, Ok)
  2 |-> Value

iff
  VCallValue == 0
  Ok == 1

returns Value
```

# Spotter

```act
behaviour ilks of Spotter
interface ilks(bytes32 ilk)

for all
  Pip : address
  Mat : uint256

storage
  ilks[ilk].pip |-> Pip
  ilks[ilk].mat |-> Mat

iff
  VCallValue == 0

returns Pip : Mat
```
