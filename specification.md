What follows is an executable K specification of the smart contracts of multicollateral dai.

# tune

## Specification of behaviours

### Accessors

#### admin address
```
behaviour root of Vat
interface root()

types

    Root : address

storage

    #Vat.root |-> Root

returns Root
```

#### internal dai balances
```
behaviour dai of Vat
interface dai(address lad)

types

    Rad : int256

storage

    #Vat.dai(lad) |-> uint(Rad)

returns uint(Rad)
```

#### internal sin balances
```
behaviour sin of Vat
interface sin(address lad)

types

    Rad : int256

storage

    #Vat.sin(lad) |-> uint(Rad)

returns uint(Rad)
```

#### `ilk` data
```
behaviour ilks of Vat
interface ilks(bytes32 ilk)

types

    Rate : int256
    Art_i  : int256

storage

    #Vat.ilks(ilk).rate |-> uint(Rate)
    #Vat.ilks(ilk).Art |-> uint(Art_i)

returns uint(Rate) : uint(Art_i)
```

#### `urn` data
```
behaviour urns of Vat
interface urns(bytes32 ilk, address lad)

types

    Gem : int256
    Ink : int256
    Art_u : int256

storage

    #Vat.urns(ilk, lad).gem |-> uint(Gem)
    #Vat.urns(ilk, lad).ink |-> uint(Ink)
    #Vat.urns(ilk, lad).art |-> uint(Art_u)

returns uint(Gem) : uint(Ink) : uint(Art_u)
```

#### total debt
```
behaviour Tab of Vat
interface Tab()

types

    Tab : int256

storage

    #Vat.Tab |-> uint(Tab)

returns uint(Tab)
```

#### total bad debt
```
behaviour vice of Vat
interface vice()

types

    Vice : int256

storage

    #Vat.vice |-> uint(Vice)

returns uint(Vice)
```
### Mutators

#### setting `ilk` data
```
behaviour file of Vat
interface file(bytes32 ilk, bytes32 what, int256 risk)

types

    Rate : int256

storage

    #Vat.ilks(ilk).rate |-> Rate => uint(#if what ==Int 51735852229306712642142495812301944985879738350407357154196970624323795550208 #then risk #else Rate #fi)
```

#### transferring dai balances
```
behaviour move-uint of Vat
interface move(address src, address dst, uint256 wad)

types

    Dai_src : int256
    Dai_dst : int256

storage

    #Vat.dai(src) |-> uint(Dai_src) => uint(Dai_src - #wad2rad(wad))
    #Vat.dai(dst) |-> uint(Dai_dst) => uint(Dai_dst + #wad2rad(wad))

iff

    Dai_src - #wad2rad(wad) >= 0
    Dai_dst + #wad2rad(wad) >= 0

iff in range int256

    wad
    #wad2rad(wad)
    Dai_src - #wad2rad(wad)
    Dai_dst + #wad2rad(wad)
```

```
behaviour move-int of Vat
interface move(address src, address dst, int256 wad)

types

    Dai_src : int256
    Dai_dst : int256

storage

    #Vat.dai(src) |-> uint(Dai_src) => uint(Dai_src - #wad2rad(wad))
    #Vat.dai(dst) |-> uint(Dai_dst) => uint(Dai_dst + #wad2rad(wad))

iff

    Dai_src - #wad2rad(wad) >= 0
    Dai_dst + #wad2rad(wad) >= 0

iff in range int256

    #wad2rad(wad)
    Dai_src - #wad2rad(wad)
    Dai_dst + #wad2rad(wad)
```

#### assigning unencumbered collateral
```
behaviour slip of Vat
interface slip(bytes32 ilk, address guy, int256 wad)

types

    Wad : int256

storage

    #Vat.urns(ilk, guy).gem |-> uint(Wad) => uint(Wad + wad)

iff

    Wad + wad >= 0

iff in range int256

    Wad + wad
```

#### adminstering a position

