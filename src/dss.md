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
    gem[i][v]         |-> Gem_iv   => Gem_iv  - dart
    dai[w]            |-> Dai_w    => Dai_w + (Ilk_rate * dart)
    debt              |-> Debt     => Debt + (Ilk_rate * dart)
    live              |-> Live

iff in range uint256

    Urn_ink + dink
    Urn_art + dart
    Ilk_Art + dart
    Gem_iv - dink
    Gem_iv - dart
    Dai_w + (Ilk_rate * dart)
    Debt + (Ilk_rate * dart)
    (Urn_art + dart) * Ilk_rate
    (Ilk_Art + dart) * Ilk_rate
    Ilk_Art * Ilk_rate
    Urn_art * Ilk_rate
    Urn_ink * Ilk_spot
    (Urn_ink + ABI_dink) * Ilk_spot

iff in range int256

    Ilk_rate
    Ilk_rate * dart

if

    u =/= v
    v =/= w
    u =/= w

iff

    (Ilk_Art * Ilk_rate <= Ilk_line and Debt <= Line) or (dart <= 0)
    (dart <= 0 and dink >= 0) or (Urn_art * Ilk_rate <= Urn_ink * Ilk_spot)
    (u == CALLER_ID or Can_u == 1) or (dart <= 0 and dink >= 0)
    (v == CALLER_ID or Can_v == 1) or (dink < 0)
    (w == CALLER_ID or Can_w == 1) or (dart > 0)
    (Urn_art * Ilk_rate >= Ilk_dust) or (Urn_art == 0)
    Ilk_rate =/= 0
    Live == 1
    VCallValue == 0

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

iff in range uint256

    Ink_u - dink
    Ink_v + dink
    Art_u - dart
    Art_v + dart
    (Ink_u - dink) * Spot
    (Ink_v + dink) * Spot
    (Art_u - dart) * Rate
    (Art_v + dart) * Rate

iff

    (src == CALLER_ID) or (Can_src == 1)
    (dst == CALLER_ID) or (Can_dst == 1)
    (Art_u - dart) * Rate <= (Ink_u - dink) * Spot
    (Art_v + dart) * Rate <= (Ink_v + dink) * Spot
    ((Art_u - dart) * Rate >= Dust) or (Art_u - dart == 0)
    ((Art_v + dart) * Rate >= Dust) or (Art_v + dart == 0)
    VCallValue == 0

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

iff in range uint256

    Ink_u - dink
    Art_u - dart
    Ink_u * Spot

iff

    (src == CALLER_ID) or (Can_src == 1)
    Art_u * Rate <= Ink_u * Spot
    (Art_u * Rate >= Dust) or (Art_u == 0)
    VCallValue == 0

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

    May   : uint256
    Rate  : uint256
    Dai   : uint256
    Art_i : uint256
    Debt  : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[i].rate     |-> Rate => Rate + rate
    ilks[i].Art      |-> Art_i
    dai[u]           |-> Dai  => Dai  + Art_i * rate
    debt             |-> Debt => Debt + Art_i * rate
    live             |-> Live

iff

    // act: caller is `. ? : not` authorised
    May == 1
    Live == 1
    VCallValue == 0

iff in range uint256

    Rate + rate
    Dai  + Art_i * rate
    Debt + Art_i * rate

iff in range int256

    Art_i
    Art_i * rate

calls

    Vat.addui
    Vat.mului
