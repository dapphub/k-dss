What follows is an executable K specification of the smart contracts of multicollateral dai.

# Vat

The `Vat` stores the core dai, CDP, and collateral state, and tracks the system's accounting invariants. The `Vat` is where all dai is created and destroyed.

## Specification of behaviours

### Arithmetic

#### Overflow safe addition
```
behaviour add of Vat
interface add(uint256 x, int256 y) internal

stack

   #unsigned(y) : x : JUMPto : WS => JUMPto : x + y : WS

gas

   VGas => YGas

such that

   VGas - 109 <= YGas
   YGas <= VGas - 80

iff in range uint256

    x + y

if

    VGas > 109
    #sizeWordStack (WS) <= 1018

```
#### Overflow safe subtraction
```
behaviour sub of Vat
interface sub(uint256 x, int256 y) internal

stack

   #unsigned(y) : x : JUMPto : WS => JUMPto : x - y : WS

gas

   VGas => YGas
   
such that
    
   VGas - 109 <= YGas
   YGas <= VGas - 80
    
iff in range uint256

    x - y

if

    VGas > 109
    #sizeWordStack (WS) <= 1018

```
#### Overflow safe multiplication
```
behaviour mul of Vat
interface mul(uint256 x, int256 y) internal

stack

   #unsigned(y) : x : JUMPto : WS => JUMPto : #unsigned(x * y) : WS

gas

   VGas => YGas
   
such that
    
   VGas - 122 <= YGas
   YGas <= VGas - 85
    
iff in range int256

    x * y
    x
if

    VGas > 122
    #sizeWordStack (WS) <= 1016

```


### Accessors

#### owners

The contracts use a multi-owner only-owner authorisation scheme. In the case of the `Vat`, all mutating methods can only be called by owners.

```act
behaviour wards of Vat
interface wards(address guy)

types

    Can : uint256

storage

    wards[guy] |-> Can

if

    VGas > 300000

returns Can
```

#### collateral type data

An `ilk` is a collateral type.

```act
behaviour ilks of Vat
interface ilks(bytes32 ilk)

types

    Take  : uint256
    Rate  : uint256
    Ink_i : uint256
    Art_i : uint256

storage

    ilks[ilk].take |-> Take
    ilks[ilk].rate |-> Rate
    ilks[ilk].Ink  |-> Ink_i
    ilks[ilk].Art  |-> Art_i

if

    VGas > 300000

returns Take : Rate : Ink_i : Art_i
```

#### `urn` data

An `urn` is a collateralised debt position.

```act
behaviour urns of Vat
interface urns(bytes32 ilk, bytes32 urn)

types

    Ink_iu : uint256
    Art_iu : uint256

storage

    urns[ilk][urn].ink |-> Ink_iu
    urns[ilk][urn].art |-> Art_iu

if

    VGas > 300000

returns Ink_iu : Art_iu
```

#### internal unencumbered collateral balances

A `gem` is a token used as collateral in some `ilk`.

```act
behaviour gem of Vat
interface gem(bytes32 ilk, bytes32 urn)

types

    Gem : uint256

storage

    gem[ilk][urn] |-> Gem

if

    VGas > 300000

returns Gem
```

#### internal dai balances

`dai` is a stablecoin.

```act
behaviour dai of Vat
interface dai(bytes32 lad)

types

    Rad : uint256

storage

    dai[lad] |-> Rad

if

    VGas > 300000

returns Rad
```

#### internal sin balances

`sin`, or "system debt", is used to track debt which is no longer assigned to a particular CDP, and is carried by the system during the liquidation process.

```act
behaviour sin of Vat
interface sin(bytes32 lad)

types

    Rad : uint256

storage

    sin[lad] |-> Rad

if

    VGas > 300000

returns Rad
```

#### total debt

```act
behaviour debt of Vat
interface debt()

types

    Debt : uint256

storage

    debt |-> Debt

if

    VGas > 300000

returns Debt
```

#### total bad debt

```act
behaviour vice of Vat
interface vice()

types

    Vice : uint256

storage

    vice |-> Vice

if

    VGas > 300000

returns Vice
```
### Mutators

#### adding and removing owners

Any owner can add and remove owners.

```act
behaviour rely of Vat
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000

behaviour deny of Vat
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### initialising an `ilk`

An `ilk` starts with `Rate` and `Take` set to (fixed-point) one.

```act
behaviour init of Vat
interface init(bytes32 ilk)

types

    Can  : uint256
    Rate : uint256
    Take : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].rate   |-> Rate => 1000000000000000000000000000
    ilks[ilk].take   |-> Take => 1000000000000000000000000000

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: `Rate` is `. ? : not` zero
    Rate == 0
    // act: `Take` is `. ? : not` zero
    Take == 0

if

    VGas > 300000
```

#### assigning unencumbered collateral

Collateral coming from outside of the system must be assigned to a user before it can be locked in a CDP.

```act
behaviour slip of Vat
interface slip(bytes32 ilk, bytes32 guy, int256 wad)

types

    Can : uint256
    Gem : uint256

storage

    wards[CALLER_ID] |-> Can
    gem[ilk][guy]    |-> Gem => Gem + wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Gem + wad

if

    VGas > 300000
    
