What follows is an executable K specification of the smart contracts of multicollateral dai.

# Vat

## Specification of behaviours

### Accessors

#### owners
```
behaviour wards of Vat
interface wards(address guy)

types

    Can : uint256

storage

    #Vat.wards(guy) |-> Can

returns Can
```

#### collateral type data
```
behaviour ilks of Vat
interface ilks(bytes32 ilk)

types

    Take  : uint256
    Rate  : uint256
    Ink_i : uint256
    Art_i : uint256

storage

    #Vat.ilks(ilk).take |-> Take
    #Vat.ilks(ilk).rate |-> Rate
    #Vat.ilks(ilk).Ink  |-> Ink_i
    #Vat.ilks(ilk).Art  |-> Art_i

returns Take : Rate : Ink_i : Art_i
```

#### `urn` data
```
behaviour urns of Vat
interface urns(bytes32 ilk, bytes32 urn)

types

    Ink_u : uint256
    Art_u : uint256

storage

    #Vat.urns(ilk, urn).ink |-> Ink_u
    #Vat.urns(ilk, urn).art |-> Art_u

returns Ink_u : Art_u
```

#### internal unencumbered collateral balances
```
behaviour gem of Vat
interface gem(bytes32 ilk, bytes32 urn)

types

    Gem : uint256

storage

    #Vat.gem(ilk, urn) |-> Gem

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

#### adding and removing owners
```
behaviour rely of Vat
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.wards(guy)       |-> Could => 1

iff

    Can == 1
```

```
behaviour deny of Vat
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.wards(guy)       |-> Could => 0

iff

    Can == 1
```

#### initialising an `ilk`
```
behaviour init of Vat
interface init(bytes32 ilk)

types

    Can  : uint256
    Rate : uint256
    Take : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.ilks(ilk).rate   |-> Rate => 1000000000000000000000000000
    #Vat.ilks(ilk).take   |-> Take => 1000000000000000000000000000

iff

    Can == 1
    Rate == 0
    Take == 0
```

#### assigning unencumbered collateral
```
behaviour slip of Vat
interface slip(bytes32 ilk, bytes32 guy, int256 wad)

types

    Can : uint256
    Gem : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.gem(ilk, guy)    |-> Gem => Gem + wad

iff

    Can == 1

iff in range uint256

    Gem + wad
```

#### moving unencumbered collateral
```
behaviour flux of Vat
interface flux(bytes32 ilk, bytes32 src, bytes32 dst, int256 wad)

types

    Can     : uint256
    Gem_src : uint256
    Gem_dst : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.gem(ilk, src)    |-> Gem_src => Gem_src - wad
    #Vat.gem(ilk, dst)    |-> Gem_dst => Gem_dst + wad

iff

    Can == 1

iff in range uint256

    Gem_src - wad
    Gem_dst + wad
```

#### transferring dai balances
```
behaviour move of Vat
interface move(bytes32 src, bytes32 dst, int256 rad)

types

    Can     : uint256
    Dai_src : uint256
    Dai_dst : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.dai(src)         |-> Dai_src => Dai_src - rad
    #Vat.dai(dst)         |-> Dai_dst => Dai_dst + rad

iff

    Can == 1
    
iff in range uint256

    Dai_src - rad
    Dai_dst + rad