```
# Dai

The `Dai` contract is the user facing ERC20 contract maintaining the accounting for external Dai balances. Most functions are standard for a token with changing supply, but it also notably features the ability to issue approvals for transferFroms based on signed messages, called `Permit`s.

## Specification of behaviours

### Accessors

<-- TODO: Name, symbol, domain separator (requires dynamic types) -->
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
    #rangeUInt(256, Allowed - wad) or (src == CALLER_ID or Allowed == maxUInt256)
    VCallValue == 0

if
    src =/= dst

returns 1
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
    #rangeUInt(256, Allowed - wad) or (src == CALLER_ID or Allowed == maxUInt256)
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
    #rangeUInt(256, Allowed - wad) or (src == CALLER_ID or Allowed == maxUInt256)
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
    #rangeUInt(256, Allowed - wad) or (src == CALLER_ID or Allowed == maxUInt256)
    VCallValue == 0

if
    src == dst

returns 1
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

    #rangeUInt(256, Allowed - wad) or (src == CALLER_ID or Allowed == maxUInt256)
    VCallValue == 0
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
interface permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s)

types

   Nonce   : uint256
   Allowed : uint256
   Domain_separator : bytes32

storage

    nonces[holder]             |-> Nonce => Nonce + 1
    DOMAIN_SEPARATOR           |-> Domain_separator
    allowance[holder][spender] |-> Allowed => (#if allowed == 1 #then maxUInt256 #else 0 #fi)

iff

    holder == #symEcrec(#padToWidth(32, #asByteStack(keccak(#parseHexWord("0x19") : #parseHexWord("0x1") : #padToWidth(32, #asByteStack(Domain_separator)) ++ #padToWidth(32, #asByteStack(keccak(#encodeArgs(#bytes32(keccak(#parseByteStackRaw("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)"))), #address(holder), #address(spender), #uint256(nonce), #uint256(expiry), #bool(allowed)))))))) ++ #padToWidth(32, #asByteStack(v)) ++ #padToWidth(32, #asByteStack(r)) ++ #padToWidth(32, #asByteStack(s)))
    expiry == 0 or TIME <= expiry
    VCallValue == 0
    nonce == Nonce

iff in range uint256
    Nonce + 1

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

## Rpow

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

This is the coiductive lemma.
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

//  0d63    0da7
pc

    3322 => 3390

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

#### getting the `Awe`

```act
behaviour Awe of Vow
interface Awe()

for all

    Vat : address VatLike
    Sin : uint256

storage

    vat |-> Vat

storage Vat

    sin[ACCT_ID] |-> Sin

iff

    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

returns Sin
```

#### getting the `Joy`

```act
behaviour Joy of Vow
interface Joy()

for all

    Vat : address VatLike
    Dai : uint256

storage

    vat |-> Vat

storage Vat

    dai[ACCT_ID] |-> Dai

iff

    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

returns Dai
```

#### getting the `Woe`

```act
behaviour Woe of Vow
interface Woe()

for all

    Vat  : address VatLike
    Ssin : uint256
    Sin  : uint256
    Ash  : uint256

storage

    vat |-> Vat
    Sin |-> Ssin
    Ash |-> Ash

storage Vat

    sin[ACCT_ID] |-> Sin

iff

    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range uint256

    Sin - Ssin
    (Sin - Ssin) - Ash

returns (Sin - Ssin) - Ash

calls

  Vow.subuu
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
    May  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256
    Siny : uint256
    Ashy : uint256

storage

    vat |-> Vat
    Sin |-> Siny
    Ash |-> Ashy

storage Vat

    wards[ACCT_ID] |-> May
    dai[ACCT_ID]   |-> Dai  => Dai  - rad
    sin[ACCT_ID]   |-> Sin  => Sin  - rad
    vice           |-> Vice => Vice - rad
    debt           |-> Debt => Debt - rad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0
    rad <= Dai
    rad <= Sin - (Ssin - Ashy)

iff in range uint256

    Dai  - rad
    Sin  - rad
    Vice - rad
    Debt - rad

calls

  Vow.subuu
```

```act
behaviour kiss of Vow
interface kiss(uint256 rad)

for all

    Vat  : address VatLike
    Ash  : uint256
    May  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat
    Ash |-> Ash => Ash - wad

storage Vat

    wards[ACCT_ID] |-> May
    dai[ACCT_ID]   |-> Dai  => Dai  - rad
    sin[ACCT_ID]   |-> Sin  => Sin  - rad
    vice           |-> Vice => Vice - rad
    debt           |-> Debt => Debt - rad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0
    rad <= Dai
    rad <= Ash

iff in range uint256

    Ash  - rad
    Dai  - rad
    Sin  - rad
    Vice - rad
    Debt - rad

calls

  Vow.subuu
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

    Flopp    : address Flopper
    Vat      : address VatLike
    Ssin     : uint256
    Ash      : uint256
    Sump     : uint256
    May      : uint256
    Kicks    : uint256
    Vow_was  : address
    Lot_was  : uint256
    Bid_was  : uint256
    Usr_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Ttl      : uint48
    Tau      : uint48
    Dai      : uint256
    Sin_v    : uint256

storage

    flopper |-> Flopp_
    vat     |-> Vat
    Sin     |-> Ssin
    Ash     |-> Ash => Ash + Sump
    sump    |-> Sump