```
behaviour tune of Vat
interface tune(bytes32 ilk, address lad, int256 dink, int256 dart)

types

    Gem   : int256
    Ink   : int256
    Art_u : int256
    Art_i : int256
    Rate  : int256
    Dai   : int256
    Tab   : int256

storage

    #Vat.urns(ilk, lad).gem |-> uint(Gem_u)  => uint(Gem_u - dink)
    #Vat.urns(ilk, lad).ink |-> uint(Ink_u)  => uint(Ink_u + dink)
    #Vat.urns(ilk, lad).art |-> uint(Art_u)  => uint(Art_u + dart)
    #Vat.ilks(ilk).rate     |-> uint(Rate_i)
    #Vat.ilks(ilk).Art      |-> uint(Art_i)  => uint(Art_i + dart)
    #Vat.dai(lad)           |-> uint(Dai)    => uint(Dai + (Rate_i * dart))
    #Vat.Tab                |-> uint(Tab)    => uint(Tab + (Rate_i * dart))

iff

    Rate =/= 0
    (((((Art_u + dart) * Rate_i) <= #wad2rad(Spot_i)) and (((Tab + (Rate_i * dart))) < #wad2rad(Line))) or (dart <= 0))
    (((dart <= 0) and (dink >= 0)) or (((Ink_u + dink) * Spot_i) >= ((Art_u + dart) * Rate_i)))
    Live == 1

iff in range int256

    Gem_u - dink
    Ink_u + dink
    Art_u + dart
    Art_i + dart
    Rate_i * dart
    Dai + (Rate_i * dart)
    Tab + (Rate_i * dart)
    (Art_u + dart) * Rate_i
    (Ink_u + dink) * Spot_i
    #wad2rad(Spot_i)
    #wad2rad(Line)
```

#### confiscating a position
```
behaviour grab of Vat
interface grab(bytes32 ilk, address lad, address vow, int256 dink, int256 dart)

types

    Ink   : int256
    Art_u : int256
    Art_i : int256
    Rate  : int256
    Sin   : int256

storage

    #Vat.urns(ABI_ilk, ABI_lad).ink |-> uint(Ink)   => uint(Ink + dink)
    #Vat.urns(ABI_ilk, ABI_lad).art |-> uint(Art_u) => uint(Art_u + dart)
    #Vat.ilks(ABI_ilk).rate         |-> uint(Rate)
    #Vat.ilks(ABI_ilk).Art          |-> uint(Art_i) => uint(Art_i + dart)
    #Vat.sin(ABI_vow)               |-> uint(Sin)   => uint(Sin + Rate * dart)
    #Vat.vice                       |-> uint(Vice)  => uint(Vice + Rate * dart)


iff in range int256

    Ink + dink
    Art_u + dart
    Art_i + dart
    Rate * dart
    Sin + Rate * dart
    Vice + Rate * dart
```

#### cancelling bad debt and surplus
```
behaviour heal of Vat
interface heal(address u, address v, int256 wad)

types

    Dai_v : int256
    Sin_u : int256
    Tab   : int256
    Vice  : int256

storage

    #Vat.dai(v) |-> uint(Dai_v) => uint(Dai_v - #wad2rad(wad))
    #Vat.sin(u) |-> uint(Sin_u) => uint(Sin_u - #wad2rad(wad))
    #Vat.Tab    |-> uint(Tab)   => uint(Tab - #wad2rad(wad))
    #Vat.vice   |-> uint(Vice)  => uint(Vice - #wad2rad(wad))

iff

    Dai_v - #wad2rad(wad) >= 0
    Sin_u - #wad2rad(wad) >= 0
    Tab - #wad2rad(wad)   >= 0
    Vice - #wad2rad(wad)  >= 0

iff in range int256

    Dai_v - #wad2rad(wad)
    Sin_u - #wad2rad(wad)
    Tab - #wad2rad(wad)
    Vice - #wad2rad(wad)
```

#### applying interest to `ilk`
```
behaviour fold of Vat
interface fold(bytes32 ilk, address vow, int256 rate)

types

    Rate  : int256
    Dai   : int256
    Art_i : int256
    Tab   : int256

storage

    #Vat.ilks(ilk).rate |-> uint(Rate => uint(Rate + rate)
    #Vat.ilks(ilk).Art  |-> uint(Art)
    #Vat.dai(vow)       |-> uint(Dai) => uint(Dai + Art_i * rate)
    #Vat.Tab            |-> uint(Tab) => uint(Tab + Art_i * rate)

iff in range int256

    Rate + rate
    Art * rate
    Dai + Art_i * rate
    Tab + Art_i * rate
```