```

#### administering a position

```
behaviour tune of Vat
interface tune(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Can   : uint256
    Take  : uint256
    Rate  : uint256
    Ink_u : uint256
    Art_u : uint256
    Ink_i : uint256
    Art_i : uint256
    Gem_v : uint256
    Dai_w : uint256
    Debt  : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.ilks(i).take     |-> Take
    #Vat.ilks(i).rate     |-> Rate
    #Vat.urns(i, u).ink   |-> Ink_u  => Ink_u + dink
    #Vat.urns(i, u).art   |-> Art_u  => Art_u + dart
    #Vat.ilks(i).Ink      |-> Ink_i  => Ink_i + dink
    #Vat.ilks(i).Art      |-> Art_i  => Art_i + dart
    #Vat.gem(i, v)        |-> Gem_v  => Gem_v - (Take * dink)
    #Vat.dai(w)           |-> Dai_w  => Dai_w + (Rate * dart)
    #Vat.debt             |-> Debt   => Debt + (Rate * dart)

iff

    Can == 1

iff in range uint256

    Ink_u + dink
    Art_u + dart
    Ink_i + dink
    Art_i + dart
    Gem_v - (Take * dink)
    Dai_w + (Rate * dart)
    Debt + (Rate * dart)
    
iff in range int256

    Take
    Take * dink
    Rate
    Rate * dart
```

#### confiscating a position

```
behaviour grab of Vat
interface grab(bytes32 i, bytes32 u, bytes32 v, bytes32 w, int256 dink, int256 dart)

types

    Can   : uint256
    Take  : uint256
    Rate  : uint256
    Ink_u : uint256
    Art_u : uint256
    Ink_i : uint256
    Art_i : uint256
    Gem_v : uint256
    Sin_w : uint256
    Vice  : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.ilks(i).take     |-> Take
    #Vat.ilks(i).rate     |-> Rate
    #Vat.urns(i, u).ink   |-> Ink_u  => Ink_u + dink
    #Vat.urns(i, u).art   |-> Art_u  => Art_u + dart
    #Vat.ilks(i).Ink      |-> Ink_i  => Ink_i + dink
    #Vat.ilks(i).Art      |-> Art_i  => Art_i + dart
    #Vat.gem(i, v)        |-> Gem_v  => Gem_v - (Take * dink)
    #Vat.sin(w)           |-> Sin_w  => Sin_w + (Rate * dart)
    #Vat.vice             |-> Vice   => Vice + (Rate * dart)

iff

    Can == 1

iff in range uint256

    Ink_u + dink
    Art_u + dart
    Ink_i + dink
    Art_i + dart
    Gem_v - (Take * dink)
    Sin_w + (Rate * dart)
    Vice + (Rate * dart)
    
iff in range int256

    Take
    Take * dink
    Rate
    Rate * dart
```

#### manipulating bad debt and surplus
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

#### applying interest to an `ilk`
```
behaviour fold of Vat
interface fold(bytes32 i, bytes32 u, int256 rate)

types

    Can   : uint256
    Rate  : uint256
    Dai   : uint256
    Art_i : uint256
    Debt  : uint256

storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.ilks(i).rate     |-> Rate => Rate + rate
    #Vat.ilks(i).Art      |-> Art_i
    #Vat.dai(u)           |-> Dai  => Dai + Art_i * rate
    #Vat.debt             |-> Debt => Debt + Art_i * rate

iff

    Can == 1

iff in range uint256

    Rate + rate
    Dai + Art_i * rate
    Debt + Art_i * rate
    
iff in range int256

    Art_i
    Art_i * rate
```

#### applying collateral adjustment to an `ilk`
```
behaviour toll of Vat
interface toll(bytes32 i, bytes32 u, int256 take) 

types

    Can  : uint256
    Take : uint256
    Ink  : uint256
    Gem  : uint256
    
storage

    #Vat.wards(CALLER_ID) |-> Can
    #Vat.ilks(i).take     |-> Take => Take + take
    #Vat.ilks(i).Ink      |-> Ink
    #Vat.gem(i, u)        |-> Gem => Gem - (Ink * take)

iff

    Can == 1

iff in range uint256

    Take + take
    Gem - (Ink * take)

iff in range int256

    Ink
    Ink * take
```

# Drip

## Specification of behaviours

### Accessors

#### owners

```
behaviour wards of Drip
interface wards(address guy)

types

    Can : uint256

storage

    #Drip.wards(guy) |-> Can

returns Can
```

#### `ilk` data

```
behaviour ilks of Drip
interface ilks(bytes32 ilk)

types

    Vow : bytes32
    Tax : uint256
    Rho : uint48

storage

    #Drip.ilks(ilk).vow |-> Vow
    #Drip.ilks(ilk).tax |-> Tax
    #Drip.ilks(ilk).rho |-> Rho

returns Vow : Tax : Rho
```

#### getting the time
```
behaviour era of Drip
interface era()
    
returns TIME
```


### Mutators

#### adding and removing owners
```
behaviour rely of Drip
interface rely(address guy)

types

    Can   : uint256
    Could : uint256

storage

    #Drip.wards(CALLER_ID) |-> Can
    #Drip.wards(guy)       |-> Could => 1

iff

    Can == 1

behaviour deny of Drip
interface deny(address guy)

types

    Can   : uint256
    Could : uint256

storage

    #Drip.wards(CALLER_ID) |-> Can
    #Drip.wards(guy)       |-> Could => 0

iff

    Can == 1
```

#### initialising an `ilk`

```
behaviour init of Drip
interface init(bytes32 ilk)

types

    Tax : uint256
    Rho : uint48

storage

    #Drip.ilks(ilk).tax |-> Tax => #Ray
    #Drip.ilks(ilk).rho |-> Rho => TIME

iff

    Tax == 0
```

#### setting `ilk` data

```
behaviour file of Drip
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Tax : uint256

storage

    #Drip.ilks(ilk).tax |-> Tax => (#if what == 12345 #then data #else Tax #fi)

iff

    #Drip.ilks(ilk).rho == TIME
```

#### setting the base rate
```
behaviour file-repo of Drip
interface file(bytes32 what, uint256 data)

types

    Repo : uint256

storage

    #Drip.repo |-> Repo => (#if what == 12345 #then data #else Repo #fi)
```

#### setting the `vow`
```
behaviour file-vow of Drip
interface file(bytes32 what, bytes32 data)

types

    Vow : bytes32

storage

    #Drip.vow |-> Vow => (#if what == 12345 #then data #else Vow #fi)
```

#### updating the rates
```
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

    #Drip.repo          |-> Repo
    #Drip.ilks(ilk).vow |-> Vow
    #Drip.ilks(ilk).tax |-> Tax
    #Drip.ilks(ilk).rho |-> Rho => TIME

storage Vat

    #Vat.wards(ADDRESS) |-> Can
    #Vat.ilks(ilk).rate |-> Rate => Rate + (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    #Vat.ilks(i).Art    |-> Art_i
    #Vat.dai(u)         |-> Dai  => Dai + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    #Vat.debt           |-> Debt => Debt + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)

iff

    Can == 1
    TIME >= Rho

iff in range uint256

    Repo + Tax
    #rpow(Repo + Tax, TIME - Rho, #Ray) * #Ray
    #rpow(Repo + Tax, TIME - Rho, #Ray) * Rate
    Rate + (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    Dai + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
    Debt + Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)

iff in range int256

    Art_i
    #rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate
    Art_i * (#rmul(#rpow(Repo + Tax, TIME - Rho, #Ray), Rate) - Rate)
```

# Pit

## Specification of behaviours

### Accessors

#### owners
```
behaviours wards of Pit
interface wards(address guy)

types

    Can : uint256

storage

    #Pit.wards(guy) |-> Can

returns Can
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

#### liveness
```
behaviour live of Pit
interface live()

types

    Live : uint256

storage

    #Pit.live |-> Live

returns Live
```

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

#### `drip` address
```
behaviour drip of Pit
interface drip()

types

    Drip : address Dripper

storage

    #Pit.drip |-> Drip

returns Drip
```

### Mutators

#### adding and removing owners
```
behaviour rely of Pit
interface rely(address guy)

types

    Can : uint256

storage

    #Pit.wards(CALLER_ID) |-> Can
    #Pit.wards(guy)       |-> _ => 1

iff

    Can == 1

behaviour deny of Pit
interface deny(address guy)

types

    Can : uint256

storage

    #Pit.wards(CALLER_ID) |-> Can
    #Pit.wards(guy)       |-> _ => 0

iff

    Can == 1
```

#### setting `drip` address
```
behaviour file-drip of Pit
interface file(bytes32 what, address who)

types

    Can    : uint256
    Drip   : address

storage

    #Pit.wards(CALLER_ID) |-> Can
    #Pit.drip             |-> Drip => (#if (what == 123) #then Drip #else who #fi)

iff

    Can == 1
```

#### setting `ilk` data
```
behaviour file-ilk of Pit
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Can    : uint256
    Spot_i : uint256
    Line_i : uint256

storage

    #Pit.wards(CALLER_ID) |-> Can
    #Pit.ilks(ilk).spot   |-> Spot_i => #if (what == 52214633679529120849900229181229190823836184335472955378023737308807130251264) #then data #else Spot_i #fi
    #Pit.ilks(ilk).line   |-> Line_i => #if (what == 49036068503847260643156492622631591831542628249327578363867825373603329736704) #then data #else Line_i #fi

iff

    Can == 1
```

#### setting the global debt ceiling
```
behaviour file-Line of Pit
interface file(bytes32 what, uint256 data)

types

    Can  : uint256
    Line : uint256

storage

    #Pit.wards(CALLER_ID) |-> Can
    #Pit.Line             |-> Line => #if (what == 34562057349182736215210119496545603349883880166122507858935627372614188531712) #then data #else Line #fi

iff

    Can == 1
```

#### manipulating a position

```
behaviour frob of Pit
interface frob(bytes32 ilk, int256 dink, int256 dart)

types

    Live   : uint256
    Line   : uint256
    Vat    : address VatLike
    Spot   : uint256
    Line_i : uint256
    Ink_i  : uint256
    Art_i  : uint256
    Ink_u  : uint256
    Art_u  : uint256
    Take   : uint256
    Rate   : uint256
    Gem_u  : uint256
    Dai    : uint256
    Debt   : uint256

storage

    #Pit.live           |-> Live
    #Pit.Line           |-> Line
    #Pit.vat            |-> Vat
    #Pit.ilks(ilk).line |-> Line_i
    #Pit.ilks(ilk).spot |-> Spot

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.ilks(ilk).take           |-> Take
    #Vat.ilks(ilk).rate           |-> Rate
    #Vat.ilks(ilk).Ink            |-> Ink_i  => Ink_i + dink
    #Vat.ilks(ilk).Art            |-> Art_i  => Art_i + dart
    #Vat.urns(ilk, CALLER_ID).ink |-> Ink_u  => Ink_u + dink
    #Vat.urns(ilk, CALLER_ID).art |-> Art_u  => Art_u + dart
    #Vat.gem(ilk, CALLER_ID)      |-> Gem_u  => Gem_u - Take * dink
    #Vat.dai(CALLER_ID)           |-> Dai    => Dai + Rate * dart
    #Vat.debt                     |-> Debt   => Debt + Rate * dart

iff

    Can == 1
    Rate =/= 0
    (((((Art_u + dart) * Rate) <= (#Ray * Spot)) and (((Debt + (Rate * dart))) < (#Ray * Line))) or (dart <= 0))
    (((dart <= 0) and (dink >= 0)) or (((Ink_u + dink) * Spot) >= ((Art_u + dart) * Rate)))
    Live == 1

iff in range uint256

    Ink_i + dink
    Art_i + dart
    Ink_u + dink
    Art_u + dart
    Gem_u - Take * dink
    Dai + (Rate * dart)
    Debt + (Rate * dart)
    (Art_u + dart) * Rate
    (Ink_u + dink) * Spot
    #Ray * Spot
    #Ray * Line
    
iff in range int256

    Take
    Take * dink
    Rate
    Rate * dart
```

# Vow

## Specification of behaviours

### Accessors

#### owners
```
behaviours wards of Vow
interface wards(address guy)

types

    Can : uint256

storage

    #Vow.wards(guy) |-> Can

returns Can
```

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

#### getting the `sump`
```
behaviour sump of Vow
interface sump()

types

    Sump : uint256
    
storage

    #Vow.sump |-> Sump
    
returns Sump
```

#### getting the `bump`
```
behaviour bump of Vow
interface bump()

types

    Bump : uint256
    
storage

    #Vow.bump |-> Bump
    
returns Bump
```

#### getting the `hump`
```
behaviour hump of Vow
interface hump()

types

    Hump : uint256
    
storage

    #Vow.hump |-> Hump
    
returns Hump
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

storage Vat

    #Vat.dai(ACCT_ID) |-> Dai
    
returns Dai / 1000000000000000000000000000
```

### Mutators

#### adding and removing owners
```
behaviour rely of Vow
interface rely(address guy)

types

    Can : uint256

storage

    #Vow.wards(CALLER_ID) |-> Can
    #Vow.wards(guy)       |-> _ => 1

iff

    Can == 1

behaviour deny of Vow
interface deny(address guy)

types

    Can : uint256

storage

    #Vow.wards(CALLER_ID) |-> Can
    #Vow.wards(guy)       |-> _ => 0

iff

    Can == 1
```


#### setting `Vow` parameters
```
behaviour file-data of Vow
interface file(bytes32 what, uint256 data)

types

    Can  : uint256
    Sump : uint256
    Bump : uint256
    Hump : uint256

storage

    #Vow.wards(CALLER_ID) |-> Can
    #Vow.sump             |-> Sump => (#if what == 12345 #then data #else Sump #fi)
    #Vow.bump             |-> Bump => (#if what == 12345 #then data #else Bump #fi)
    #Vow.hump             |-> Hump => (#if what == 67890 #then data #else Hump #fi)
    
iff

    Can == 1
```

#### setting vat and liquidators
```
behaviour file-addr of Vow
interface file(bytes32 what, address addr)

types

    Can : uint256
    Cow : address
    Row : address
    Vat : address

storage

    #Vow.wards(CALLER_ID) |-> Can
    #Vow.cow              |-> Cow => (#if what == 12345 #then addr #else Cow #fi)
    #Vow.row              |-> Row => (#if what == 67890 #then addr #else Row #fi)
    #Vow.vat              |-> Vat => (#if what == 54321 #then addr #else Vat #fi)
    
iff

    Can == 1
```

#### cancelling bad debt and surplus
```
behaviour heal of Vow
interface heal(uint256 wad)

types

    Can  : uint256
    Vat  : address VatLike
    Woe  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    #Vow.vat |-> Vat
    #Vow.Woe |-> Woe => Woe - wad

storage Vat
    
    #Vat.wards(ACCT_ID) |-> Can
    #Vat.dai(ACCT_ID)   |-> Dai  => Dai - #Ray * wad
    #Vat.sin(ACCT_ID)   |-> Sin  => Sin - #Ray * wad
    #Vat.vice           |-> Vice => Vice - #Ray * wad
    #Vat.debt           |-> Debt => Debt - #Ray * wad

iff

    Can == 1
    wad <= Dai / 1000000000000000000000000000
    wad <= Woe

iff in range uint256

    Woe - wad
    Dai - #Ray * wad
    Sin - #Ray * wad
    Vice - #Ray * wad
    Debt - #Ray * wad
    
iff in range int256

    #Ray * wad
```

```
behaviour kiss of Vow
interface kiss(uint256 wad)

types

    Can  : uint256
    Vat  : address VatLike
    Woe  : uint256
    Dai  : uint256
    Sin  : uint256
    Vice : uint256
    Debt : uint256

storage

    #Vow.vat |-> Vat
    #Vow.Ash |-> Ash - wad

storage Vat

    #Vat.wards(ACCT_ID) |-> Can
    #Vat.dai(ACCT_ID) |-> Dai  => Dai - #Ray * wad
    #Vat.sin(ACCT_ID) |-> Sin  => Sin - #Ray * wad
    #Vat.vice         |-> Vice => Vice - #Ray * wad
    #Vat.debt         |-> Debt => Debt - #Ray * wad

iff

    Can == 1
    wad <= Dai / 1000000000000000000000000000
    wad <= Ash

iff in range uint256

    Ash - wad
    Dai - #Ray * wad
    Sin - #Ray * wad
    Vice - #Ray * wad
    Debt - #Ray * wad
    
iff in range int256

    #Ray * wad
```

#### adding to the `sin` queue
```
behaviour fess of Vow
interface fess(uint256 tab)

types

    Can     : uint256
    Sin_era : uint256
    Sin     : uint256
    
storage

    #Vow.wards(CALLER_ID) |-> Can
    #Vow.sin(TIME)        |-> Sin_era => Sin_era + tab
    #Vow.Sin              |-> Sin     => Sin + tab

iff

    Can == 1

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
    Sump  : uint256
    Woe   : uint256
    Ash   : uint256
    Can   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : uint256
    
storage

    #Vow.row  |-> Row
    #Vow.lump |-> Sump
    #Vow.Woe  |-> Woe => Woe - Sump
    #Vow.Ash  |-> Ash => Ash + Sump
    
storage Row

    #Flopper.wards(ACCT_ID)              |-> Can
    #Flopper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flopper.kicks                       |-> Kicks => Kicks + 1
    #Flopper.bids(Kicks + 1).bid         |-> _ => Sump
    #Flopper.bids(Kicks + 1).lot         |-> _ => pow256 - 1
    #Flopper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flopper.bids(Kicks + 1).vow         |-> _ => ACCT_ID
    
storage Vat

    #Vat.dai(ACCT_ID) |-> Dai
    
iff

    Can == 1
    Dai == 0
    
iff in range uint256

    Woe - Sump
    Ash + Sump
    
returns Kicks + 1
```

#### starting a surplus auction
```
behaviour flap of Vow
interface flap()

types

    Cow   : address Flappy
    Vat   : address VatLike
    Bump  : uint256
    Hump   : uint256
    Woe   : uint256
    Ash   : uint256
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Dai   : uint256
    
storage

    #Vow.cow  |-> Cow
    #Vow.lump |-> Bump
    #Vow.hump  |-> Hump
    #Vow.Sin  |-> Sin
    #Vow.Woe  |-> Woe
    #Vow.Ash  |-> Ash
    
storage Cow

    #Flapper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flapper.kicks                       |-> Kicks => Kicks + 1
    #Flapper.bids(Kicks + 1).bid         |-> _ => 0
    #Flapper.bids(Kicks + 1).lot         |-> _ => Bump
    #Flapper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flapper.bids(Kicks + 1).gal         |-> _ => ACCT_ID
    
storage Vat

    #Vat.dai(ACCT_ID)   |-> Dai

iff

    Dai / 1000000000000000000000000000 >= Sin + Woe + Ash + Bump + Hump
    Woe == 0
    
iff in range uint256

    Sin + Woe
    Sin + Woe + Ash
    Sin + Woe + Ash + Bump
    Sin + Woe + Ash + Bump + Hump
    
returns Kicks + 1
```

# Cat

## Specification of behaviours

### Accessors

#### owners
```
behaviours wards of Cat
interface wards(address guy)

types

    Can : uint256

storage

    #Cat.wards(guy) |-> Can

returns Can
```

#### `ilk` data
```
behaviour ilks of Cat
interface ilks(bytes32 ilk)

types

    Chop : uint256
    Flip : address
    Lump : uint256
    
storage

    #Cat.ilks(ilk).chop |-> Chop
    #Cat.ilks(ilk).flip |-> Flip
    #Cat.ilks(ilk).lump |-> Lump
    
returns Chop : Flip : Lump
```

#### liquidation data
```
behaviour flips of Cat
interface flips(uint256 n)

types

    Ilk : bytes32
    Urn : bytes32
    Ink : uint256
    Tab : uint256
    
storage

    #Cat.flips(n).ilk |-> Ilk
    #Cat.flips(n).urn |-> Urn
    #Cat.flips(n).ink |-> Ink
    #Cat.flips(n).tab |-> Tab
    
returns Ilk : Urn : Ink : Tab
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

#### liveness
```
behaviour live of Cat
interface live()

types

    Live : uint256

storage

    #Cat.live |-> Live

returns Live
```

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

### Mutators

#### addingg and removing owners
```
behaviour rely of Cat
interface rely(address guy)

types

    Can : uint256

storage

    #Cat.wards(CALLER_ID) |-> Can
    #Cat.wards(guy)       |-> _ => 1

iff

    Can == 1

behaviour deny of Cat
interface deny(address guy)

types

    Can : uint256

storage

    #Cat.wards(CALLER_ID) |-> Can
    #Cat.wards(guy)       |-> _ => 0

iff

    Can == 1
```

#### setting contract addresses
```
behaviour file-addr of Cat
interface file(bytes32 what, address data)

types

    Can : uint256
    Pit : address
    Vow : address

storage

    #Cat.wards(CALLER_ID) |-> Can
    #Cat.pit              |-> Pit => (#if what == 12345 #then data #else Pit #fi)
    #Cat.vow              |-> Vow => (#if what == 54321 #then data #else Vow #fi)
    
iff

    Can == 1
```

#### setting liquidation data
```
behaviour file of Cat
interface file(bytes32 ilk, bytes32 what, uint256 data)

types

    Can  : uint256
    Chop : uint256
    Lump : uint256

storage

    #Cat.wards(CALLER_ID) |-> Can
    #Cat.ilks(ilk).chop   |-> Chop => (#if what == 12345 #then data #else Chop #fi)
    #Cat.ilks(ilk).lump   |-> Lump => (#if what == 54321 #then data #else Lump #fi)
    
iff

    Can == 1
```

#### setting liquidator address
```
behaviour file-flip of Cat
interface file(bytes32 ilk, bytes32 what, address flip)

types

    Can  : uint256
    Flip : address

storage

    #Cat.wards(CALLER_ID) |-> Can
    #Cat.ilks(ilk).flip   |-> Flip => (#if what == 12345 #then flip #else Flip #fi)
    
iff

    Can == 1
```

#### marking a position for liquidation
```
behaviour bite of Cat
interface bite(bytes32 ilk, address urn)

types

    Vat     : address VatLike
    Pit     : address PitLike
    Vow     : address VowLike
    Nflip   : uint256
    Take    : uint256
    Rate    : uint256
    Art_i   : uint256
    Ink_u   : uint256
    Art_u   : uint256
    Gem_v   : uint256
    Sin_w   : uint256
    Vice    : uint256
    Sin     : uint256
    Sin_era : uint256
    Live    : uint256
    
storage

    #Cat.vat              |-> Vat
    #Cat.pit              |-> Pit
    #Cat.vow              |-> Vow
    #Cat.nflip            |-> Nflip => Nflip + 1
    #Cat.flips(Nflip).ilk |-> 0     => ilk
    #Cat.flips(Nflip).urn |-> 0     => urn
    #Cat.flips(Nflip).ink |-> 0     => Ink_u
    #Cat.flips(Nflip).tab |-> 0     => Rate * Art_u
    #Cat.live             |-> Live

storage Vat

    #Vat.wards(ADDRESS)     |-> Can
    #Vat.ilks(ilk).take     |-> Take
    #Vat.ilks(ilk).rate     |-> Rate
    #Vat.urns(ilk, urn).ink |-> Ink_u => 0
    #Vat.urns(ilk, urn).art |-> Art_u => 0
    #Vat.ilks(ilk).Ink      |-> Ink_i => Ink_i - Ink_u
    #Vat.ilks(ilk).Art      |-> Art_i => Art_i - Art_u
    #Vat.gem(ilk, ADDRESS)  |-> Gem_v => Gem_v + Take * Ink_u
    #Vat.sin(Vow)           |-> Sin_w => Sin_w - Rate * Art_u
    #Vat.vice               |-> Vice  => Vice - Rate_* Art_u

storage Pit

    #Pit.ilks(ilk).spot |-> Spot_i
    
storage Vow

    #Vow.sin(TIME) |-> Sin_era => Sin_era + Art_u * Rate
    #Vow.Sin       |-> Sin     => Sin + Art_u * Rate
    
iff

    Can == 1
    Live == 1
    Ink_u * Spot_i < Art_u * Rate

iff in range int256

    Take
    Rate
    Take * (0 - Ink_u)
    Rate * (0 - Art_u)

iff in range uint256

    Art_i - Art_u
    Sin_w - Rate * Art_u
    Gem_v + Take * Ink_u
    Vice - Rate * Art_u
    Sin_era + Art_u * Rate
    Sin + Art_u * Rate

returns Nflip + 1
```

#### starting a collateral auction
```
behaviour flip of Cat
interface flip(uint256 n, uint256 wad)

types

    Ilk   : bytes32
    Urn   : address
    Ink   : uint256
    Tab   : uint256
    Flip  : address Flippy
    Chop  : uint256
    Lump  : uint256
    Vow   : address
    Ttl   : uint48
    Tau   : uint48
    Kicks : uint256
    Live  : uint256

storage

    #Cat.flips(Nflip).ilk |-> Ilk
    #Cat.flips(Nflip).urn |-> Urn
    #Cat.flips(Nflip).ink |-> Ink => Ink - (Ink * wad) / Tab
    #Cat.flips(Nflip).tab |-> Tab => Tab - wad
    #Cat.ilks(ilk).flip   |-> Flip
    #Cat.ilks(ilk).chop   |-> Chop
    #Cat.ilks(ilk).lump   |-> Lump
    #Cat.vow              |-> Vow
    #Cat.live             |-> Live
    
storage Flip

    #Flipper.ttl_tau                     |-> #WordPackUInt48UInt48(Ttl, Tau)
    #Flipper.kicks                       |-> Kicks => Kicks + 1
    #Flipper.bids(Kicks + 1).bid         |-> _ => 0
    #Flipper.bids(Kicks + 1).lot         |-> _ => (Ink * wad) / Tab
    #Flipper.bids(Kicks + 1).guy_tic_end |-> _ => #WordPackAddrUInt48UInt48(ACCT_ID, 0, TIME + Tau)
    #Flipper.bids(Kicks + 1).urn         |-> _ => Urn
    #Flipper.bids(Kicks + 1).gal         |-> _ => Vow
    #Flipper.bids(Kicks + 1).tab         |-> _ => (wad * Chop) /Int 1000000000000000000000000000)

iff

    Live == 1
    wad <= Tab
    (wad == Lump) or ((wad < Lump) and (wad == Tab))

iff in range uint256

    Ink * wad
    wad * Chop

returns Kicks + 1
```

# GemJoin

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of GemJoin
interface vat()

types

    Vat : address VatLike

storage

    #GemJoin.vat |-> Vat

returns Vat
```

#### the associated `ilk`
```
behaviour ilk of GemJoin
interface ilk()

types

    Ilk : bytes32
    
storage

    #GemJoin.ilk |-> Ilk
    
returns Ilk
```

#### gem address
```
behaviour gem of GemJoin
interface gem()

types

    Gem : address
    
storage

    #GemJoin.gem |-> Gem
    
returns Gem
```

### Mutators

#### depositing into the system
```
behaviour join of GemJoin
interface join(bytes32 urn, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #GemJoin.vat |-> Vat
    #GemJoin.ilk |-> Ilk
    #GemJoin.gem |-> Gem

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.gem(Ilk, urn, CALLER_ID) |-> Rad => Rad + #Ray * wad
    
storage Gem

    #GemLike.balances(CALLER_ID) |-> Bal_guy     => Bal_guy - wad
    #GemLike.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter + wad
    
iff

    Can == 1

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_guy - wad
    Bal_adapter + wad
```

#### withdrawing from the system
```
behaviour exit of GemJoin
interface exit(bytes32 urn, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #GemJoin.vat |-> Vat
    #GemJoin.ilk |-> Ilk
    #GemJoin.gem |-> Gem

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.gem(Ilk, urn, CALLER_ID) |-> Rad => Rad - #Ray * wad

storage Gem

    #GemLike.balances(CALLER_ID) |-> Bal_guy     => Bal_guy + wad
    #GemLike.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter - wad

iff

    Can == 1

iff in range int256

    #Ray * wad

iff in range uint256

    Rad - #Ray * wad
    Bal_guy + wad
    Bal_adapter - wad
```

# ETHJoin

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of ETHJoin
interface vat()

types

    Vat : address VatLike

storage

    #ETHJoin.vat |-> Vat

returns Vat
```

#### the associated `ilk`
```
behaviour ilk of ETHJoin
interface ilk()

types

    Ilk : bytes32
    
storage

    #ETHJoin.ilk |-> Ilk
    
returns Ilk
```

### Mutators

#### depositing into the system

*TODO* : add `balance ACCT_ID` block
```
behaviour join of ETHJoin
interface join(bytes32 urn)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address
    Can         : uint256
    Rad         : uint256
    Bal_adapter : uint256

storage

    #ETHJoin.vat |-> Vat
    #ETHJoin.ilk |-> Ilk

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.gem(Ilk, urn, CALLER_ID) |-> Rad => Rad + #Ray * VALUE

iff

    Can == 1

iff in range int256

    #Ray * VALUE

iff in range uint256

    Rad + #Ray * VALUE
    Bal_adapter + VALUE
```

#### withdrawing from the system

*TODO* : add `balance ACCT_ID` block
```
behaviour exit of ETHJoin
interface exit(bytes32, uint256 wad)

types

    Vat         : address VatLike
    Ilk         : bytes32
    Gem         : address
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256

storage

    #ETHJoin.vat |-> Vat
    #ETHJoin.ilk |-> Ilk
    #ETHJoin.gem |-> Gem

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.gem(Ilk, urn, CALLER_ID) |-> Rad => Rad - #Ray * wad

iff

    Can == 1

iff in range int256

    #Ray * wad

iff in range uint256

    Rad - #Ray * wad
    Bal_guy + wad
```

# DaiJoin

## Specification of behaviours

### Accessors

#### `vat` address
```
behaviour vat of DaiJoin
interface vat()

types

    Vat : address VatLike

storage

    #DaiJoin.vat |-> Vat

returns Vat
```

#### dai address
```
behaviour dai of DaiJoin
interface dai()

types

    Dai : address
    
storage

    #DaiJoin.dai |-> Dai
    
returns Dai
```

### Mutators

#### depositing into the system
```
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

    #DaiJoin.vat |-> Vat
    #DaiJoin.dai |-> Dai

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.dai(Ilk, urn, CALLER_ID) |-> Rad => Rad + #Ray * wad
    
storage Dai

    #GemLike.balances(CALLER_ID) |-> Bal_guy     => Bal_guy - wad
    #GemLike.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter + wad
    
iff

    Can == 1

iff in range int256

    #Ray * wad

iff in range uint256

    Rad + #Ray * wad
    Bal_guy - wad
    Bal_adapter + wad
```

#### withdrawing from the system
```
behaviour exit of DaiJoin
interface exit(bytes32 urn, uint256 wad)

types

    Vat         : address VatLike
    Dai         : address GemLike
    Can         : uint256
    Rad         : uint256
    Bal_guy     : uint256
    Bal_adapter : uint256
    
storage

    #DaiJoin.vat |-> Vat
    #DaiJoin.dai |-> Dai

storage Vat

    #Vat.wards(ACCT_ID)           |-> Can
    #Vat.gem(Ilk, urn, CALLER_ID) |-> Rad => Rad - #Ray * wad

storage Dai

    #GemLike.balances(CALLER_ID) |-> Bal_guy     => Bal_guy + wad
    #GemLike.balances(ACCT_ID)   |-> Bal_adapter => Bal_adapter - wad

iff

    Can == 1

iff in range int256

    #Ray * wad

iff in range uint256

    Rad - #Ray * wad
    Bal_guy + wad
    Bal_adapter - wad
```