storage Flopp

    wards[ACCT_ID]              |-> May
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].vow         |-> Vow_was => ACCT_ID
    bids[1 + Kicks].bid         |-> Bid_was => Sump
    bids[1 + Kicks].lot         |-> Lot_was => maxUInt256
    bids[1 + Kicks].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)

storage Vat

    dai[ACCT_ID] |-> Dai
    sin[ACCT_ID] |-> Sin_v

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // doc:
    (Sin_v - Ssin) - Ash >= Sump
    // doc: there is at most dust Joy
    Dai == 0
    // act: call stack is not too big
    VCallDepth < 1023
    VCallValue == 0

iff in range uint48

    TIME + Tau

iff in range uint256

    Ash + Sump
    Sin_v - Ssin
    (Sin_v - Ssin) - Ash
    1 + Kicks

if

    #rangeUInt(48, TIME)


returns 1 + Kicks

calls

  Vow.subuu
  Vow.adduu
```

#### starting a surplus auction

```act
behaviour flap of Vow
interface flap()

for all

    Flapp    : address Flapper
    Vat      : address VatLike
    Bump     : uint256
    Hump     : uint256
    Ssin     : uint256
    Ash      : uint256
    Bid_was  : uint256
    Lot_was  : uint256
    Usr_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Gal_was  : address
    Ttl      : uint48
    Tau      : uint48
    Kicks    : uint256
    Can      : uint256
    Dai_v    : uint256
    Sin_v    : uint256
    Dai_c    : uint256
    Flap_live : uint256

storage

    vat     |-> Vat
    flapper |-> Flapp
    bump    |-> Bump
    hump    |-> Hump
    Sin     |-> Ssin
    Ash     |-> Ash

storage Flapp

    #Flapper.vat                         |-> Vat
    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks   => 1 + Kicks
    #Flapper.bids[1 + Kicks].bid         |-> Bid_was => 0
    #Flapper.bids[1 + Kicks].lot         |-> Lot_was => Bump
    #Flapper.bids[1 + Kicks].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    #Flapper.bids[1 + Kicks].gal         |-> Gal_was => 0
    #Flapper.live                        |-> Flap_live

storage Vat

    can[ACCT_ID][Flapp] |-> Can
    dai[ACCT_ID]        |-> Dai_v => Dai_v - Bump
    sin[ACCT_ID]        |-> Sin_v
    dai[Flapp]          |-> Dai_c => Dai_c + Bump

iff

    // doc: there is enough `Joy`
    Dai_v >= (Sin_v + Bump) + Hump
    // doc: there is no `Woe`
    (Sin_v - Ssin) - Ash == 0
    // act: call stack is not too big
    VCallDepth < 1023
    VCallValue == 0
    Can == 1
    Flap_live == 1

iff in range uint48

    TIME + Tau

iff in range uint256

    Sin_v + Bump
    (Sin_v + Bump) + Hump
    Sin_v - Ssin
    (Sin_v - Ssin) - Ash
    1 + Kicks
    Dai_v - Bump
    Dai_c + Bump

if

    #rangeUInt(48, TIME)


returns 1 + Kicks

calls

  Vow.subuu
  Vow.adduu
```

#### system lock down

```act
behaviour cage of Vow
interface cage()

for all

   Vat : address VatLike
   Flapper : address Flapper
   Flopper : address Flopper
   May_flop : uint256
   Dai_v    : uint256
   Sin_v    : uint256
   Dai_f    : uint256

storage


   flop |-> Flopper
   flap |-> Flapper
   live |-> _ => 0
   Sin  |-> _ => 0
   Ash  |-> _ => 0

storage Vat

   dai[Flap]    |-> Dai_f => 0
   dai[ACCT_ID] |-> Dai_v => Dai_v - #if Dai_v > Sin_v #then Dai_v - Sin_v #else 0 #fi + Dai_f
   sin[ACCT_ID] |-> Sin_v => Sin_v - #if Dai_v > Sin_v #then 0 #else Sin_v - Dai_v #fi

storage Flapper

    live |-> _ => 0

storage Flopper

    wards[ACCT_ID] |-> May_flop
    live |-> _ => 0

iff

    VCallValue == 0
    May_flop == 1