# frob

## Specification of behaviours

### Accessors

#### system liveness
```
behaviour live of Pit
interface live()

types

    Live : bool

storage

    #Pit.live |-> Live

returns Live
```

#### global debt ceiling
```
behaviour Line of Pit
interface Line()

types

    Line : int256

storage

    #Pit.Line |-> uint(Line)

returns uint(Line)
```

#### `vat` address
```
behaviour vat of Pit
interface vat()

types

    Vat : address {Vat}

storage

    #Pit.vat |-> Vat

returns Vat
```

#### `ilk` data
```
behaviour ilks of Pit
interface ilks(bytes32 ilk)

types

    Spot_i : int256
    Line_i : int256

storage

    #Pit.ilks(ilk).spot |-> uint(Spot_i)
    #Pit.ilks(ilk).line |-> uint(Line_i)

returns

    uint(Spot_i) : uint(Line_i)
```

### Mutators

#### setting `ilk` data
```
behaviour file-ilk of Pit
interface file(bytes32 ilk, bytes32 what, int256 risk)

types

    Spot_i : int256
    Line_i : int256

storage

    #Pit.ilks(ilk).spot |-> Spot_i => uint(#if (what == 52214633679529120849900229181229190823836184335472955378023737308807130251264) #then risk #else Spot_i #fi)
    #Pit.ilks(ilk).line |-> Line_i => uint(#if (what == 49036068503847260643156492622631591831542628249327578363867825373603329736704) #then risk #else Line_i #fi)
```

#### setting the global debt ceiling
```
behaviour file-line of Pit
interface file(bytes32 what, int256 risk)

types

    Line : int256

storage

    #Pit.Line |-> Line => uint(#if (what == 34562057349182736215210119496545603349883880166122507858935627372614188531712) #then risk #else Line #fi)
```

#### manipulating a position

```
behaviour frob of Pit
interface frob(bytes32 ilk, int256 dink, int256 dart)

types

    Live   : bool
    Line   : int256
    Vat    : address VatLike
    Spot_i : int256
    Line_i : int256
    Gem_u  : int256
    Ink_u  : int256
    Art_u  : int256
    Art_i  : int256
    Rate_i : int256
    Dai    : int256
    Tab    : int256

storage

    #Pit.live           |-> Live
    #Pit.Line           |-> uint(Line)
    #Pit.vat            |-> Vat
    #Pit.ilks(ilk).line |-> uint(Line_i)
    #Pit.ilks(ilk).spot |-> uint(Spot_i)

storage Vat

    #Vat.urns(ilk, CALLER_ID).gem |-> uint(Gem_u) => uint(Gem_u - dink)
    #Vat.urns(ilk, CALLER_ID).ink |-> uint(Ink_u) => uint(Ink_u + dink)
    #Vat.urns(ilk, CALLER_ID).art |-> uint(Art_u) => uint(Art_u + dart)
    #Vat.ilks(ilk).rate           |-> uint(Rate_i)
    #Vat.ilks(ilk).Art            |-> uint(Art_i) => uint(Art_i + dart)
    #Vat.dai(CALLER_ID)           |-> uint(Dai) => uint(Dai + (Rate_i * dart))
    #Vat.Tab                      |-> uint(Tab) => uint(Tab + (Rate_i * dart))

iff

    Rate =/= 0
    (((((Art_u + dart) * Rate_i) <= #wad2rad(Spot_i)) and (((Tab + (Rate_i * dart))) < #wad2rad(Line))) or (dart <= 0))
    (((dart <= 0) and (dink >= 0)) or (((Ink_u + dink) * Spot_i) >= ((Art_u + dart) * Rate_i)))
    Live == 1

iff in range int256

    Gem_u - dink
    Ink_u + dink
    Art_u + dart
    Art_i + dart
    Rate_i * dart
    Dai + (Rate_i * dart)
    Tab + (Rate_i * dart)
    (Art_u + dart) * Rate_i
    (Ink_u + dink) * Spot_i
    #wad2rad(Spot_i)
    #wad2rad(Line)
```

