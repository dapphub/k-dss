What follows is an executable K specification of the smart contracts of multicollateral dai.

# tune

## Specification of behaviours

### Accessors

#### `ilk` data
```
behaviour ilks of Vat
interface ilks(bytes32 ilk)

types

    Rate : uint256
    Art_i  : uint256

storage

    #Vat.ilks(ilk).rate |-> Rate
    #Vat.ilks(ilk).Art  |-> Art_i

returns Rate : Art_i
```

#### `urn` data
```
behaviour urns of Vat
interface urns(bytes32 ilk, bytes32 lad)

types

    Ink   : uint256
    Art_u : uint256

storage

    #Vat.urns(ilk, lad).ink |-> Ink
    #Vat.urns(ilk, lad).art |-> Art_u

returns Ink : Art_u
```

#### internal gem balances
```
behaviour gem of Vat
interface gem(bytes32 ilk, bytes32 lad)

types

    Gem : uint256

storage

    #Vat.gem(ilk, lad) |-> Gem

returns Gem
```

#### internal dai balances
```
behaviour dai of Vat
interface dai(bytes32 lad)

types

    Rad : uint256

storage

    #Vat.dai(lad) |-> Rad

returns Rad
```

#### internal sin balances
```
behaviour sin of Vat
interface sin(bytes32 lad)

types

    Rad : uint256

storage

    #Vat.sin(lad) |-> Rad

returns Rad
```

#### total debt
```
behaviour debt of Vat
interface debt()

types

    Debt : uint256

storage

    #Vat.debt |-> Debt

returns Debt
```

#### total bad debt
```
behaviour vice of Vat
interface vice()

types

    Vice : uint256

storage

    #Vat.vice |-> Vice

returns Vice
```
### Mutators

#### initialising an `ilk`
```
behaviour init of Vat
interface init(bytes32 ilk)

storage

    #Vat.ilks(ilk).rate |-> Rate => 1000000000000000000000000000
    
iff

    Rate == 0
```

#### transferring dai balances
```
behaviour move of Vat
interface move(bytes32 src, bytes32 dst, uint256 rad)

types

    Dai_src : uint256
    Dai_dst : uint256

storage

    #Vat.dai(src) |-> Dai_src => Dai_src - rad
    #Vat.dai(dst) |-> Dai_dst => Dai_dst + rad

iff in range int256

    rad
    
iff in range uint256

    Dai_src - rad
    Dai_dst + rad
```

#### assigning unencumbered collateral
```
behaviour slip of Vat
interface slip(bytes32 ilk, bytes32 guy, int256 wad)

types

    Gem : uint256

storage

    #Vat.gem(ilk, guy) |-> Gem => Gem + wad

iff in range uint256

    Gem + wad
```

#### moving unencumbered collateral
```
behaviour flux of Vat
interface flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad)

types

    Gem_src : uint256
    Gem_dst : uint256

storage

    #Vat.gem(ilk, src) |-> Gem_src => Gem_src - wad
    #Vat.gem(ilk, dst) |-> Gem_dst => Gem_dst + wad
    
iff in range uint256

    Gem_src - wad
    Gem_dst + wad
```

#### adminstering a position

```
behaviour tune of Vat
interface tune(bytes32 ilk, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Gem_v : uint256
    Ink_u : uint256
    Art_u : uint256
    Art_i : uint256
    Rate  : uint256
    Dai   : uint256
    Debt  : uint256

storage

    #Vat.gem(ilk, v)        |-> Gem_v  => Gem_v - dink
    #Vat.urns(ilk, u).ink   |-> Ink_u  => Ink_u + dink
    #Vat.urns(ilk, u).art   |-> Art_u  => Art_u + dart
    #Vat.ilks(ilk).rate     |-> Rate
    #Vat.ilks(ilk).Art      |-> Art_i  => Art_i + dart
    #Vat.dai(w)             |-> Dai    => Dai + (Rate * dart)
    #Vat.debt               |-> Debt   => Debt + (Rate * dart)

iff in range uint256

    Gem_v - dink
    Ink_u + dink
    Art_u + dart
    Art_i + dart
    Dai + (Rate * dart)
    Debt + (Rate * dart)
    
iff in range int256

    Rate
    Rate * dart
```