iff in range uint256

    Dai_v - #if Dai_v > Sin_v #then Dai_v - Sin_v #else 0 #fi
    Dai_v - #if Dai_v > Sin_v #then Dai_v - Sin_v #else 0 #fi + Dai_f
    Sin_v - #if Dai_v > Sin_v #then 0 #else Sin_v - Dai_v #fi

calls

  Flapper.cage
  Flopper.cage
  Vat.heal
  Vow.subuu
  Vow.adduu
  Vow.minuu
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

TODO: add Vat storage
```
behaviour file-flip of Cat
interface file(bytes32 ilk, bytes32 what, address data)

for all

    May  : uint256
    Flip : address

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].flip   |-> Flip => (#if what == #string2Word("flip") #then data #else Flip #fi)

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
behaviour bite of Cat
interface bite(bytes32 ilk, address urn)

for all

    Vat     : address VatLike
    Vow     : address VowLike
    Flip    : address Flipper
    Live    : uint256
    Rate    : uint256
    Art_i   : uint256
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
    Lot     : uint256
    Art     : uint256
    Ttl     : uint48
    Tau     : uint48

storage

    vat            |-> Vat
    vow            |-> Vow
    live           |-> Live
    ilks[ilk].flip |-> Flip
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump

storage Vat

    wards[ACCT_ID]     |-> CatMayVat
    ilks[ilk].rate     |-> Rate
    urns[ilk][urn].ink |-> Ink_iu => Ink_iu - Lot
    urns[ilk][urn].art |-> Art_iu => Art_iu - Art
    ilks[ilk].Art      |-> Art_i  => Art_i  - Art
    gem[ilk][Flip]     |-> Gem_iv => Gem_iv + Lot
    sin[Vow]           |-> Sin_w  => Sin_w  + Art * Rate
    vice               |-> Vice   => Vice   + Art * Rate

storage Vow

    wards[ACCT_ID]     |-> CatMayVow
    sin[TIME]          |-> Sin_era => Sin_era + Art * Rate
    Sin                |-> Sin     => Sin     + Art * Rate

storage Flip

    #Flipper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flipper.kicks                       |-> Kicks => 1 + Kicks
    #Flipper.bids[1 + Kicks].bid         |-> _ => 0
    #Flipper.bids[1 + Kicks].lot         |-> _ => Lot
    #Flipper.bids[1 + Kicks].usr_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flipper.bids[1 + Kicks].urn         |-> _ => urn
    #Flipper.bids[1 + Kicks].gal         |-> _ => Vow
    #Flipper.bids[1 + Kicks].tab         |-> _ => #rmul(Chop, Art * Rate)

iff

    CatMayVat == 1
    CatMayVow == 1
    Live == 1
    Ink_iu * Spot_i < Art_iu * Rate
    VCallDepth < 1023
    VCallValue == 0
    (Ink_iu >= Lump and Lot == Lump) or (Ink_iu < Lump and Lot == Ink_iu)
    Art == Lot * Art_iu / Ink_iu

iff in range int256

    Art
    Lot

iff in range uint256

    Ink_iu - Lot
    Art_iu - Art
    Art_i  - Art
    Gem_iv + Lot
    Sin_w  + Art * Rate
    Vice   + Art * Rate
    Chop * Art * Rate


returns 1 + Kicks

calls

  Cat.muluu
  Cat.minuu
  Vat.grab
  Vat.ilks
  Vat.urns
  Vow.fess
  Flip.kick
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
    Usr : address
    Tic : uint48
    End : uint48
    Urn : address
    Gal : address
    Tab : uint256

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End)
    bids[n].urn         |-> Urn
    bids[n].gal         |-> Gal
    bids[n].tab         |-> Tab

iff

    VCallValue == 0

returns Bid : Lot : Usr : Tic : End : Urn : Gal : Tab
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
behaviour kick of Flipper
interface kick(address urn, address gal, uint256 tab, uint256 lot, uint256 bid)

for all

    Vat      : address VatLike
    Ilk      : uint256
    Kicks    : uint256
    Ttl      : uint48
    Tau      : uint48
    CanFlux  : uint256
    Gem_v    : uint256
    Gem_c    : uint256

storage

    vat                         |-> Vat
    ilk                         |-> Ilk
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> _ => bid
    bids[1 + Kicks].lot         |-> _ => lot
    bids[1 + Kicks].usr_tic_end |-> _ => #WordPackAddrUInt48UInt48(CALLER_ID, 0, TIME + Tau)
    bids[1 + Kicks].urn         |-> _ => urn
    bids[1 + Kicks].gal         |-> _ => gal
    bids[1 + Kicks].tab         |-> _ => tab

storage Vat

    can[ACCT_ID][CALLER_ID] |-> CanFlux
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

calls

  Flipper.addu48u48
  Vat.flux-diff

returns 1 + Kicks
```

