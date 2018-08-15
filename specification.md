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

    #Vat.dai(lad) |-> Rad

returns Rad
```

#### internal sin balances
```
behaviour sin of Vat
interface sin(address lad)

types

    Rad : int256

storage

    #Vat.sin(lad) |-> Rad

returns Rad
```

#### `ilk` data
```
behaviour ilks of Vat
interface ilks(bytes32 ilk)

types

    Rate : int256
    Art_i  : int256

storage

    #Vat.ilks(ilk).rate |-> Rate
    #Vat.ilks(ilk).Art |-> Art_i

returns Rate : Art_i
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

    #Vat.urns(ilk, lad).gem |-> Gem
    #Vat.urns(ilk, lad).ink |-> Ink
    #Vat.urns(ilk, lad).art |-> Art_u

returns Gem : Ink : Art_u
```

#### total debt
```
behaviour Tab of Vat
interface Tab()

types

    Tab : int256

storage

    #Vat.Tab |-> Tab

returns Tab
```

#### total bad debt
```
behaviour vice of Vat
interface vice()

types

    Vice : int256

storage

    #Vat.vice |-> Vice

returns Vice
```
### Mutators

#### setting `ilk` data
```
behaviour file of Vat
interface file(bytes32 ilk, bytes32 what, int256 risk)

types

    Rate : int256

storage

    #Vat.ilks(ilk).rate |-> Rate => (#if what ==Int 5173585222930671264214249581230194498587973835040735715419697062432379555020 #then risk #else Rate #fi)
```

#### transferring dai balances
```
behaviour move-uint of Vat
interface move(address src, address dst, uint256 wad)

types

    Dai_src : int256
    Dai_dst : int256

storage

    #Vat.dai(src) |-> Dai_src => (Dai_src - #wad2rad(wad))
    #Vat.dai(dst) |-> Dai_dst => (Dai_dst + #wad2rad(wad))

iff

    Dai_src - #wad2rad(wad) >= 0
    Dai_dst + #wad2rad(wad) >= 0

iff in range int256

    wad
    Dai_src - #wad2rad(wad) : int256
    Dai_dst + #wad2rad(wad) : int256
```

```
behaviour move-int of Vat
interface move(address src, address dst, int256 wad)

types

    Dai_src : int256
    Dai_dst : int256

storage

    #Vat.dai(src) |-> Dai_src => (Dai_src - #wad2rad(wad))
    #Vat.dai(dst) |-> Dai_dst => (Dai_dst + #wad2rad(wad))

iff

    Dai_src - #wad2rad(wad) >= 0
    Dai_dst + #wad2rad(wad) >= 0

iff in range int256

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

    #Vat.urns(ilk, guy).gem |-> Wad => Wad + wad

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

    #Vat.urns(ilk, lad).gem |-> Gem_u  => Gem_u - dink
    #Vat.urns(ilk, lad).ink |-> Ink_u  => Ink_u + dink
    #Vat.urns(ilk, lad).art |-> Art_u  => Art_u + dart
    #Vat.ilks(ilk).rate     |-> Rate_i
    #Vat.ilks(ilk).Art      |-> Art_i  => Art_i + dart
    #Vat.dai(lad)           |-> Dai    => Dai + (Rate_i * dart)
    #Vat.Tab                |-> Tab    => Tab + (Rate_i * dart)

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

####

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

    #Vat.urns(ABI_ilk, ABI_lad).ink |-> Ink   => Ink + dink
    #Vat.urns(ABI_ilk, ABI_lad).art |-> Art_u => Art_u + dart
    #Vat.ilks(ABI_ilk).rate         |-> Rate
    #Vat.ilks(ABI_ilk).Art          |-> Art_i => Art_i + dart
    #Vat.sin(ABI_vow)               |-> Sin   => Sin + Rate * dart
    #Vat.vice                       |-> Vice  => Vice + Rate * dart


iff in range int256

    Ink + dink
    Art_u + dart
    Art_i + dart
    Rate * dart
    Sin + Rate * dart
    Vice + Rate * dart
```

```
behaviour heal of Vat
interface heal(address u, address v, int256 wad)

types

    Dai_v : int256
    Sin_u : int256
    Tab   : int256
    Vice  : int256

storage

    #Vat.dai(v) |-> Dai_v => Dai_v - #wad2rad(wad)
    #Vat.sin(u) |-> Sin_u => Sin_u - #wad2rad(wad)
    #Vat.Tab    |-> Tab   => Tab - #wad2rad(wad)
    #Vat.vice   |-> Vice  => Vice - #wad2rad(wad)

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

```
behaviour fold of Vat
interface fold(bytes32 ilk, address vow, int256 rate)

types

    Rate  : int256
    Dai   : int256
    Art_i : int256
    Tab   : int256

storage

    #Vat.ilks(ilk).rate |-> Rate => Rate + rate
    #Vat.ilks(ilk).Art  |-> Art
    #Vat.dai(vow)       |-> Dai => Dai + Art_i * rate
    #Vat.Tab            |-> Tab => Tab + Art_i * rate

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

    #Pit.Line |-> Line

returns Line
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

    #Pit.ilks(ilk).spot |-> Spot_i
    #Pit.ilks(ilk).line |-> Line_i

returns

    Spot_i : Line_i
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

    #Pit.ilks(ilk).spot |-> Spot_i => #if (what == 52214633679529120849900229181229190823836184335472955378023737308807130251264) #then risk #else Spot_i #fi
    #Pit.ilks(ilk).line |-> Line_i => #if (what == 49036068503847260643156492622631591831542628249327578363867825373603329736704) #then risk #else Line_i #fi
```

#### setting the global debt ceiling
```
behaviour file-line of Pit
interface file(bytes32 what, int256 risk)

types

    Line : int256

storage

    #Pit.Line |-> Line => #if (what == 34562057349182736215210119496545603349883880166122507858935627372614188531712) #then risk #else Line #fi
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
    #Pit.Line           |-> Line
    #Pit.vat            |-> Vat
    #Pit.ilks(ilk).line |-> Line_i
    #Pit.ilks(ilk).spot |-> Spot_i

storage Vat

    #Vat.urns(ilk, CALLER_ID).gem |-> Gem_u => Gem_u - dink
    #Vat.urns(ilk, CALLER_ID).ink |-> Ink_u => Ink_u + dink
    #Vat.urns(ilk, CALLER_ID).art |-> Art_u => Art_u + dart
    #Vat.ilks(ilk).rate           |-> Rate_i
    #Vat.ilks(ilk).Art            |-> Art_i => Art_i + dart
    #Vat.dai(CALLER_ID)           |-> Dai => Dai + (Rate_i * dart)
    #Vat.Tab                      |-> Tab => Tab + (Rate_i * dart)

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

### Mutators

# bite

## Specification of behaviours

### Accessors

### Mutators

# join

## Specification of behaviours

### Accessors

### Mutators