#### confiscating a position
```
behaviour grab of Vat
interface grab(bytes32 ilk, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Gem_v : uint256
    Ink_u : uint256
    Art_u : uint256
    Art_i : uint256
    Rate  : uint256
    Sin   : uint256
    Vice  : uint256

storage

    #Vat.gem(ilk, v)       |-> Gem_v => Gem_v - dink
    #Vat.urns(ilk, u).ink  |-> Ink_u => Ink_u + dink
    #Vat.urns(ilk, u).art  |-> Art_u => Art_u + dart
    #Vat.ilks(ilk).rate    |-> Rate
    #Vat.ilks(ilk).Art     |-> Art_i => Art_i + dart
    #Vat.sin(w)            |-> Sin   => Sin - Rate * dart
    #Vat.vice              |-> Vice  => Vice - Rate * dart


iff in range uint256

    Gem_v - dink
    Ink_u + dink
    Art_u + dart
    Art_i + dart
    Sin - Rate * dart
    Vice - Rate * dart
    
iff in range int256

    Rate
    Rate * dart
```

#### manipulating debt and surplus
```
behaviour heal of Vat
interface heal(bytes32 u, bytes32 v, int256 rad)

types

    Dai_v : uint256
    Sin_u : uint256
    Debt  : uint256
    Vice  : uint256

storage

    #Vat.dai(v) |-> Dai_v => Dai_v - rad
    #Vat.sin(u) |-> Sin_u => Sin_u - rad
    #Vat.debt   |-> Debt  => Debt - rad
    #Vat.vice   |-> Vice  => Vice - rad

iff in range uint256

    Dai_v - rad
    Sin_u - rad
    Debt - rad
    Vice - rad
```

#### applying interest to an `ilk`
```
behaviour fold of Vat
interface fold(bytes32 ilk, bytes32 vow, int256 rate)

types

    Rate  : uint256
    Dai   : uint256
    Art_i : uint256
    Debt  : uint256

storage

    #Vat.ilks(ilk).rate |-> Rate => Rate + rate
    #Vat.ilks(ilk).Art  |-> Art_i
    #Vat.dai(vow)       |-> Dai  => Dai + Art_i * rate
    #Vat.debt           |-> Debt => Debt + Art_i * rate

iff in range uint256

    Rate + rate
    Dai + Art_i * rate
    Debt + Art_i * rate
    
iff in range int256

    Art_i
    Art_i * rate
```

# frob

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of Pit
interface vat()

types

    Vat : address VatLike

storage

    #Pit.vat |-> Vat

returns Vat
```

#### global debt ceiling
```
behaviour Line of Pit
interface Line()

types

    Line : uint256

storage

    #Pit.Line |-> Line

returns Line
```

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

#### `ilk` data
```
behaviour ilks of Pit
interface ilks(bytes32 ilk)

types

    Spot_i : uint256
    Line_i : uint256

storage

    #Pit.ilks(ilk).spot |-> Spot_i
    #Pit.ilks(ilk).line |-> Line_i

returns

    Spot_i : Line_i
```

### Mutators

#### setting `ilk` data
```
behaviour file-ilk of Pit
interface file(bytes32 ilk, bytes32 what, uint256 risk)

types

    Spot_i : uint256
    Line_i : uint256

storage

    #Pit.ilks(ilk).spot |-> Spot_i => #if (what == 52214633679529120849900229181229190823836184335472955378023737308807130251264) #then risk #else Spot_i #fi
    #Pit.ilks(ilk).line |-> Line_i => #if (what == 49036068503847260643156492622631591831542628249327578363867825373603329736704) #then risk #else Line_i #fi
```

#### setting the global debt ceiling
```
behaviour file-line of Pit
interface file(bytes32 what, uint256 risk)

types

    Line : uint256

storage

    #Pit.Line |-> Line => #if (what == 34562057349182736215210119496545603349883880166122507858935627372614188531712) #then risk #else Line #fi
```

#### manipulating a position

```
behaviour frob of Pit
interface frob(bytes32 ilk, int256 dink, int256 dart)

types

    Live   : bool
    Line   : uint256
    Vat    : address VatLike
    Spot   : uint256
    Line_i : uint256
    Gem_u  : uint256
    Ink_u  : uint256
    Art_u  : uint256
    Art_i  : uint256
    Rate   : uint256
    Dai    : uint256
    Debt   : uint256

storage

    #Pit.live           |-> Live
    #Pit.Line           |-> Line
    #Pit.vat            |-> Vat
    #Pit.ilks(ilk).line |-> Line_i
    #Pit.ilks(ilk).spot |-> Spot

storage VatLike

    #Vat.gem(ilk, CALLER_ID)      |-> Gem_u  => Gem_u - dink
    #Vat.urns(ilk, CALLER_ID).ink |-> Ink_u  => Ink_u + dink
    #Vat.urns(ilk, CALLER_ID).art |-> Art_u  => Art_u + dart
    #Vat.ilks(ilk).rate           |-> Rate
    #Vat.ilks(ilk).Art            |-> Art_i  => Art_i + dart
    #Vat.dai(CALLER_ID)           |-> Dai    => Dai + Rate * dart
    #Vat.debt                     |-> Debt   => debt + Rate * dart