```act
behaviour tick of Flipper
interface tick(uint256 id)

for all
  Usr : address
  Tic : uint48
  End : uint48
  Tau : uint48
  Ttl : uint48

storage
  ttl_tau              |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End) => #WordPackAddrUInt48UInt48(Usr, Tic, End + Tau)

iff
  End < TIME
  Tic == 0
  VCallValue == 0

iff in range uint48
  End + Tau

calls
  Flipper.addu48u48
```

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
  Usr : address
  Tic : uint48
  End : uint48
  Dai_c : uint256
  Dai_u : uint256
  Dai_g : uint256

storage
  vat          |-> Vat
  beg          |-> Beg
  bids[id].bid |-> Bid => bid
  bids[id].lot |-> Lot => lot
  bids[id].tab |-> Tab
  bids[id].gal |-> Gal
  ttl_tau      |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, Tic + Ttl, End)

storage Vat
  dai[CALLER_ID] |-> Dai_c => Dai_c - bid
  dai[Usr]       |-> Dai_u => Dai_u + bid
  dai[Gal]       |-> Dai_g => Dai_g + bid - Bid

iff
  Guy /= 0
  Tic > TIME or Tic == 0
  End > TIME

  lot == Lot
  bid <= Tab
  bid >  Bid
  (bid * #RAY >= beg * Bid) or (bid == Tab)

  CALLER_ID /= Usr
  VCallValue == 0

if in range uint256
  Dai_c - bid
  Dai_u + bid
  Dai_g + bid - Bid
  bid * #RAY
  Beg * Bid

if in range uint48
  Tic + Ttl

calls
  Flipper.muluu
  Vat.move-diff
```

```act
behaviour dent of Flipper
interface dent(uint256 id, uint256 lot, uint256 bid)

for all
  Vat : address VatLike
  Beg : uint256
  Bid : uint256
  Lot : uint256
  Tab : uint256
  Gal : address
  Ttl : uint48
  Tau : uint48
  Usr : address
  Tic : uint48
  End : uint48
  Dai_c : uint256
  Dai_u : uint256
  Dai_g : uint256

storage
  vat          |-> Vat
  ilk          |-> Ilk
  beg          |-> Beg
  bids[id].bid |-> Bid => bid
  bids[id].lot |-> Lot => lot
  bids[id].tab |-> Tab
  bids[id].urn |-> Urn
  bids[id].gal |-> Gal
  ttl_tau      |-> #WordPackUInt48UInt48(Ttl, Tau)
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End) => #WordPackAddrUInt48UInt48(CALLER_ID, Tic + Ttl, End)

storage Vat
  dai[CALLER_ID]    |-> Dai_c => Dai_c - bid
  dai[Usr]          |-> Dai_u => Dai_u + bid
  gem[ilk][ACCT_ID] |-> Dai_a => Dai_a + lot - Lot
  gem[ilk][Urn]     |-> Dai_v => Dai_v + Lot - lot

iff
  Guy /= 0
  Tic > TIME or Tic == 0
  End > TIME

  bid == Bid
  bid == Tab
  lot <  Lot
  Lot * #RAY >= lot * Beg

  CALLER_ID /= Usr
  ACCT_ID   /= Urn
  VCallValue == 0

if in range uint256
  Dai_c - bid
  Dai_u + bid
  Dai_g + bid - Bid
  Lot * #RAY
  lot * Beg

if in range uint48
  Tic + Ttl

calls
  Flipper.muluu
  Vat.move-diff
  Vat.flux-diff
```

```act
behaviour deal of Flipper
interface deal(uint256 id)

storage
  bids[id].bid         |-> _   => 0
  bids[id].lot         |-> Lot => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].urn         |-> _ => 0
  bids[id].gal         |-> _ => 0
  bids[id].tab         |-> _ => 0

