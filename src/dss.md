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

    #unsigned(y) : x : JMPTO : WS => JMPTO : #unsigned(x * y) : WD

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

    y : x : JMPTO : WS => JMPTO : x * y : WD

iff in range uint256

    x * y

if

    // TODO: strengthen
    #sizeWordStack(WS) <= 1000
```

### Mutators

#### adding and removing owners

Any owner can add and remove owners.

```act
behaviour rely-diff of Vat
interface rely(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 1

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
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 0

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

    addui
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
    Gem_iv - dart
    Dai_w + (Ilk_rate * dart)
    Debt + (Ilk_rate * dart)
    Ilk_rate * dart
    Ilk_Art * Ilk_rate
    Urn_art * Ilk_rate
    Urn_ink * Ilk_spot

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

    addui
    subui
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

if

    src =/= dst

calls

    addui
    subui
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

iff

    (src == CALLER_ID) or (Can_src == 1)
    Art_u * Rate <= Ink_u * Spot
    (Art_u * Rate >= Dust) or (Art_u == 0)

if

    src == dst

calls

    addui
    subui
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

    addui
    subui
```

#### creating/annihilating system debt and surplus

`dai` and `sin` are two sides of the same coin. When the system has surplus `dai`, it can be cancelled with `sin`. Dually, the system can bring `dai` into existence while creating offsetting `sin`.

```act
behaviour heal of Vat
interface heal(address u, address v, int256 rad)

for all

    May   : uint256
    Dai_v : uint256
    Sin_u : uint256
    Debt  : uint256
    Vice  : uint256

storage

    wards[CALLER_ID] |-> May
    dai[v]           |-> Dai_v => Dai_v - rad
    sin[u]           |-> Sin_u => Sin_u - rad
    debt             |-> Debt  => Debt  - rad
    vice             |-> Vice  => Vice  - rad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

iff in range uint256

    Dai_v - rad
    Sin_u - rad
    Debt  - rad
    Vice  - rad

calls

    addui
    subui
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

iff

    // act: caller is `. ? : not` authorised
    May == 1
    VCallValue == 0

iff in range uint256

    Rate + rate
    Dai  + Art_i * rate
    Debt + Art_i * rate

iff in range int256

    Art_i
    Art_i * rate

calls

    addui
    subui
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

storage

    decimals |-> 18

iff

    VCallValue == 0

returns 18
```

```act
behaviour permit_TYPEHASH of Dai
interface permit_TYPEHASH()

storage

    permit_TYPEHASH |-> keccak(#parseBytesRaw("Permit(address holder,address spender,uint256 nonce,uint256 deadline,bool allowed)")

iff

    VCallValue == 0

returns keccak(#parseBytesRaw("Permit(address holder,address spender,uint256 nonce,uint256 deadline,bool allowed)")
```

### Mutators


#### adding and removing owners

Any owner can add and remove owners.

```act
behaviour rely-diff of Dai
interface rely(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 1

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
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 0

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
    #rangeUInt(256, Allowed - wad) or src == CALLER_ID
    VCallValue == 0

if
    src =/= dst

returns 1
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
    #rangeUInt(256, Allowed - wad) or src == CALLER_ID
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

storage

    allowance[src][CALLER_ID] |-> Allowed => (#if src == CALLER_ID #then Allowed #else Allowed - wad #fi)
    balanceOf[src]            |-> DstBal => DstBal - wad
    totalSupply               |-> TotalSupply => TotalSupply - wad

iff in range uint256

    SrcBal - wad
    DstBal + wad

iff

    #rangeUInt(256, Allowed - wad) or src == CALLER_ID
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
interface permit(address holder, address spender, uint256 nonce, uint256 deadline, bool allowed, uint8 v, bytes32 r, bytes32 s)

types

    Nonce : uint256

storage

    nonces[holder]             |-> Nonce => Nonce + 1
    allowance[holder][spender] |-> Allowed => (#if allowed == 1 #then maxUInt256 #else 0 #fi)

iff

    holder == #sender(#unparseByteStack(#padToWidth(32, #asByteStack(keccak(#encodePacked(STUFF))), v,#unparseByteStack(#padToWidth(32, #asByteStack(r))), #unparseByteStack(#padToWidth(32, #asByteStack(s))))))
    deadline == 0 or TIME < deadline
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

returns May
```

#### `ilk` data


```act
behaviour ilks of Jug
interface ilks(bytes32 ilk)

for all

    Vow : bytes32
    Tax : uint256
    Rho : uint48

storage

    ilks[ilk].tax |-> Tax
    ilks[ilk].rho |-> Rho

returns Tax : Rho
```

#### `vat` address

```act
behaviour vat of Jug
interface vat()

for all

    Vat : address

storage

    vat |-> Vat

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

returns Vow
```

#### global interest rate

```act
behaviour repo of Jug
interface repo()

for all

    Repo : uint256

storage

    repo |-> Repo

returns Repo
```


### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Jug
interface rely(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1

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

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Jug
interface deny(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1

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

if

    CALLER_ID == usr
```

#### initialising an `ilk`


```act
behaviour init of Jug
interface init(bytes32 ilk)

for all

    May : uint256
    Tax : uint256
    Rho : uint48

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].tax    |-> Tax => #Ray
    ilks[ilk].rho    |-> Rho => TIME

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: `Tax` is `. ? : not` zero
    Tax == 0

```

#### setting `ilk` data


```act
behaviour file of Jug
interface file(bytes32 ilk, bytes32 what, uint256 data)

for all

    May : uint256
    Tax : uint256

storage

    wards[CALLER_ID] |-> May
    ilks[ilk].tax    |-> Tax => (#if what == #string2Word("tax") #then data #else Tax #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
```

#### setting the base rate

```act
behaviour file-repo of Jug
interface file(bytes32 what, uint256 data)

for all

    May  : uint256
    Repo : uint256

storage

    wards[CALLER_ID] |-> May
    repo             |-> Repo => (#if what == #string2Word("repo") #then data #else Repo #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1

```

#### setting the `vow`

```act
behaviour file-vow of Jug
interface file(bytes32 what, bytes32 data)

for all

    May : uint256
    Vow : bytes32

storage

    wards[CALLER_ID] |-> May
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1

```

#### updating the rates

```act
behaviour drip of Jug
interface drip(bytes32 ilk)

for all

    Vat   : address VatLike
    Repo  : uint256
    Vow   : bytes32
    Tax   : uint256
    Rho   : uint48
    May   : uint256
    Rate  : uint256
    Art_i : uint256
    Dai   : uint256
    Debt  : uint256

storage

    vat           |-> Vat
    vow           |-> Vow
    repo          |-> Repo
    ilks[ilk].tax |-> Tax
    ilks[ilk].rho |-> Rho => TIME

storage Vat

    wards[ACCT_ID] |-> May
    ilks[ilk].rate |-> Rate => Rate + (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    ilks[ilk].Art  |-> Art_i
    dai[Vow]       |-> Dai  => Dai  + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    debt           |-> Debt => Debt + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint256

    Repo + Tax
    TIME - Rho
    #rpow(Repo + Tax, TIME - Rho, #Ray) * #Ray
    #rpow(Repo + Tax, TIME - Rho, #Ray) * Rate
    Rate + (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    Dai  + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    Debt + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)

iff in range int256

    Art_i
    #rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate
    Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
```

# Vow

The `Vow` is the system's fiscal organ, the recipient of both system surplus and system debt. Its function is to cover deficits via [debt auctions](#starting-a-debt-auction) and discharge surpluses via [surplus auctions](#starting-a-surplus-auction).

## Specification of behaviours

### Accessors

#### owners

```act
behaviour wards of Vow
interface wards(address usr)

for all

    May : uint256

storage

    wards[usr] |-> May

returns May
```

#### getting a `sin` packet

```act
behaviour sin of Vow
interface sin(uint48 era)

for all

    Sin_era : uint256

storage

    sin[era] |-> Sin_era

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

returns Sin / #Ray
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

returns Dai / #Ray
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

iff in range uint256

    Sin / #Ray - Ssin
    (Sin / #Ray - Ssin) - Ash

returns (Sin / #Ray - Ssin) - Ash
```

### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Vow
interface rely(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1

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

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Vow
interface deny(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1

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
```

#### setting vat and liquidators

```act
behaviour file-addr of Vow
interface file(bytes32 what, address addr)

for all

    May : uint256
    Cow : address
    Row : address
    Vat : address

storage

    wards[CALLER_ID] |-> May
    cow              |-> Cow => (#if what == #string2Word("flap") #then addr #else Cow #fi)
    row              |-> Row => (#if what == #string2Word("flop") #then addr #else Row #fi)
    vat              |-> Vat => (#if what == #string2Word("vat")  #then addr #else Vat #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
```

#### cancelling bad debt and surplus

```act
behaviour heal of Vow
interface heal(uint256 wad)

for all

    Vat  : address VatLike
    May  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat

storage Vat

    wards[ACCT_ID] |-> May
    dai[ACCT_ID]   |-> Dai  => Dai  - wad * #Ray
    sin[ACCT_ID]   |-> Sin  => Sin  - wad * #Ray
    vice           |-> Vice => Vice - wad * #Ray
    debt           |-> Debt => Debt - wad * #Ray

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint256

    Dai  - wad * #Ray
    Sin  - wad * #Ray
    Vice - wad * #Ray
    Debt - wad * #Ray

iff in range int256

    wad * #Ray
```

```act
behaviour kiss of Vow
interface kiss(uint256 wad)

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
    dai[ACCT_ID]   |-> Dai  => Dai  - wad * #Ray
    sin[ACCT_ID]   |-> Sin  => Sin  - wad * #Ray
    vice           |-> Vice => Vice - wad * #Ray
    debt           |-> Debt => Debt - wad * #Ray

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint256

    Ash  - wad
    Dai  - wad * #Ray
    Sin  - wad * #Ray
    Vice - wad * #Ray
    Debt - wad * #Ray

iff in range int256

    wad * #Ray
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

iff in range uint256

    Sin_era + tab
    Sin     + tab
```

#### processing `sin` queue

```act
behaviour flog of Vow
interface flog(uint48 t)

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

iff in range uint256

    t   + Wait
    Sin - Sin_t
```

#### starting a debt auction

```act
behaviour flop of Vow
interface flop()

for all

    Row     : address Flopper
    Vat     : address VatLike
    Ssin    : uint256
    Ash     : uint256
    Sump    : uint256
    May     : uint256
    Kicks   : uint256
    Vow_was : address
    Lot_was : uint256
    Bid_was : uint256
    Usr_was : address
    Tic_was : uint48
    End_was : uint48
    Ttl     : uint48
    Tau     : uint48
    Dai     : uint256
    Sin_v   : uint256

storage

    row  |-> Row
    vat  |-> Vat
    Sin  |-> Ssin
    Ash  |-> Ash => Ash + Sump
    sump |-> Sump

storage Row

    #Flopper.wards[ACCT_ID]              |-> May
    #Flopper.kicks                       |-> Kicks => 1 + Kicks
    #Flopper.bids[1 + Kicks].vow         |-> Vow_was => ACCT_ID
    #Flopper.bids[1 + Kicks].bid         |-> Bid_was => Sump
    #Flopper.bids[1 + Kicks].lot         |-> Lot_was => maxUInt256
    #Flopper.bids[1 + Kicks].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    #Flopper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)

storage Vat

    dai[ACCT_ID] |-> Dai
    sin[ACCT_ID] |-> Sin_v

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // doc:
    (Sin_v / #Ray - Ssin) - Ash >= Sump
    // doc: there is at most dust Joy
    Dai < #Ray
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint48

    TIME + Tau

iff in range uint256

    Ash + Sump
    Sin_v / #Ray - Ssin
    (Sin_v / #Ray - Ssin) - Ash
    1 + Kicks

returns 1 + Kicks
```

#### starting a surplus auction

```act
behaviour flap of Vow
interface flap()

for all

    Cow      : address Flapper
    Vat      : address VatLike
    Bump     : uint256
    Hump     : uint256
    Ssin     : uint256
    Ash      : uint256
    DaiMove  : address
    Could    : uint256
    Bid_was  : uint256
    Lot_was  : uint256
    Usr_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Gal_was  : address
    Ttl      : uint48
    Tau      : uint48
    Kicks    : uint256
    May_move : uint256
    Dai_v    : uint256
    Sin_v    : uint256
    Dai_c    : uint256

storage

    cow  |-> Cow
    vat  |-> Vat
    bump |-> Bump
    hump |-> Hump
    Sin  |-> Ssin
    Ash  |-> Ash

storage Cow

    #Flapper.dai                         |-> DaiMove
    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks   => 1 + Kicks
    #Flapper.bids[1 + Kicks].bid         |-> Bid_was => 0
    #Flapper.bids[1 + Kicks].lot         |-> Lot_was => Bump
    #Flapper.bids[1 + Kicks].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    #Flapper.bids[1 + Kicks].gal         |-> Gal_was => ACCT_ID

storage Vat

    wards[DaiMove] |-> May_move
    dai[ACCT_ID]   |-> Dai_v => Dai_v - #Ray * Bump
    sin[ACCT_ID]   |-> Sin_v
    dai[Cow]       |-> Dai_c => Dai_c + #Ray * Bump

iff

    // doc: there is enough `Joy`
    Dai_v / #Ray >= (Sin_v + Bump) + Hump
    // doc: there is no `Woe`
    (Sin_v / #Ray - Ssin) - Ash == 0
    // doc: DaiMove is authorised to call Vat
    May_move == 1
    // act: call stack is not too big
    VCallDepth < 1022

iff in range uint48

    TIME + Tau

iff in range uint256

    Sin_v + Bump
    (Sin_v + Bump) + Hump
    Sin_v / #Ray - Ssin
    (Sin_v / #Ray - Ssin) - Ash
    1 + Kicks
    Dai_v - #Ray * Bump
    Dai_c + #Ray * Bump

iff in range int256

     #Ray * Bump

if

    Cow =/= DaiMove
    Cow =/= Vat
    Vat =/= DaiMove

returns 1 + Kicks
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

returns Flip : Chop : Lump
```

#### liquidation data

```act
behaviour flips of Cat
interface flips(uint256 n)

for all

    Ilk : bytes32
    Urn : bytes32
    Ink : uint256
    Tab : uint256

storage

    flips[n].ilk |-> Ilk
    flips[n].urn |-> Urn
    flips[n].ink |-> Ink
    flips[n].tab |-> Tab

returns Ilk : Urn : Ink : Tab
```

#### liquidation counter

```act
behaviour nflip of Cat
interface nflip()

for all

    Nflip : uint256

storage

    nflip |-> Nflip

returns Nflip
```

#### liveness

```act
behaviour live of Cat
interface live()

for all

    Live : uint256

storage

    live |-> Live

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

returns Vat
```

#### `pit` address

```act
behaviour pit of Cat
interface pit()

for all

    Pit : address

storage

    pit |-> Pit

returns Pit
```

#### `vow` address

```act
behaviour vow of Cat
interface vow()

for all

    Vow : address

storage

    vow |-> Vow

returns Vow
```

### Mutators

#### adding and removing owners

```act
behaviour rely-diff of Cat
interface rely(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    May == 1

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

if
    usr == CALLER_ID
```

```act
behaviour deny-diff of Cat
interface deny(address usr)

for all

    May   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> May
    wards[usr]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    May == 1

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

if

    CALLER_ID == usr
```

#### setting contract addresses

```act
behaviour file-addr of Cat
interface file(bytes32 what, address data)

for all

    May : uint256
    Pit : address
    Vow : address

storage

    wards[CALLER_ID] |-> May
    pit              |-> Pit => (#if what == #string2Word("pit") #then data #else Pit #fi)
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    May == 1
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
```

#### setting liquidator address

```act
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
```

#### marking a position for liquidation

```act
behaviour bite of Cat
interface bite(bytes32 ilk, address urn)

for all

    Vat     : address VatLike
    Pit     : address
    Vow     : address VowLike
    Nflip   : uint256
    Ilk_was : uint256
    Urn_was : uint256
    Ink_was : uint256
    Tab_was : uint256
    Take    : uint256
    Rate    : uint256
    Art_i   : uint256
    Ink_iu  : uint256
    Art_iu  : uint256
    Gem_iv  : uint256
    Sin_w   : uint256
    Vice    : uint256
    Sin     : uint256
    Sin_era : uint256
    Live    : uint256

storage

    vat                |-> Vat
    pit                |-> Pit
    vow                |-> Vow
    nflip              |-> Nflip   => Nflip + 1
    flips[Nflip].ilk   |-> Ilk_was => ilk
    flips[Nflip].urn   |-> Urn_was => urn
    flips[Nflip].ink   |-> Ink_was => Ink_iu
    flips[Nflip].tab   |-> Tab_was => Rate * Art_iu
    live               |-> Live

storage Vat

    wards[ACCT_ID]     |-> May
    ilks[ilk].take     |-> Take
    ilks[ilk].rate     |-> Rate
    urns[ilk][urn].ink |-> Ink_iu => 0
    urns[ilk][urn].art |-> Art_iu => 0
    ilks[ilk].Art      |-> Art_i  => Art_i  - Art_iu
    gem[ilk][ACCT_ID]  |-> Gem_iv => Gem_iv + Take * Ink_iu
    sin[Vow]           |-> Sin_w  => Sin_w  - Rate * Art_iu
    vice               |-> Vice   => Vice   - Rate_* Art_iu

storage Vow

    sin[TIME]          |-> Sin_era => Sin_era + Art_iu * Rate
    Sin                |-> Sin     => Sin     + Art_iu * Rate

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: system is  `. ? : not` live
    Live == 1
    // act: CDP is  `. ?  : not` vulnerable
    Ink_iu * Spot_i < Art_iu * Rate
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    Take
    Rate
    Take * (0 - Ink_iu)
    Rate * (0 - Art_iu)

iff in range uint256

    Art_i   - Art_iu
    Sin_w   - Rate   * Art_iu
    Gem_iv  + Take   * Ink_iu
    Vice    - Rate   * Art_iu
    Sin_era + Art_iu * Rate
    Sin     + Art_iu * Rate

returns Nflip + 1
```

#### starting a collateral auction

```act
behaviour flip of Cat
interface flip(uint256 n, uint256 wad)

for all

    Ilk   : bytes32
    Urn   : address
    Ink   : uint256
    Tab   : uint256
    Flip  : address Flipper
    Chop  : uint256
    Lump  : uint256
    Vow   : address
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Live  : uint256

storage

    flips[n].ilk   |-> Ilk
    flips[n].urn   |-> Urn
    flips[n].ink   |-> Ink => Ink - (Ink * wad) / Tab
    flips[n].tab   |-> Tab => Tab - wad
    ilks[ilk].flip |-> Flip
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump
    vow            |-> Vow
    live           |-> Live

storage Flip

    #Flipper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flipper.kicks                       |-> Kicks => 1 + Kicks
    #Flipper.bids[1 + Kicks].bid         |-> _ => 0
    #Flipper.bids[1 + Kicks].lot         |-> _ => (Ink * wad) / Tab
    #Flipper.bids[1 + Kicks].usr_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flipper.bids[1 + Kicks].urn         |-> _ => Urn
    #Flipper.bids[1 + Kicks].gal         |-> _ => Vow
    #Flipper.bids[1 + Kicks].tab         |-> _ => (wad * Chop) /Int 1000000000000000000000000000)

iff

    // act: system is  `. ? : not` live
    Live == 1
    // doc: flipping no more than the available debt
    wad <= Tab
    // doc: flipping the lot size or the remainder
    (wad == Lump) or ((wad < Lump) and (wad == Tab))
    // act: call stack is not too big
    VCallDepth < 1023

iff in range uint256

    Ink * wad
    wad * Chop

returns 1 + Kicks
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

returns Gem
```

### Mutators

#### depositing into the system

```act
behaviour join of GemJoin
interface join(bytes32 urn, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    May         : uint256
    Rad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> May
    gem[Ilk][CALLER_ID]     |-> Rad => Rad + #Ray * wad

storage Gem

    balances[CALLER_ID] |-> Bal_usr     => Bal_usr     - wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_usr     - wad
    Bal_adapter + wad

if

    CALLER_ID =/= ACCT_ID
```

#### withdrawing from the system

```act
behaviour exit of GemJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    May         : uint256
    Rad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> May
    gem[Ilk][CALLER_ID]     |-> Rad => Rad - #Ray * wad

storage Gem

    balances[CALLER_ID] |-> Bal_usr     => Bal_usr     + wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad         - #Ray * wad
    Bal_usr     + wad
    Bal_adapter - wad

if

    CALLER_ID =/= ACCT_ID
```

# ETHJoin

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of ETHJoin
interface vat()

for all

    Vat : address VatLike

storage

    vat |-> Vat

returns Vat
```

#### the associated `ilk`

```act
behaviour ilk of ETHJoin
interface ilk()

for all

    Ilk : bytes32

storage

    ilk |-> Ilk

returns Ilk
```

### Mutators

#### depositing into the system

*TODO* : add `balance ACCT_ID` block

```act
behaviour join of ETHJoin
interface join(bytes32 urn)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    May         : uint256
    Rad         : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk

storage Vat

    wards[ACCT_ID]      |-> May
    gem[Ilk][CALLER_ID] |-> Rad => Rad + #Ray * VALUE

iff

    // act: caller is `. ? : not` authorised
    May == 1

iff in range int256

    #Ray * VALUE

iff in range uint256

    Rad         + #Ray * VALUE
    Bal_adapter + VALUE

if

    CALLER_ID =/= ACCT_ID
```

#### withdrawing from the system

*TODO* : add `balance ACCT_ID` block

```act
behaviour exit of ETHJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Ilk         : bytes32
    May         : uint256
    Rad         : uint256
    Bal_usr     : uint256

storage

    vat             |-> Vat
    ilk             |-> Ilk

storage Vat

    wards[ACCT_ID]      |-> May
    gem[Ilk][CALLER_ID] |-> Rad => Rad - #Ray * wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024
    // act: there is `. ? : not` enough ETH in the adapter
    wad <= BAL

iff in range int256

    #Ray * wad

iff in range uint256

    Rad     - #Ray * wad
    Bal_usr + wad

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

returns Dai
```

### Mutators

#### depositing into the system

```act
behaviour join of DaiJoin
interface join(bytes32 urn, uint256 wad)

for all

    Vat         : address VatLike
    Dai         : address GemLike
    May         : uint256
    Rad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    wards[ACCT_ID] |-> May
    dai[CALLER_ID] |-> Rad => Rad + #Ray * wad

storage Dai

    #Gem.balances[CALLER_ID] |-> Bal_usr     => Bal_usr - wad
    #Gem.balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_usr - wad
    Bal_adapter + wad

if

    CALLER_ID =/= ACCT_ID
```

#### withdrawing from the system

```act
behaviour exit of DaiJoin
interface exit(address usr, uint256 wad)

for all

    Vat         : address VatLike
    Dai         : address GemLike
    May         : uint256
    Rad         : uint256
    Bal_usr     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    wards[ACCT_ID]          |-> May
    gem[Ilk][CALLER_ID]     |-> Rad => Rad - #Ray * wad

storage Dai

    #Gem.balances[CALLER_ID] |-> Bal_usr     => Bal_usr     + wad
    #Gem.balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad

iff

    // act: caller is `. ? : not` authorised
    May == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad         - #Ray * wad
    Bal_usr     + wad
    Bal_adapter - wad

if

    CALLER_ID =/= ACCT_ID
```

# Flapper

The `Flapper` is an auction contract that receives `dai` tokens and starts an auction, accepts bids of `gem` (with `tend`), and after completion settles with the winner.

## Specification of behaviours

### Accessors

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

returns Bid : Lot : #WordPackAddrUInt48UInt48(Usr, Tic, End) : Gal
```

#### sell token

```act
behaviour dai of Flapper
interface dai()

for all

    Dai : address

storage

    dai |-> Dai

returns Dai
```

#### buy token

```act
behaviour gem of Flapper
interface gem()

for all

    Gem : address

storage

    gem |-> Gem

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

returns Kicks
```

### Mutators


#### starting an auction

```act
behaviour kick of Flapper
interface kick(address gal, uint256 lot, uint256 bid)

for all

    Kicks    : uint256
    DaiMove  : address
    Ttl      : uint48
    Tau      : uint48
    Bid_was  : uint256
    Lot_was  : uint256
    Usr_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Gal_was  : address
    Vat      : address VatLike
    May      : uint256
    May_move : uint256
    Dai_v    : uint256
    Dai_c    : uint256

storage

    dai                         |-> DaiMove
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks   => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid_was => bid
    bids[1 + Kicks].lot         |-> Lot_was => lot
    bids[1 + Kicks].usr_tic_end |-> #WordPackAddrUInt48UInt48(Usr_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(CALLER_ID, Tic_was, TIME + Tau)
    bids[1 + Kicks].gal         |-> Gal_was => gal

storage Vat

    wards[DaiMove] |-> May_move
    dai[CALLER_ID] |-> Dai_v => Dai_v - #Ray * lot
    dai[ACCT_ID]   |-> Dai_c => Dai_c + #Ray * lot

iff

    // doc: call stack is not too big
    VCallDepth < 1023
    // doc: Flap is authorised to move for the caller
    May      == 1
    // doc: DaiMove is authorised to call Vat
    May_move == 1

iff in range uint256

    1 + Kicks
    Dai_v - #Ray * lot
    Dai_c + #Ray * lot

iff in range uint48

    TIME + Tau

iff in range int256

    #Ray * lot

if

   CALLER_ID =/= ACCT_ID

returns 1 + Kicks
```