iff

    Rate =/= 0
    (((((Art_u + dart) * Rate) <= #wad2rad(Spot)) and (((debt + (Rate * dart))) < #wad2rad(Line))) or (dart <= 0))
    (((dart <= 0) and (dink >= 0)) or (((Ink_u + dink) * Spot) >= ((Art_u + dart) * Rate)))
    Live == 1

iff in range uint256

    Gem_u - dink
    Ink_u + dink
    Art_u + dart
    Art_i + dart
    Dai + (Rate * dart)
    debt + (Rate * dart)
    (Art_u + dart) * Rate
    (Ink_u + dink) * Spot
    #wad2rad(Spot)
    #wad2rad(Line)
    
iff in range int256

    Rate
    Rate * dart
```

# heal

## Specification of behaviours

### Accessors

#### getting the time
```
behaviour era of Vow
interface era()
    
returns TIME
```

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
    Dai : uint256

storage

    #Vow.vat |-> Vat

storage VatLike

    #Vat.dai(ACCT_ID) |-> Dai
    
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

#### cancelling bad debt and surplus
```
behaviour heal of Vow
interface heal(uint256 wad)

types

    Vat  : address VatLike
    Woe  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    #Vow.vat |-> Vat
    #Vow.Woe |-> Woe - wad

storage VatLike

    #Vat.dai(ACCT_ID) |-> Dai  => Dai - #wad2rad(wad)
    #Vat.sin(ACCT_ID) |-> Sin  => Sin - #wad2rad(wad)
    #Vat.vice         |-> Vice => Vice - #wad2rad(wad)
    #Vat.debt         |-> Debt => Debt - #wad2rad(wad)

iff

    wad <= Dai / 1000000000000000000000000000
    wad <= Woe

iff in range uint256

    Woe - wad
    Dai - #wad2rad(wad)
    Sin - #wad2rad(wad)
    Vice - #wad2rad(wad)
    Debt - #wad2rad(wad)
    
iff in range int256

    #wad2rad(wad)
```

```
behaviour kiss of Vow
interface kiss(uint256 wad)

types

    Vat  : address VatLike
    Woe  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    #Vow.vat |-> Vat
    #Vow.Ash |-> Ash - wad

storage VatLike

    #Vat.dai(ACCT_ID) |-> Dai  => Dai - #wad2rad(wad)
    #Vat.sin(ACCT_ID) |-> Sin  => Sin - #wad2rad(wad)
    #Vat.vice         |-> Vice => Vice - #wad2rad(wad)
    #Vat.debt         |-> Debt => Debt - #wad2rad(wad)

iff

    wad <= Dai / 1000000000000000000000000000
    wad <= Ash

iff in range uint256

    Ash - wad
    Dai - #wad2rad(wad)
    Sin - #wad2rad(wad)
    Vice - #wad2rad(wad)
    Debt - #wad2rad(wad)
    
iff in range int256

    #wad2rad(wad)
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
    #Vow.Sin       |-> Sin     => Sin + tab
    
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
    #Vow.Sin       |-> Sin      => Sin - Sin_era_
    #Vow.Woe       |-> Woe      => Woe + Sin_era_

iff in range uint256

    Sin - Sin_era_
    Woe + Sin_era_
```

#### starting a debt auction
```
behaviour flop of Vow
interface flop()

types

    Row   : address Floppy
    Vat   : address VatLike
    Lump  : uint256
    Woe   : uint256
    Ash   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : uint256
    
storage

    #Vow.row  |-> Row
    #Vow.lump |-> Lump
    #Vow.Woe  |-> Woe => Woe - Lump
    #Vow.Ash  |-> Ash => Ash + Lump
    
storage Floppy

    #Flopper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flopper.kicks                       |-> Kicks => Kicks + 1
    #Flopper.bids(Kicks + 1).bid         |-> _ => Lump
    #Flopper.bids(Kicks + 1).lot         |-> _ => pow256 - 1
    #Flopper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flopper.bids(Kicks + 1).vow         |-> _ => ACCT_ID
    
storage VatLike

    #Vat.dai(ACCT_ID) |-> Dai
    
iff

    Dai == 0
    
iff in range uint256

    Woe - Lump
    Ash + Lump
    
returns Kicks + 1
```

#### starting a surplus auction
```
behaviour flap of Vow
interface flap()

types

    Cow   : address Flappy
    Vat   : address VatLike
    Lump  : uint256
    Pad   : uint256
    Woe   : uint256
    Ash   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : uint256
    
storage

    #Vow.cow  |-> Cow
    #Vow.lump |-> Lump
    #Vow.pad  |-> Pad
    #Vow.Sin  |-> Sin
    #Vow.Woe  |-> Woe
    #Vow.Ash  |-> Ash
    
storage Flappy

    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks => Kicks + 1
    #Flapper.bids(Kicks + 1).bid         |-> _ => 0
    #Flapper.bids(Kicks + 1).lot         |-> _ => Lump
    #Flapper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flapper.bids(Kicks + 1).gal         |-> _ => ACCT_ID
    
storage VatLike

    #Vat.dai(ACCT_ID) |-> Dai

iff

    Dai / 1000000000000000000000000000 >= Sin + Woe + Ash + Lump + Pad
    Woe == 0
    
iff in range uint256

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

    Vat     : address VatLike
    Pit     : address PitLike
    Vow     : address VowLike
    Nflip   : uint256
    Rate    : uint256
    Art_i   : uint256
    Ink_u   : uint256
    Art_u   : uint256
    Sin_v   : uint256
    Vice    : uint256
    Sin     : uint256
    Sin_era : uint256
    
storage

    #Cat.vat              |-> Vat
    #Cat.pit              |-> Pit
    #Cat.vow              |-> Vow
    #Cat.nflip            |-> Nflip => Nflip + 1
    #Cat.flips(Nflip).ilk |-> 0     => ilk
    #Cat.flips(Nflip).lad |-> 0     => guy
    #Cat.flips(Nflip).ink |-> 0     => Ink_u
    #Cat.flips(Nflip).tab |-> 0     => Rate * Art_u
    
storage VatLike

    #Vat.ilks(ilk).rate     |-> Rate
    #Vat.ilks(ilk).Art      |-> Art_i => Art_i - Art_u
    #Vat.urns(ilk, guy).ink |-> Ink_u => 0
    #Vat.urns(ilk, guy).art |-> Art_u => 0
    #Vat.sin(Vow)           |-> Sin_v => Sin_v - Rate * Art_u
    #Vat.vice               |-> Vice  => Vice - Rate_* Art_u

storage PitLike

    #Pit.ilks(ilk).spot |-> Spot_i
    
storage VowLike

    #Vow.sin(TIME) |-> Sin_era => Sin_era + Art_u * Rate
    #Vow.Sin       |-> Sin     => Sin + Art_u * Rate
    
iff

    Ink_u * Spot_i < Art_u * Rate

iff in range int256

    Rate
    Rate * (0 - Art_u)

iff in range uint256

    Art_i - Art_u
    Sin_v - Rate * Art_u
    Vice - Rate * Art_u
    Sin_era + Art_u * Rate
    Sin + Art_u * Rate

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
    Flip  : address Flippy
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
    
storage Flippy

    #Flipper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flipper.kicks                       |-> Kicks => Kicks + 1
    #Flipper.bids(Kicks + 1).bid         |-> _ => 0
    #Flipper.bids(Kicks + 1).lot         |-> _ => (Ink * wad) / Tab
    #Flipper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flipper.bids(Kicks + 1).lad         |-> _ => Lad
    #Flipper.bids(Kicks + 1).gal         |-> _ => Vow
    #Flipper.bids(Kicks + 1).tab         |-> _ => (wad * Chop) /Int 1000000000000000000000000000)

iff

    wad <= Tab
    (wad == Lump) or ((wad < Lump) and (wad == Tab))

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

    Vat : address VatLike

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
    Gem         : address
    Wad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #Adapter.vat |-> Vat
    #Adapter.ilk |-> Ilk
    #Adapter.gem |-> Gem

storage VatLike

    #Vat.gem(Ilk, CALLER_ID) |-> Wad => Wad + wad
    
storage GemLike

    #Gem.balances(CALLER_ID) |-> Bal_guy     => Bal_guy - wad
    #Gem.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter + wad
    
iff in range int256

    wad

iff in range uint256

    Wad + wad
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
    Gem         : address
    Wad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #Adapter.vat |-> Vat
    #Adapter.ilk |-> Ilk
    #Adapter.gem |-> Gem

storage VatLike

    #Vat.gem(Ilk, CALLER_ID) |-> Wad => Wad - wad
    
storage GemLike

    #Gem.balances(CALLER_ID) |-> Bal_guy     => Bal_guy + wad
    #Gem.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter - wad

iff in range uint256

    Wad - wad
    Bal_guy + wad
    Bal_adapter - wad
```