storage Vat
  gem[ilk][ACCT_ID] |-> Gem_a => Gem_a - Lot
  gem[ilk][Usr]     |-> Gem_u => Gem_u + Lot

for all
  Lot : uint256
  Guy : address
  Tic : uint48
  End : uint48
  Gem_a : uint256

iff
  Tic /= 0
  Tic < TIME or End < TIME
  ACCT_ID /= Usr
  VCallValue == 0

if in range uint256
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
  Bid : uint256
  Lot : uint256
  Tab : uint256
  Ttl : uint48
  Tau : uint48
  Guy : address
  Tic : uint48
  End : uint48
  Dai_u : uint256
  Dai_g : uint256
  Gem_a : uint256
  Gem_u : uint256

storage
  wards[CALLER_ID]     |-> May
  vat                  |-> Vat
  ilk                  |-> Ilk
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].tab         |-> Tab => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].urn         |-> _ => 0
  bids[id].gal         |-> _ => 0

storage Vat
  gem[Ilk][ACCT_ID]   |-> Gem_a => Gem_a - Lot
  gem[Ilk][CALLER_ID] |-> Gem_u => Gem_u + Lot
  dai[CALLER_ID]      |-> Dai_u => Dai_u - Bid
  dai[Guy]            |-> Dai_g => Dai_g + Bid

iff
  May == 1
  Guy /= 0
  Bid < Tab
  CALLER_ID /= ACCT_ID
  CALLER_ID /= Guy
  VCallValue == 0

if in range uint256
  Gem_a - Lot
  Gem_c + Lot
  Dai_u - Bid
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
interface join(address urn, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address Gemish
    May         : uint256
    Vat_bal     : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> May
    gem[Ilk][CALLER_ID]     |-> Vat_bal => Vat_bal + wad

storage Gem

    balances[CALLER_ID] |-> Bal_usr     => Bal_usr     - wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range int256

    wad

iff in range uint256

    Vat_bal + wad
    Bal_usr     - wad
    Bal_adapter + wad

if

    CALLER_ID =/= ACCT_ID

calls

  Vat.slip
```

#### withdrawing from the system

```act
behaviour exit of GemJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address Gemish
    May         : uint256
    Wad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> May
    gem[Ilk][CALLER_ID]     |-> Wad => Wad - wad

storage Gem

    balances[CALLER_ID] |-> Bal_usr     => Bal_usr     + wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0

iff in range uint256

    Wad         - wad
    Bal_usr     + wad
    Bal_adapter - wad

if

    CALLER_ID =/= ACCT_ID
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
behaviour join of DaiJoin
interface join(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Dai         : address Dai
    Rad         : uint256
    Supply      : uint256
    Bal_caller  : uint256
    Dai_adapter : uint256
    Allowed     : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    dai[usr]     |-> Rad => Rad + #Ray * wad
    dai[ACCT_ID] |-> Dai_adapter => Dai_adapter - #Ray * wad

storage Dai

    balanceOf[CALLER_ID]          |-> Bal_caller => Bal_caller - wad
    totalSupply                   |-> Supply     => Supply - wad
    allowance[ACCT_ID][CALLER_ID] |-> Allowed    => #if Allowed == maxUInt256 #then Allowed #else Allowed - wad #fi

iff

    // act: call stack is not too big
    VCallDepth < 1024
    VCallValue == 0
    #rangeUInt(256, Allowed - wad) or Allowed == maxUInt256

iff in range uint256

    Supply - wad
    #Ray * wad
    Bal_caller - wad
    Rad + #Ray * wad
    Dai_adapter - #Ray * wad

if

    CALLER_ID =/= ACCT_ID
```

#### withdrawing from the system

```act
behaviour exit of DaiJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Dai         : address Dai
    Rad         : uint256
    May         : uint256
    Bal_usr     : uint256
    Dai_adapter : uint256
    Supply      : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat


    dai[CALLER_ID]          |-> Rad => Rad - #Ray * wad
    dai[ACCT_ID]            |-> Dai_adapter => Dai_adapter + #Ray * wad
    can[ACCT_ID][CALLER_ID] |-> Can

storage Dai

    wards[ACCT_ID] |-> May
    balanceOf[usr] |-> Bal_usr => Bal_usr + wad
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
    Rad - #Ray * wad
    Dai_adapter + #Ray * wad
    Bal_usr + wad
    Supply + wad

if

    CALLER_ID =/= ACCT_ID

calls

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
    Usr : address
    Tic : uint48
    End : uint48
    Gal : address

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End)
    bids[n].gal         |-> Gal

iff

    VCallValue == 0

returns Bid : Lot : Usr : Tic : End : Gal
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
behaviour kick of Flapper
interface kick(address gal, uint256 lot, uint256 bid)

for all

    Vat      : address VatLike
    Kicks    : uint256
    Ttl      : uint48
    Tau      : uint48
    CanMove  : uint256
    Dai_v    : uint256
    Dai_c    : uint256
    Live     : uint256

storage

    vat                         |-> Vat
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks => 1 + Kicks
    bids[1 + Kicks].bid         |-> _ => bid
    bids[1 + Kicks].lot         |-> _ => lot
    bids[1 + Kicks].usr_tic_end |-> _ => #WordPackAddrUInt48UInt48(CALLER_ID, 0, TIME + Tau)
    bids[1 + Kicks].gal         |-> _ => gal
    live                        |-> Live

storage Vat

    can[ACCT_ID][CALLER_ID] |-> CanMove
    dai[ACCT_ID]   |-> Dai_v => Dai_v - lot
    dai[CALLER_ID] |-> Dai_c => Dai_c + lot

iff

    Live == 1
    Can == 1
    VCallValue == 0
    VCallDepth < 1024

iff in range uint256

    Kicks + 1
    Dai_v - lot
    Dai_c + lot

iff in range uint48

    TIME + Tau

if

    CALLER_ID =/= ACCT_ID

returns 1 + Kicks

calls

    Vat.move-diff
    Flapper.addu48u48
```

#### Bidding on an auction (tend phase)


```act
behaviour tend of Flapper
interface tend(uint256 id, uint256 lot, uint256 bid)

for all

    Ttl      : uint48
    Tau      : uint48
    Usr_was  : address
    Gal      : address
    Tic_was  : uint48
    End      : uint48
    Gem      : address Gemish
    Can      : uint256
    Beg      : uint256
    Bid_was  : uint256
    Dai_v    : uint256
    Dai_c    : uint256
    Live     : uint256
    Bal_usr  : uint256
    Bal_gal  : uint256
    Bal_caller : uint256

storage

    gem                  |-> Gem
    ttl_tau              |-> #WordPackUInt48UInt48(Ttl, Tau)
    bids[id].bid         |-> Bid_was => bid
    bids[id].lot         |-> Lot
    bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End) => #WordPackAddrUInt48UInt48(CALLER_ID, TIME + Ttl, End)
    bids[id].gal         |-> Gal
    live                 |-> Live
    beg                  |-> Beg