# heal

## Specification of behaviours

### Accessors

#### getting a `sin` packet
```
behaviour sin of Vow
interface sin(uint48 era_)

types

    Sin_era : uint256
    
storage

    #Vow.sin(era_) |-> Sin_era
    
returns Sin_era
```

#### getting the `Sin`
```
behaviour Sin of Vow
interface Sin()

types

    Sin : uint256
    
storage

    #Vow.Sin |-> Sin
    
returns Sin
```

#### getting the `Woe`
```
behaviour Woe of Vow
interface Woe()

types

    Woe : uint256
    
storage

    #Vow.Woe |-> Woe
    
returns Woe
```

#### getting the `Ash`
```
behaviour Ash of Vow
interface Ash()

types

    Ash : uint256
    
storage

    #Vow.Ash |-> Ash
    
returns Ash
```

#### getting the `wait`
```
behaviour wait of Vow
interface wait()

types

    Wait : uint256
    
storage

    #Vow.wait |-> Wait
    
returns Wait
```

#### getting the `lump`
```
behaviour lump of Vow
interface lump()

types

    Lump : uint256
    
storage

    #Vow.lump |-> Lump
    
returns Lump
```

#### getting the `pad`
```
behaviour pad of Vow
interface pad()

types

    Pad : uint256
    
storage

    #Vow.pad |-> Pad
    
returns Pad
```

#### getting the time
```
behaviour era of Vow
interface era()
    
returns TIME
```

#### getting the `Awe`
```
behaviour Awe of Vow
interface Awe()

types

    Sin : uint256
    Woe : uint256
    Ash : uint256
    
storage

    #Vow.Sin |-> Sin
    #Vow.Woe |-> Woe
    #Vow.Ash |-> Ash
    
iff in range uint256

    Sin + Woe
    Sin + Woe + Ash
    
returns Sin + Woe + Ash
```

#### getting the `Joy`
```
behaviour Joy of Vow
interface Joy()

types

    Vat : address VatLike
    Dai : int256

storage

    #Vow.vat |-> Vat

storage Vat

    #Vat.dai(ACCT_ID) |-> uint(Dai)
    
iff in range uint256

    Dai
    
returns Dai / 1000000000000000000000000000
```

### Mutators

#### setting `Vow` parameters
```
behaviour file-risk of Vow
interface file(bytes32 what, uint256 risk)

types

    Lump : uint256
    Pad  : uint256

storage

    #Vow.lump |-> Lump => (#if what == 12345 #then risk #else Lump #fi)
    #Vow.pad  |-> Pad => (#if what == 67890 #then risk #else Pad #fi)
```

#### setting vat and liquidators
```
behaviour file-addr of Vow
interface file(bytes32 what, address addr)

types

    Cow : address
    Row : address
    Vat : address

storage

    #Vow.cow |-> Cow => (#if what == 12345 #then addr #else Cow #fi)
    #Vow.row |-> Row => (#if what == 67890 #then addr #else Row #fi)
    #Vow.vat |-> Vat => (#if what == 54321 #then addr #else Vat #fi)
```

#### adding to the `sin` queue
```
behaviour fess of Vow
interface fess(uint256 tab)

types

    Sin_era : uint256
    Sin     : uint256
    
storage

    #Vow.sin(TIME) |-> Sin_era => Sin_era + tab
    #Vow.Sin       |-> Sin => Sin + tab
    
iff in range uint256

    Sin_era + tab
    Sin + tab
```

#### processing `sin` queue
```
behaviour flog of Vow
interface flog(uint48 era_)

types

    Sin_era_ : uint256
    
storage

    #Vow.sin(era_) |-> Sin_era_ => 0
    #Vow.Sin       |-> Sin => Sin - Sin_era_
    #Vow.Woe       |-> Woe => Woe + Sin_era_

iff in range uint256

    Sin - Sin_era_
    Woe + Sin_era_
```