calls
    
    Vat.add
```

#### moving unencumbered collateral

```act
behaviour flux of Vat
interface flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad)

types

    Can     : uint256
    Gem_src : uint256
    Gem_dst : uint256

storage

    wards[CALLER_ID] |-> Can
    gem[ilk][src]    |-> Gem_src => Gem_src - wad
    gem[ilk][dst]    |-> Gem_dst => Gem_dst + wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Gem_src - wad
    Gem_dst + wad

if

    VGas > 300000

calls
    
    Vat.sub
    Vat.add
```

#### transferring dai balances

```act
behaviour move of Vat
interface move(bytes32 src, bytes32 dst, int256 rad)

types

    Can     : uint256
    Dai_src : uint256
    Dai_dst : uint256

storage

    wards[CALLER_ID] |-> Can
    dai[src]         |-> Dai_src => Dai_src - rad
    dai[dst]         |-> Dai_dst => Dai_dst + rad

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Dai_src - rad
    Dai_dst + rad

if

    VGas > 300000
    
calls
    
    Vat.add
    Vat.sub
```

#### administering a position

This is the core method that opens, manages, and closes a collateralised debt position. This method has the ability to issue or delete dai while increasing or decreasing the position's debt, and to deposit and withdraw "encumbered" collateral from the position. The caller specifies the ilk `i` to interact with, and identifiers `u`, `v`, and `w`, corresponding to the sources of the debt, unencumbered collateral, and dai, respectively. The collateral and debt unit adjustments `dink` and `dart` are specified incrementally.

```act
behaviour tune of Vat
interface tune(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Can    : uint256
    Take   : uint256
    Rate   : uint256
    Ink_iu : uint256
    Art_iu : uint256
    Ink_i  : uint256
    Art_i  : uint256
    Gem_iv : uint256
    Dai_w  : uint256
    Debt   : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[i].take     |-> Take
    ilks[i].rate     |-> Rate
    urns[i][u].ink   |-> Ink_iu => Ink_iu + dink
    urns[i][u].art   |-> Art_iu => Art_iu + dart
    ilks[i].Ink      |-> Ink_i  => Ink_i  + dink
    ilks[i].Art      |-> Art_i  => Art_i  + dart
    gem[i][v]        |-> Gem_iv => Gem_iv - (Take * dink)
    dai[w]           |-> Dai_w  => Dai_w  + (Rate * dart)
    debt             |-> Debt   => Debt   + (Rate * dart)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Ink_iu + dink
    Art_iu + dart
    Ink_i  + dink
    Art_i  + dart
    Gem_iv - (Take * dink)
    Dai_w  + (Rate * dart)
    Debt   + (Rate * dart)

iff in range int256

    Take
    Rate
    Take * dink
    Rate * dart

if

    VGas > 300000
    
calls
    
    Vat.add
    Vat.sub
    Vat.mul
```

#### confiscating a position

When a position of a user `u` is siezed, both the collateral and debt are deleted from the user's account and assigned to the system's balance sheet, with the debt reincarnated as `sin` and assigned to some agent of the system `w`, while collateral goes to `v`.

```act
behaviour grab of Vat
interface grab(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Can    : uint256
    Take   : uint256
    Rate   : uint256
    Ink_iu : uint256
    Art_iu : uint256
    Ink_i  : uint256
    Art_i  : uint256
    Gem_iv : uint256
    Sin_w  : uint256
    Vice   : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[i].take     |-> Take
    ilks[i].rate     |-> Rate
    urns[i][u].ink   |-> Ink_iu => Ink_iu + dink
    urns[i][u].art   |-> Art_iu => Art_iu + dart
    ilks[i].Ink      |-> Ink_i  => Ink_i  + dink
    ilks[i].Art      |-> Art_i  => Art_i  + dart
    gem[i][v]        |-> Gem_iv => Gem_iv - (Take * dink)
    sin[w]           |-> Sin_w  => Sin_w  - (Rate * dart)
    vice             |-> Vice   => Vice   - (Rate * dart)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Ink_iu + dink
    Art_iu + dart
    Ink_i  + dink
    Art_i  + dart
    Gem_iv - (Take * dink)
    Sin_w  - (Rate * dart)
    Vice   - (Rate * dart)

iff in range int256

    Take
    Rate
    Take * dink
    Rate * dart

if

    VGas > 300000

calls
    
    Vat.add
    Vat.sub
```

#### creating/annihilating system debt and surplus

`dai` and `sin` are two sides of the same coin. When the system has surplus `dai`, it can be cancelled with `sin`. Dually, the system can bring `dai` into existence while creating offsetting `sin`.

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

    wards[CALLER_ID] |-> Can
    dai[v]           |-> Dai_v => Dai_v - rad
    sin[u]           |-> Sin_u => Sin_u - rad
    debt             |-> Debt  => Debt  - rad
    vice             |-> Vice  => Vice  - rad

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Dai_v - rad
    Sin_u - rad
    Debt  - rad
    Vice  - rad

if

    VGas > 300000

calls
    
    Vat.sub
```

#### applying interest to an `ilk`

Interest is charged on an `ilk` `i` by adjusting the debt unit `Rate`, which says how many units of `dai` correspond to a unit of `art`. To preserve a key invariant, dai must be created or destroyed, depending on whether `Rate` is increasing or decreasing. The beneficiary/benefactor of the dai is `u`. 

```act
behaviour fold of Vat
interface fold(bytes32 i, bytes32 u, int256 rate)

types

    Can   : uint256
    Rate  : uint256
    Dai   : uint256
    Art_i : uint256
    Debt  : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[i].rate     |-> Rate => Rate + rate
    ilks[i].Art      |-> Art_i
    dai[u]           |-> Dai  => Dai  + Art_i * rate
    debt             |-> Debt => Debt + Art_i * rate

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Rate + rate
    Dai  + Art_i * rate
    Debt + Art_i * rate

iff in range int256

    Art_i
    Art_i * rate

if

    VGas > 300000
    
calls
    
    Vat.add
    Vat.sub
```

#### applying collateral adjustment to an `ilk`


Likewise, the collateral unit `Take` can be adjusted, with collateral going to/from `u`.

```act
behaviour toll of Vat
interface toll(bytes32 i, bytes32 u, int256 take)

types

    Can  : uint256
    Take : uint256
    Ink  : uint256
    Gem  : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[i].take     |-> Take => Take + take
    ilks[i].Ink      |-> Ink
    gem[i][u]        |-> Gem  => Gem  - Ink * take

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Take + take
    Gem  - Ink * take

iff in range int256

    Ink
    Ink * take

if

    VGas > 300000
    
calls
    Vat.add
    Vat.sub
    Vat.mul
```

# Drip

## Specification of behaviours

### Accessors

#### owners


```act
behaviour wards of Drip
interface wards(address guy)

types

    Can : uint256

storage

    wards[guy] |-> Can

if

    VGas > 300000

returns Can
```

#### `ilk` data


```act
behaviour ilks of Drip
interface ilks(bytes32 ilk)

types

    Vow : bytes32
    Tax : uint256
    Rho : uint48

storage

    ilks[ilk].tax |-> Tax
    ilks[ilk].rho |-> Rho

if

    VGas > 300000

returns Tax : Rho
```

#### `vat` address

```act
behaviour vat of Drip
interface vat()

types

    Vat : address

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### `vow` address

```act
behaviour vow of Drip
interface vow()

types

    Vow : address

storage

    vow |-> Vow

if

    VGas > 300000

returns Vow
```

#### global interest rate

```act
behaviour repo of Drip
interface repo()

types

    Repo : uint256

storage

    repo |-> Repo

if

    VGas > 300000

returns Repo
```


### Mutators

#### adding and removing owners

```act
behaviour rely of Drip
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000

behaviour deny of Drip
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### initialising an `ilk`


```act
behaviour init of Drip
interface init(bytes32 ilk)

types

    Can : uint256
    Tax : uint256
    Rho : uint48

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].tax    |-> Tax => #Ray
    ilks[ilk].rho    |-> Rho => TIME

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: `Tax` is `. ? : not` zero
    Tax == 0

if

    VGas > 300000
```

#### setting `ilk` data


```act
behaviour file of Drip
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Can : uint256
    Tax : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].tax    |-> Tax => (#if what == #string2Word("tax") #then data #else Tax #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting the base rate

```act
behaviour file-repo of Drip
interface file(bytes32 what, uint256 data)

types

    Can  : uint256
    Repo : uint256

storage

    wards[CALLER_ID] |-> Can
    repo             |-> Repo => (#if what == #string2Word("repo") #then data #else Repo #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting the `vow`

```act
behaviour file-vow of Drip
interface file(bytes32 what, bytes32 data)

types

    Can : uint256
    Vow : bytes32

storage

    wards[CALLER_ID] |-> Can
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### updating the rates

```act
behaviour drip of Drip
interface drip(bytes32 ilk)

types

    Vat   : address VatLike
    Repo  : uint256
    Vow   : bytes32
    Tax   : uint256
    Rho   : uint48
    Can   : uint256
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

    wards[ACCT_ID] |-> Can
    ilks[ilk].rate |-> Rate => Rate + (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    ilks[ilk].Art  |-> Art_i
    dai[Vow]       |-> Dai  => Dai  + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    debt           |-> Debt => Debt + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)

iff

    // act: caller is `. ? : not` authorised
    Can == 1
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

if

    VGas > 300000
```

# Pit

## Specification of behaviours

### Accessors

#### owners

```act
behaviour wards of Pit
interface wards(address guy)

types

    Can : uint256

storage

    wards[guy] |-> Can

if

    VGas > 300000

returns Can
```


#### `ilk` data

```act
behaviour ilks of Pit
interface ilks(bytes32 ilk)

types

    Spot_i : uint256
    Line_i : uint256

storage

    ilks[ilk].spot |-> Spot_i
    ilks[ilk].line |-> Line_i

if

    VGas > 300000

returns Spot_i : Line_i
```

#### liveness

```act
behaviour live of Pit
interface live()

types

    Live : uint256

storage

    live |-> Live

if

    VGas > 300000

returns Live
```

#### `vat` address

```act
behaviour vat of Pit
interface vat()

types

    Vat : address VatLike

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### global debt ceiling

```act
behaviour Line of Pit
interface Line()

types

    Line : uint256

storage

    Line |-> Line

if

    VGas > 300000

returns Line
```

### Mutators

#### adding and removing owners

```act
behaviour rely of Pit
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000

behaviour deny of Pit
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting `ilk` data

```act
behaviour file-ilk of Pit
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Can    : uint256
    Spot_i : uint256
    Line_i : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].spot   |-> Spot_i => #if what == #string2Word("spot") #then data #else Spot_i #fi
    ilks[ilk].line   |-> Line_i => #if what == #string2Word("line") #then data #else Line_i #fi

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting the global debt ceiling

```act
behaviour file-Line of Pit
interface file(bytes32 what, uint256 data)

types

    Can  : uint256
    Line : uint256

storage

    wards[CALLER_ID] |-> Can
    Line             |-> Line => #if what == #string2Word("Line") #then data #else Line #fi

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### manipulating a position


```act
behaviour frob of Pit
interface frob(bytes32 ilk, int256 dink, int256 dart)

types

    Can    : uint256
    Live   : uint256
    Line   : uint256
    Vat    : address VatLike
    Spot   : uint256
    Line_i : uint256
    Ink_i  : uint256
    Art_i  : uint256
    Ink_iu  : uint256
    Art_iu  : uint256
    Take   : uint256
    Rate   : uint256
    Gem_u  : uint256
    Dai    : uint256
    Debt   : uint256

storage

    live           |-> Live
    Line           |-> Line
    vat            |-> Vat
    ilks[ilk].line |-> Line_i
    ilks[ilk].spot |-> Spot

storage Vat

    wards[ACCT_ID]           |-> Can
    ilks[ilk].rate           |-> Rate
    ilks[ilk].take           |-> Take
    ilks[ilk].Ink            |-> Ink_i  => Ink_i + dink
    ilks[ilk].Art            |-> Art_i  => Art_i + dart
    urns[ilk][CALLER_ID].ink |-> Ink_iu  => Ink_iu + dink
    urns[ilk][CALLER_ID].art |-> Art_iu  => Art_iu + dart
    gem[ilk][CALLER_ID]      |-> Gem_u  => Gem_u - Take * dink
    dai[CALLER_ID]           |-> Dai    => Dai + Rate * dart
    debt                     |-> Debt   => Debt + Rate * dart

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: `Rate` is `. ? : not` non-zero
    Rate =/= 0
    // act: position is `. ? : not` either below collateral and global ceiling or is dai-decreasing
    (((Art_iu + dart) * Rate <= #Ray * Spot) and (Debt + (Rate * dart) < #Ray * Line)) or (dart <= 0)
    // act: position is `. ? : not` either safe or risk-decreasing
    ((dart <= 0) and (dink >= 0)) or ((Ink_iu + dink) * Spot >= (Art_iu + dart) * Rate)
    // act: system is `. ? : not` live
    Live == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint256

    Ink_i + dink
    Art_i + dart
    Ink_iu + dink
    Art_iu + dart
    Gem_u - Take * dink
    Dai + Rate * dart
    Debt + Rate * dart
    (Art_iu + dart) * Rate
    (Ink_iu + dink) * Spot
    #Ray * Spot
    #Ray * Line

iff in range int256

    Take
    Take * dink
    Rate
    Rate * dart

if

    VGas > 300000
```

# Vow

## Specification of behaviours

### Accessors

#### owners

```act
behaviour wards of Vow
interface wards(address guy)

types

    Can : uint256

storage

    wards[guy] |-> Can

if

    VGas > 300000

returns Can
```

#### getting a `sin` packet

```act
behaviour sin of Vow
interface sin(uint48 era)

types

    Sin_era : uint256

storage

    sin[era] |-> Sin_era

if

    VGas > 300000

returns Sin_era
```

#### getting the `Sin`

```act
behaviour Sin of Vow
interface Sin()

types

    Sin : uint256

storage

    Sin |-> Sin

if

    VGas > 300000

returns Sin
```

#### getting the `Ash`

```act
behaviour Ash of Vow
interface Ash()

types

    Ash : uint256

storage

    Ash |-> Ash

if

    VGas > 300000

returns Ash
```

#### getting the `wait`

```act
behaviour wait of Vow
interface wait()

types

    Wait : uint256

storage

    wait |-> Wait

if

    VGas > 300000

returns Wait
```

#### getting the `sump`

```act
behaviour sump of Vow
interface sump()

types

    Sump : uint256

storage

    sump |-> Sump

if

    VGas > 300000

returns Sump
```

#### getting the `bump`

```act
behaviour bump of Vow
interface bump()

types

    Bump : uint256

storage

    bump |-> Bump

if

    VGas > 300000

returns Bump
```

#### getting the `hump`

```act
behaviour hump of Vow
interface hump()

types

    Hump : uint256

storage

    hump |-> Hump

if

    VGas > 300000

returns Hump
```

#### getting the `Awe`

```act
behaviour Awe of Vow
interface Awe()

types

    Vat : address VatLike
    Sin : uint256

storage

    vat |-> Vat

storage Vat

    sin[ACCT_ID] |-> Sin

iff

    // act: call stack is not too big
    VCallDepth < 1024

if

    VGas > 300000

returns Sin / #Ray
```

#### getting the `Joy`

```act
behaviour Joy of Vow
interface Joy()

types

    Vat : address VatLike
    Dai : uint256

storage

    vat |-> Vat

storage Vat

    dai[ACCT_ID] |-> Dai

iff

    // act: call stack is not too big
    VCallDepth < 1024

if

    VGas > 300000

returns Dai / #Ray
```

#### getting the `Woe`

```act
behaviour Woe of Vow
interface Woe()

types

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

if

    VGas > 300000

returns (Sin / #Ray - Ssin) - Ash
```

### Mutators

#### adding and removing owners

```act
behaviour rely of Vow
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000

behaviour deny of Vow
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```


#### setting `Vow` parameters

```act
behaviour file-data of Vow
interface file(bytes32 what, uint256 data)

types

    Can  : uint256
    Wait : uint256
    Sump : uint256
    Bump : uint256
    Hump : uint256

storage

    wards[CALLER_ID] |-> Can
    wait             |-> Wait => (#if what == #string2Word("wait") #then data #else Wait #fi)
    sump             |-> Sump => (#if what == #string2Word("sump") #then data #else Sump #fi)
    bump             |-> Bump => (#if what == #string2Word("bump") #then data #else Bump #fi)
    hump             |-> Hump => (#if what == #string2Word("hump") #then data #else Hump #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting vat and liquidators

```act
behaviour file-addr of Vow
interface file(bytes32 what, address addr)

types

    Can : uint256
    Cow : address
    Row : address
    Vat : address

storage

    wards[CALLER_ID] |-> Can
    cow              |-> Cow => (#if what == #string2Word("flap") #then addr #else Cow #fi)
    row              |-> Row => (#if what == #string2Word("flop") #then addr #else Row #fi)
    vat              |-> Vat => (#if what == #string2Word("vat")  #then addr #else Vat #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### cancelling bad debt and surplus

```act
behaviour heal of Vow
interface heal(uint256 wad)

types

    Vat  : address VatLike
    Can  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat

storage Vat

    wards[ACCT_ID] |-> Can
    dai[ACCT_ID]   |-> Dai  => Dai  - wad * #Ray
    sin[ACCT_ID]   |-> Sin  => Sin  - wad * #Ray
    vice           |-> Vice => Vice - wad * #Ray
    debt           |-> Debt => Debt - wad * #Ray

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range uint256

    Dai  - wad * #Ray
    Sin  - wad * #Ray
    Vice - wad * #Ray
    Debt - wad * #Ray

iff in range int256

    wad * #Ray

if

    VGas > 300000

behaviour kiss of Vow
interface kiss(uint256 wad)

types

    Vat  : address VatLike
    Ash  : uint256
    Can  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    vat |-> Vat
    Ash |-> Ash => Ash - wad

storage Vat

    wards[ACCT_ID] |-> Can
    dai[ACCT_ID]   |-> Dai  => Dai  - wad * #Ray
    sin[ACCT_ID]   |-> Sin  => Sin  - wad * #Ray
    vice           |-> Vice => Vice - wad * #Ray
    debt           |-> Debt => Debt - wad * #Ray

iff

    // act: caller is `. ? : not` authorised
    Can == 1
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

if

    VGas > 300000
```

#### adding to the `sin` queue

```act
behaviour fess of Vow
interface fess(uint256 tab)

types

    Can     : uint256
    Sin_era : uint256
    Sin     : uint256

storage

    wards[CALLER_ID] |-> Can
    sin[TIME]        |-> Sin_era => Sin_era + tab
    Sin              |-> Sin     => Sin     + tab

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range uint256

    Sin_era + tab
    Sin     + tab

if

    VGas > 300000
```

#### processing `sin` queue

```act
behaviour flog of Vow
interface flog(uint48 t)

types

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

if

    VGas > 300000
```

#### starting a debt auction

```act
behaviour flop of Vow
interface flop()

types

    Row     : address Flopper
    Vat     : address VatLike
    Ssin    : uint256
    Ash     : uint256
    Sump    : uint256
    Can     : uint256
    Kicks   : uint256
    Vow_was : address
    Lot_was : uint256
    Bid_was : uint256
    Guy_was : address
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

    #Flopper.wards[ACCT_ID]              |-> Can
    #Flopper.kicks                       |-> Kicks => 1 + Kicks
    #Flopper.bids[1 + Kicks].vow         |-> Vow_was => ACCT_ID
    #Flopper.bids[1 + Kicks].bid         |-> Bid_was => Sump
    #Flopper.bids[1 + Kicks].lot         |-> Lot_was => maxUInt256
    #Flopper.bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    #Flopper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)

storage Vat

    dai[ACCT_ID] |-> Dai
    sin[ACCT_ID] |-> Sin_v

iff

    // act: caller is `. ? : not` authorised
    Can == 1
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

if

    VGas > 300000

returns 1 + Kicks
```

#### starting a surplus auction

```act
behaviour flap of Vow
interface flap()

types

    Cow      : address Flapper
    Vat      : address VatLike
    Bump     : uint256
    Hump     : uint256
    Ssin     : uint256
    Ash      : uint256
    DaiMove  : address DaiMoveLike
    Could    : uint256
    Bid_was  : uint256
    Lot_was  : uint256
    Guy_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Gal_was  : address
    Ttl      : uint48
    Tau      : uint48
    Kicks    : uint256
    Can_move : uint256
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

storage DaiMove

    vat                         |-> Vat
    can[ACCT_ID][Cow]           |-> Could => 0

storage Cow

    #Flapper.dai                         |-> DaiMove
    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks   => 1 + Kicks
    #Flapper.bids[1 + Kicks].bid         |-> Bid_was => 0
    #Flapper.bids[1 + Kicks].lot         |-> Lot_was => Bump
    #Flapper.bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(ACCT_ID, Tic_was, TIME + Tau)
    #Flapper.bids[1 + Kicks].gal         |-> Gal_was => ACCT_ID

storage Vat

    wards[DaiMove] |-> Can_move
    dai[ACCT_ID]   |-> Dai_v => Dai_v - #Ray * Bump
    sin[ACCT_ID]   |-> Sin_v
    dai[Cow]       |-> Dai_c => Dai_c + #Ray * Bump

iff

    // doc: there is enough `Joy`
    Dai_v / #Ray >= (Sin_v + Bump) + Hump
    // doc: there is no `Woe`
    (Sin_v / #Ray - Ssin) - Ash == 0
    // doc: DaiMove is authorised to call Vat
    Can_move == 1
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
    VGas > 600000

returns 1 + Kicks
```

# Cat

## Specification of behaviours

### Accessors

#### owners

```act
behaviour wards of Cat
interface wards(address guy)

types

    Can : uint256

storage

    wards[guy] |-> Can

if

    VGas > 300000

returns Can
```

#### `ilk` data

```act
behaviour ilks of Cat
interface ilks(bytes32 ilk)

types

    Chop : uint256
    Flip : address
    Lump : uint256

storage

    ilks[ilk].flip |-> Flip
    ilks[ilk].chop |-> Chop
    ilks[ilk].lump |-> Lump

if

    VGas > 300000

returns Flip : Chop : Lump
```

#### liquidation data

```act
behaviour flips of Cat
interface flips(uint256 n)

types

    Ilk : bytes32
    Urn : bytes32
    Ink : uint256
    Tab : uint256

storage

    flips[n].ilk |-> Ilk
    flips[n].urn |-> Urn
    flips[n].ink |-> Ink
    flips[n].tab |-> Tab

if

    VGas > 300000

returns Ilk : Urn : Ink : Tab
```

#### liquidation counter

```act
behaviour nflip of Cat
interface nflip()

types

    Nflip : uint256

storage

    nflip |-> Nflip

if

    VGas > 300000

returns Nflip
```

#### liveness

```act
behaviour live of Cat
interface live()

types

    Live : uint256

storage

    live |-> Live

if

    VGas > 300000

returns Live
```

#### `vat` address

```act
behaviour vat of Cat
interface vat()

types

    Vat : address

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### `pit` address

```act
behaviour pit of Cat
interface pit()

types

    Pit : address

storage

    pit |-> Pit

if

    VGas > 300000

returns Pit
```

#### `vow` address

```act
behaviour vow of Cat
interface vow()

types

    Vow : address

storage

    vow |-> Vow

if

    VGas > 300000

returns Vow
```

### Mutators

#### addingg and removing owners

```act
behaviour rely of Cat
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 1

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000

behaviour deny of Cat
interface deny(address guy)

types

    Can : uint256
    Could : uint256

storage

    wards[CALLER_ID] |-> Can
    wards[guy]       |-> Could => 0

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting contract addresses

```act
behaviour file-addr of Cat
interface file(bytes32 what, address data)

types

    Can : uint256
    Pit : address
    Vow : address

storage

    wards[CALLER_ID] |-> Can
    pit              |-> Pit => (#if what == #string2Word("pit") #then data #else Pit #fi)
    vow              |-> Vow => (#if what == #string2Word("vow") #then data #else Vow #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting liquidation data

```act
behaviour file of Cat
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Can  : uint256
    Chop : uint256
    Lump : uint256

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].chop   |-> Chop => (#if what == #string2Word("chop") #then data #else Chop #fi)
    ilks[ilk].lump   |-> Lump => (#if what == #string2Word("lump") #then data #else Lump #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### setting liquidator address

```act
behaviour file-flip of Cat
interface file(bytes32 ilk, bytes32 what, address data)

types

    Can  : uint256
    Flip : address

storage

    wards[CALLER_ID] |-> Can
    ilks[ilk].flip   |-> Flip => (#if what == #string2Word("flip") #then data #else Flip #fi)

iff

    // act: caller is `. ? : not` authorised
    Can == 1

if

    VGas > 300000
```

#### marking a position for liquidation

```act
behaviour bite of Cat
interface bite(bytes32 ilk, address urn)

types

    Vat     : address VatLike
    Pit     : address PitLike
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

    wards[ACCT_ID]     |-> Can
    ilks[ilk].take     |-> Take
    ilks[ilk].rate     |-> Rate
    urns[ilk][urn].ink |-> Ink_iu => 0
    urns[ilk][urn].art |-> Art_iu => 0
    ilks[ilk].Ink      |-> Ink_i  => Ink_i  - Ink_iu
    ilks[ilk].Art      |-> Art_i  => Art_i  - Art_iu
    gem[ilk][ACCT_ID]  |-> Gem_iv => Gem_iv + Take * Ink_iu
    sin[Vow]           |-> Sin_w  => Sin_w  - Rate * Art_iu
    vice               |-> Vice   => Vice   - Rate_* Art_iu

storage Pit

    ilks[ilk].spot     |-> Spot_i

storage Vow

    sin[TIME]          |-> Sin_era => Sin_era + Art_iu * Rate
    Sin                |-> Sin     => Sin     + Art_iu * Rate

iff

    // act: caller is `. ? : not` authorised
    Can == 1
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

if

    VGas > 300000

returns Nflip + 1
```

#### starting a collateral auction

```act
behaviour flip of Cat
interface flip(uint256 n, uint256 wad)

types

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
    #Flipper.bids[1 + Kicks].guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
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

if

    VGas > 300000

returns 1 + Kicks
```

# GemJoin

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of GemJoin
interface vat()

types

    Vat : address VatLike

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### the associated `ilk`

```act
behaviour ilk of GemJoin
interface ilk()

types

    Ilk : bytes32

storage

    ilk |-> Ilk

if

    VGas > 300000

returns Ilk
```

#### gem address

```act
behaviour gem of GemJoin
interface gem()

types

    Gem : address

storage

    gem |-> Gem

if

    VGas > 300000

returns Gem
```

### Mutators

#### depositing into the system

```act
behaviour join of GemJoin
interface join(bytes32 urn, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> Can
    gem[Ilk][CALLER_ID]     |-> Rad => Rad + #Ray * wad

storage Gem

    balances[CALLER_ID] |-> Bal_guy     => Bal_guy     - wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_guy     - wad
    Bal_adapter + wad

if

    VGas > 300000
```

#### withdrawing from the system

```act
behaviour exit of GemJoin
interface exit(address guy, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk
    gem |-> Gem

storage Vat

    wards[ACCT_ID]          |-> Can
    gem[Ilk][CALLER_ID]     |-> Rad => Rad - #Ray * wad

storage Gem

    balances[CALLER_ID] |-> Bal_guy     => Bal_guy     + wad
    balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad         - #Ray * wad
    Bal_guy     + wad
    Bal_adapter - wad

if

    VGas > 300000
```

# ETHJoin

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of ETHJoin
interface vat()

types

    Vat : address VatLike

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### the associated `ilk`

```act
behaviour ilk of ETHJoin
interface ilk()

types

    Ilk : bytes32

storage

    ilk |-> Ilk

if

    VGas > 300000

returns Ilk
```

### Mutators

#### depositing into the system

*TODO* : add `balance ACCT_ID` block

```act
behaviour join of ETHJoin
interface join(bytes32 urn)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Can         : uint256
    Rad         : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    ilk |-> Ilk

storage Vat

    wards[ACCT_ID]      |-> Can
    gem[Ilk][CALLER_ID] |-> Rad => Rad + #Ray * VALUE

iff

    // act: caller is `. ? : not` authorised
    Can == 1

iff in range int256

    #Ray * VALUE

iff in range uint256

    Rad         + #Ray * VALUE
    Bal_adapter + VALUE

if

    VGas > 300000
```

#### withdrawing from the system

*TODO* : add `balance ACCT_ID` block

```act
behaviour exit of ETHJoin
interface exit(address guy, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256

storage

    vat             |-> Vat
    ilk             |-> Ilk

storage Vat

    wards[ACCT_ID]      |-> Can
    gem[Ilk][CALLER_ID] |-> Rad => Rad - #Ray * wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024
    // act: there is `. ? : not` enough ETH in the adapter
    wad <= BAL

iff in range int256

    #Ray * wad

iff in range uint256

    Rad     - #Ray * wad
    Bal_guy + wad

if

    VGas > 300000
```

# DaiJoin

## Specification of behaviours

### Accessors

#### `vat` address

```act
behaviour vat of DaiJoin
interface vat()

types

    Vat : address VatLike

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

#### dai address

```act
behaviour dai of DaiJoin
interface dai()

types

    Dai : address

storage

    dai |-> Dai

if

    VGas > 300000

returns Dai
```

### Mutators

#### depositing into the system

```act
behaviour join of DaiJoin
interface join(bytes32 urn, uint256 wad)

types

    Vat         : address VatLike
    Dai         : address GemLike
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    wards[ACCT_ID] |-> Can
    dai[CALLER_ID] |-> Rad => Rad + #Ray * wad

storage Dai

    #Gem.balances[CALLER_ID] |-> Bal_guy     => Bal_guy - wad
    #Gem.balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter + wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_guy - wad
    Bal_adapter + wad

if

    VGas > 300000
```

#### withdrawing from the system

```act
behaviour exit of DaiJoin
interface exit(address guy, uint256 wad)

types

    Vat         : address VatLike
    Dai         : address GemLike
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256

storage

    vat |-> Vat
    dai |-> Dai

storage Vat

    wards[ACCT_ID]          |-> Can
    gem[Ilk][CALLER_ID]     |-> Rad => Rad - #Ray * wad

storage Dai

    #Gem.balances[CALLER_ID] |-> Bal_guy     => Bal_guy     + wad
    #Gem.balances[ACCT_ID]   |-> Bal_adapter => Bal_adapter - wad

iff

    // act: caller is `. ? : not` authorised
    Can == 1
    // act: call stack is not too big
    VCallDepth < 1024

iff in range int256

    #Ray * wad

iff in range uint256

    Rad         - #Ray * wad
    Bal_guy     + wad
    Bal_adapter - wad

if

    VGas > 300000
```

# DaiMove

## Specification of behaviours

### Accessors

#### the Vat

```act
behaviour vat of DaiMove
interface vat()
types

    Vat : address

storage

    vat |-> Vat

if

    VGas > 300000

returns Vat
```

### Mutators

#### approve or unapprove an address

```act
behaviour hope of DaiMove
interface hope(address guy)

types

    Could : uint256

storage

    can[CALLER_ID][guy] |-> Could => 1

if

    VGas > 300000

behaviour nope of DaiMove
interface nope(address guy)

types

    Could : uint256

storage

    can[CALLER_ID][guy] |-> Could => 0

if

    VGas > 300000
```

#### move tokens

```act
behaviour move of DaiMove
interface move(address src, address dst, uint256 wad)

types

     Can      : uint256
     Vat      : address VatLike
     Can_move : uint256
     Dai_src  : uint256
     Dai_dst  : uint256

storage

     can[src][CALLER_ID] |-> Can
     vat                 |-> Vat

storage Vat

     wards[ACCT_ID]      |-> Can_move
     dai[src]            |-> Dai_src => Dai_src - #Ray * wad
     dai[dst]            |-> Dai_dst => Dai_dst + #Ray * wad

iff

     // doc: caller is approved to move tokens
     ((src == CALLER_ID) or (Can == 1))
     // doc: call stack not too big
     VCallDepth < 1024
     // doc: DaiMove authorised to call Cat
     Can_move == 1

iff in range uint256

     Dai_src - #Ray * wad
     Dai_dst + #Ray * wad

iff in range int256

     #Ray * wad

if

     VGas > 300000
```

# Flapper

## Specification of behaviours

### Accessors

#### bid data

```act
behaviour bids of Flapper
interface bids(uint256 n)

types

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

if

    VGas > 300000

returns Bid : Lot : #WordPackAddrUInt48UInt48(Guy, Tic, End) : Gal
```

#### sell token

```act
behaviour dai of Flapper
interface dai()

types

    Dai : address

storage

    dai |-> Dai

if

    VGas > 300000

returns Dai
```

#### buy token

```act
behaviour gem of Flapper
interface gem()

types

    Gem : address

storage

    gem |-> Gem

if

    VGas > 300000

returns Gem
```

#### minimum bid increment

```act
behaviour beg of Flapper
interface beg()

types

    Beg : uint256

storage

    beg |-> Beg

if

    VGas > 300000

returns Beg
```

#### auction time-to-live

```act
behaviour ttl of Flapper
interface ttl()

types

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

if

    VGas > 300000

returns Ttl
```

#### maximum auction duration

```act
behaviour tau of Flapper
interface tau()

types

    Ttl : uint48
    Tau : uint48

storage

    ttl_tau |-> #WordPackUInt48UInt48(Ttl, Tau)

if

    VGas > 300000

returns Tau
```

#### kick counter

```act
behaviour kicks of Flapper
interface kicks()

types

    Kicks : uint256

storage

    kicks |-> Kicks

if

    VGas > 300000

returns Kicks
```

### Mutators


#### starting an auction

```act
behaviour kick of Flapper
interface kick(address gal, uint256 lot, uint256 bid)

types

    Kicks    : uint256
    DaiMove  : address DaiMoveLike
    Ttl      : uint48
    Tau      : uint48
    Bid_was  : uint256
    Lot_was  : uint256
    Guy_was  : address
    Tic_was  : uint48
    End_was  : uint48
    Gal_was  : address
    Vat      : address VatLike
    Can      : uint256
    Can_move : uint256
    Dai_v    : uint256
    Dai_c    : uint256

storage

    dai                         |-> DaiMove
    ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    kicks                       |-> Kicks   => 1 + Kicks
    bids[1 + Kicks].bid         |-> Bid_was => bid
    bids[1 + Kicks].lot         |-> Lot_was => lot
    bids[1 + Kicks].guy_tic_end |-> #WordPackAddrUInt48UInt48(Guy_was, Tic_was, End_was) => #WordPackAddrUInt48UInt48(CALLER_ID, Tic_was, TIME + Tau)
    bids[1 + Kicks].gal         |-> Gal_was => gal

storage DaiMove

    vat                     |-> Vat
    can[CALLER_ID][ACCT_ID] |-> Can

storage Vat

    wards[DaiMove] |-> Can_move
    dai[CALLER_ID] |-> Dai_v => Dai_v - #Ray * lot
    dai[ACCT_ID]   |-> Dai_c => Dai_c + #Ray * lot

iff

    // doc: call stack is not too big
    VCallDepth < 1023
    // doc: Flap is authorised to move for the caller
    Can      == 1
    // doc: DaiMove is authorised to call Vat
    Can_move == 1

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
   VGas > 300000

returns 1 + Kicks
```