storage Gem

    balances[CALLER_ID] |-> Bal_caller  => Bal_caller - bid
    balances[Usr_was]   |-> Bal_usr => Bal_usr + Bid_was
    balances[Gal]       |-> Bal_gal => Bal_gal + bid - Bid_was
    allowance[ACCT_ID][CALLER_ID] |-> Allowed => #if Allowed == maxUInt256 #then Allowed #else Allowed - bid #fi
    stopped             |-> Stopped
iff

    VCallDepth < 1024
    VCallValue == 0
    Live    == 1
    Usr_was =/= 0
    Tic_was == 0 or Tic_was > TIME
    End > TIME
    Lot == lot
    Bid_was < bid
    Bid_was * Beg <= bid * #Ray
    #rangeUInt(256, Allowed - bid) or Allowed == maxUInt256
    Stopped == 0

iff in range uint256

    Dai_v - lot
    Dai_c + lot
    bid - Bid_was
    Bal_caller  - Bid_was
    Bal_usr + Bid_was
    Bal_gal + bid - Bid_was
    Bal_caller  - bid

iff in range uint48

    TIME + Ttl

if
    ACCT_ID =/= CALLER_ID
    #rangeUInt(48, TIME)
```

```act
behaviour cage of Flapper
interface cage(uint256 rad)

for all
  Vat  : address VatLike
  Auth : uint256

storage
  wards[CALLER_ID] |-> Auth
  vat              |-> Vat
  live             |-> _ => 0

iff
  Auth == 1
  CALLER_ID /= ACCT_ID
  VCallDepth < 1024
  VCallValue == 0

storage Vat
  dai[ACCT_ID]   |-> Dai_a => Dai_a - rad
  dai[CALLER_ID] |-> Dai_u => Dai_u + rad