#### cancelling bad debt and surplus
```
behaviour heal of Vow
interface heal(uint256 wad)

types

    Vat  : address VatLike
    Woe  : uint256
    Dai  : int256
    Sin  : int256
    Vice : int256
    Tab  : int256

storage

    #Vow.vat |-> Vat
    #Vow.Woe |-> Woe - wad

storage Vat

    #Vat.dai(ACCT_ID) |-> uint(Dai)  => uint(Dai - #wad2rad(wad))
    #Vat.sin(ACCT_ID) |-> uint(Sin)  => uint(Sin - #wad2rad(wad))
    #Vat.vice         |-> uint(Vice) => uint(Vice - #wad2rad(wad))
    #Vat.Tab          |-> uint(Tab)  => uint(Tab - #wad2rad(wad))

iff

    wad <= Dai / 1000000000000000000000000000
    wad <= Woe

iff in range uint256

    Woe - wad
    
iff in range int256

    wad
    Dai - #wad2rad(wad)
    Sin - #wad2rad(wad)
    Vice - #wad2rad(wad)
    Tab - #wad2rad(wad)
```

```
behaviour kiss of Vow
interface kiss(uint256 wad)

types

    Vat  : address VatLike
    Woe  : uint256
    Dai  : int256
    Sin  : int256
    Vice : int256
    Tab  : int256

storage

    #Vow.vat |-> Vat
    #Vow.Ash |-> Ash - wad

storage Vat

    #Vat.dai(ACCT_ID) |-> uint(Dai)  => uint(Dai - #wad2rad(wad))
    #Vat.sin(ACCT_ID) |-> uint(Sin)  => uint(Sin - #wad2rad(wad))
    #Vat.vice         |-> uint(Vice) => uint(Vice - #wad2rad(wad))
    #Vat.Tab          |-> uint(Tab)  => uint(Tab - #wad2rad(wad))

iff

    wad <= Dai / 1000000000000000000000000000
    wad <= Ash

iff in range uint256

    Ash - wad
    
iff in range int256

    wad
    Dai - #wad2rad(wad)
    Sin - #wad2rad(wad)
    Vice - #wad2rad(wad)
    Tab - #wad2rad(wad)
```


#### starting a debt auction
```
behaviour flop of Vow
interface flop()

types

    Row   : address Flopper
    Vat   : address VatLike
    Lump  : uint256
    Woe   : uint256
    Ash   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : int256
    
storage

    #Vow.row  |-> Row
    #Vow.lump |-> Lump
    #Vow.Woe  |-> Woe => Woe - Lump
    #Vow.Ash  |-> Ash => Ash + Lump
    
storage Row

    #Flopper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flopper.kicks                       |-> Kicks => Kicks + 1
    #Flopper.bids(Kicks + 1).bid         |-> 0 => Lump
    #Flopper.bids(Kicks + 1).lot         |-> 0 => pow256 - 1
    #Flopper.bids(Kicks + 1).guy_tic_end |-> #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flopper.bids(Kicks + 1).vow         |-> 0 => ACCT_ID
    
storage Vat

    #Vat.dai(ACCT_ID) |-> uint(Dai)
    
iff

    Dai == 0
    
iff in range uint256

    Dai
    Woe - Lump
    Ash + Lump
    
returns Kicks + 1
```

#### starting a surplus auction
```
behaviour flap of Vow
interface flap()

types

    Cow   : address Flapper
    Vat   : address VatLike
    Lump  : uint256
    Pad   : uint256
    Woe   : uint256
    Ash   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : int256
    
storage

    #Vow.cow  |-> Cow
    #Vow.lump |-> Lump
    #Vow.pad  |-> Pad
    #Vow.Sin  |-> Sin
    #Vow.Woe  |-> Woe
    #Vow.Ash  |-> Ash
    
storage Cow

    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks => Kicks + 1
    #Flapper.bids(Kicks + 1).bid         |-> 0
    #Flapper.bids(Kicks + 1).lot         |-> 0 => Lump
    #Flapper.bids(Kicks + 1).guy_tic_end |-> #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flapper.bids(Kicks + 1).gal         |-> 0 => ACCT_ID
    
storage Vat

    #Vat.dai(ACCT_ID) |-> uint(Dai)

iff

    Dai / 1000000000000000000000000000 >= Sin + Woe + Ash + Lump + Pad
    Woe == 0
    
iff in range uint256

    Dai
    Sin + Woe
    Sin + Woe + Ash
    Sin + Woe + Ash + Lump
    Sin + Woe + Ash + Lump + Pad
    
returns Kicks + 1
```