if in range uint256
  Dai_a - rad
  Dai_u + rad

calls
  Vat.move-diff
```

```act
behaviour yank of Flapper
interface yank(uint256 id)

for all
  Stopped : uint256
  Live    : uint256
  Gem     : address Gemish
  Guy     : address
  Tic     : uint256
  End     : uint256
  Bid     : uint256
  Gem_a   : uint256
  Gem_g   : uint256

storage
  live |-> Live
  gem  |-> Gem
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> _ => 0
  bids[id].gal         |-> _ => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0

storage Gem
  balances[ACCT_ID] |-> Gem_a => Gem_a - Bid
  balances[Guy]     |-> Gem_g => Gem_g + Bid
  stopped           |-> Stopped

iff
  Live == 0
  Guy /= 0
  Stopped == 0
  VCallDepth < 1024
  VCallValue == 0

if in range uint256
  Gem_a - Bid
  Gem_g + Bid
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
    Usr : address
    Tic : uint48
    End : uint48
    Gal : address

storage

    bids[n].bid         |-> Bid
    bids[n].lot         |-> Lot
    bids[n].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr, Tic, End)
    bids[n].gal         |-> Gal

iff

    VCallValue == 0

returns Bid : Lot : Usr : Tic : End : Gal
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



#### starting an auction

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
behaviour cage of Flopper
interface cage()

for all
  Auth : uint256

storage
  wards[CALLER_ID] |-> Auth
  live |-> _ => 0

iff
  Auth == 1
  VCallDepth < 1024
  VCallValue == 0
```

```act
behaviour yank of Flopper
interface yank(uint256 id)

for all
  Live    : uint256
  Vat     : address VatLike
  Guy     : address
  Tic     : uint256
  End     : uint256
  Bid     : uint256
  Dai_a   : uint256
  Dai_g   : uint256

storage
  live |-> Live
  vat  |-> Vat
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> _   => 0
  bids[id].gal |-> _   => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0

storage Vat
  dai[ACCT_ID] |-> Dai_a => Dai_a - Bid
  dai[Guy]     |-> Dai_g => Dai_g + Bid

iff
  Live == 1
  Guy /= 0
  VCallDepth < 1024
  VCallValue == 0

if in range uint256
  Dai_a - Bid
  Dai_g + Bid
```

# End

The `End` coordinates the process of Global Settlement. It has many specs.

```act
behaviour cage of End
interface cage()

for all

    Vat : address VatLike
    Cat : address Cat
    Vow : address VowLike
    Flapper : address Flapper
    Flopper : address Flopper

    Live : uint256

    CallerMay : uint256
    EndMayVat : uint256
    EndMayCat : uint256
    EndMayVow : uint256
    VowMayFlap : uint256
    VowMayFlop : uint256

    FlapDai : uint256
    Awe : uint256
    Joy : uint256

storage

    live |-> Live => 0
    when |-> _ => TIME
    vat |-> Vat
    cat |-> Cat
    vow |-> Vow
    wards[CALLER_ID] |-> CallerMay

storage Vat

    live |-> _ => 0
    wards[ACCT_ID] |-> EndMayVat
    dai[Flap] |-> FlapDai => 0
    sin[Vow]  |-> Awe => #if Joy + FlapDai > Awe #then 0 #else Awe - Joy - FlapDai #fi
    dai[Vow]  |-> Joy => #if Joy + FlapDai > Awe #then Joy + FlapDai - Awe #else 0 #fi

storage Cat

    live |-> _ => 0
    wards[ACCT_ID] |-> EndMayCat

storage Vow

    live |-> _ => 0
    wards[ACCT_ID] |-> EndMayVow
    flapper |-> Flapper
    flopper |-> Flopper
    Sin |-> _ => 0
    Ash |-> _ => 0

storage Flapper

    wards[Vow] |-> VowMayFlap
    live |-> _ => 0

storage Flopper

    wards[Vow] |-> VowMayFlop
    live |-> _ => 0

iff

    Live == 1
    CallerMay == 1
    EndMayVat == 1
    EndMayCat == 1
    EndMayVow == 1
    VowMayFlap == 1
    VowMayFlop == 1
    VCallValue == 0

calls

  Vat.cage
  Cat.cage
  Vow.cage
```