# bite

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of Cat
interface vat()

types

    Vat : address
    
storage

    #Cat.vat |-> Vat
    
returns Vat
```

#### `pit` address
```
behaviour pit of Cat
interface pit()

types

    Pit : address
    
storage

    #Cat.pit |-> Pit
    
returns Pit
```

#### `vow` address
```
behaviour vow of Cat
interface vow()

types

    Vow : address
    
storage

    #Cat.vow |-> Vow
    
returns Vow
```

#### liquidation lot size
```
behaviour lump of Cat
interface lump()

types

    Lump : uint256
    
storage

    #Cat.lump |-> Lump
    
returns Lump
```

#### `ilk` data
```
behaviour ilks of Cat
interface ilks(bytes32 ilk)

types

    Chop : uint256
    Flip : address
    
storage

    #Cat.ilks(ilk).chop |-> Chop
    #Cat.ilks(ilk).flip |-> Flip
    
returns Chop : Flip
```

#### liquidation counter
```
behaviour nflip of Cat
interface nflip()

types

    Nflip : uint256
    
storage

    #Cat.nflip |-> Nflip
    
returns Nflip
```

#### liquidation data
```
behaviour flips of Cat
interface flips(uint256 n)

types

    Ilk : bytes32
    Lad : bytes32
    Ink : uint256
    Tab : uint256
    
storage

    #Cat.flips(n).ilk |-> Ilk
    #Cat.flips(n).lad |-> Lad
    #Cat.flips(n).ink |-> Ink
    #Cat.flips(n).tab |-> Tab
    
returns Ilk : Lad : Ink : Tab
```

### Mutators

#### setting liquidation lot size
```
behaviour file-lump of Cat
interface file(bytes32 what, uint256 risk)

types

    Lump : uint256

storage

    #Cat.lump |-> Lump => (#if what == 12345 #then risk #else Lump #fi)
```

#### setting liquidation penalty
```
behaviour file-chop of Cat
interface file(bytes32 ilk, bytes32 what, uint256 risk)

types

    Chop : uint256

storage

    #Cat.ilks(ilk).chop |-> Chop => (#if what == 12345 #then risk #else Chop #fi)
```

#### setting liquidator address
```
behaviour fuss of Cat
interface fuss(bytes32 ilk, address flip)

storage

    #Cat.ilks(ilk).flip |-> _ => flip
```

#### marking a position for liquidation
```
behaviour bite of Cat
interface bite(bytes32 ilk, address guy)

types

    Vat : address VatLike
    Pit : address PitLike
    Vow : address VowLike
    Nflip : uint256
    Rate_i : int256
    Art_i : int256
    Ink_u : int256
    Art_u : int256
    Sin_v : int256
    Vice : int256
    Sin : uint256
    Sin_era : uint256
    
storage

    #Cat.vat              |-> Vat
    #Cat.pit              |-> Pit
    #Cat.vow              |-> Vow
    #Cat.nflip            |-> Nflip => Nflip + 1
    #Cat.flips(Nflip).ilk |-> 0 => ilk
    #Cat.flips(Nflip).lad |-> 0 => guy
    #Cat.flips(Nflip).ink |-> 0 => Ink_u
    #Cat.flips(Nflip).tab |-> 0 => Rate_i * Art_u
    
storage Vat

    #Vat.ilks(ilk).rate |-> uint(Rate_i)
    #Vat.ilks(ilk).Art  |-> uint(Art_i) => uint(Art_i - Art_u)
    #Vat.urns(ilk, guy).ink |-> uint(Ink_u) => 0
    #Vat.urns(ilk, guy).art |-> uint(Art_u) => 0
    #Vat.sin(Vow) |-> uint(Sin_v) => uint(Sin_v - Rate_i * Art_u)
    #Vat.vice |-> uint(Vice) => uint(Vice - Rate_i * Art_u)

storage Pit

    #Pit.ilks(ilk).spot |-> uint(Spot_i)
    
Storage Vow

    #Vow.sin(TIME) |-> Sin_era => Sin_era + Art_u * Rate_i
    #Vow.Sin       |-> Sin => Sin + Art_u * Rate_i
    
iff

    Ink_u * Spot_i < Art_u * Rate_i

iff in range int256

    Art_u - Art_u
    Rate_i * Art_u
    Rate_i * (0 - Art_u)
    Sin_v - Rate_i * Art_u
    Vice - Rate_i * Art_u

iff in range uint256

    Rate_i * Art_u
    Sin_era + Art_u * Rate_i
    Sin + Art_u * Rate_i

returns Nflip + 1
```

#### starting a collateral auction
```
behaviour flip
interface flip(uint256 n, uint256 wad)

types

    Ilk   : bytes32
    Lad   : address
    Ink   : uint256
    Tab   : uint256
    Flip  : address Flipper
    Chop  : uint256
    Lump  : uint256
    Vow   : address
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256

storage

    #Cat.flips(Nflip).ilk |-> Ilk
    #Cat.flips(Nflip).lad |-> Lad
    #Cat.flips(Nflip).ink |-> Ink => Ink - (Ink * wad) / Tab
    #Cat.flips(Nflip).tab |-> Tab => Tab - wad
    #Cat.ilks(ilk).flip   |-> Flip
    #Cat.ilks(ilk).chop   |-> Chop
    #Cat.lump             |-> Lump
    #Cat.vow              |-> Vow
    
storage Flip

    #Flipper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flipper.kicks                       |-> Kicks => Kicks + 1
    #Flipper.bids(Kicks + 1).bid         |-> 0 => 0
    #Flipper.bids(Kicks + 1).lot         |-> 0 => (Ink * wad) / Tab
    #Flipper.bids(Kicks + 1).guy_tic_end |-> 0 => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flipper.bids(Kicks + 1).lad         |-> 0 => Lad
    #Flipper.bids(Kicks + 1).gal         |-> 0 => Vow
    #Flipper.bids(Kicks + 1).tab         |-> 0 => (wad * Chop) /Int 1000000000000000000000000000)

iff

    wad <= Tab
    (wad == Lump) or ((wad < Lump) and (wad == Tab))

iff in range int256

    wad

iff in range uint256

    Ink * wad
    wad * Chop

returns Kicks + 1
```

# join

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of Adapter
interface vat()

types

    Vat : address Vat

storage

    #Pit.vat |-> Vat

returns Vat
```

#### the associated `ilk`
```
behaviour ilk of Adapter
interface ilk()

types

    Ilk : bytes32
    
storage

    #Adapter.ilk |-> Ilk
    
returns Ilk
```

#### gem address
```
behaviour gem of Adapter
interface gem()

types

    Gem : address
    
storage

    #Adapter.gem |-> Gem
    
returns Gem
```

### Mutators

#### depositing into the system
```
behaviour join of Adapter
interface join(uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    Wad         : int256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #Adapter.vat |-> Vat
    #Adapter.ilk |-> Ilk
    #Adapter.gem |-> Gem

storage Vat

    #Vat.urns(Ilk, CALLER_ID).gem |-> uint(Wad) => uint(Wad + wad)
    
storage Gem

    #Gem.balances(CALLER_ID) |-> Bal_guy - wad
    #Gem.balances(ACCT_ID)   |-> Bal_adapter + wad
    
iff in range int256

    wad
    Wad + wad

iff in range uint256

    Bal_guy - wad
    Bal_adapter + wad
```

#### withdrawing from the system
```
behaviour exit of Adapter
interface exit(uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address GemLike
    Wad         : int256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #Adapter.vat |-> Vat
    #Adapter.ilk |-> Ilk
    #Adapter.gem |-> Gem

storage Vat

    #Vat.urns(Ilk, CALLER_ID).gem |-> uint(Wad) => uint(Wad - wad)
    
storage Gem

    #Gem.balances(CALLER_ID) |-> Bal_guy + wad
    #Gem.balances(ACCT_ID)   |-> Bal_adapter - wad
    
iff

    Wad - wad >= 0
    
iff in range int256

    wad
    Wad - wad

iff in range uint256

    Bal_guy + wad
    Bal_adapter - wad
```
