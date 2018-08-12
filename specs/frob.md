# frob

## prelude
```
implementation dss/out/Vat of VatLike
implementation dss/out/Cat of Catlike

vars

    Vat  : VatLike
    Line : int256
    Live : bool

storage

    Pit.vat  |-> Vat
    Pit.Line |-> Line
    Pit.live |-> Live
```
## Specification of Behaviours

### Accessors

#### system liveness
```
behaviour live
interface live()

returns Live
```

#### global debt ceiling
```
behaviour Line
interface Line()

returns Line
```

#### `vat` address
```
behaviour vat
interface vat()

returns Vat
```

#### `ilk` data
```
behaviour ilks
interface ilks(bytes32 ilk)

vars

    Spot_i : int256
    Line_i : int256
    
storage

    Pit.ilks(ilk).spot |-> Spot_i
    Pit.ilks(ilk).line |-> Line_i

returns

    Spot_i : Line_i
```

### Mutators

#### setting `ilk` data
```
behaviour file-ilk
interface file(bytes32 ilk, bytes32 what, int256 risk)

vars

    Spot_i : int256
    Line_i : int256

storage

    Pit.ilks(ilk).spot |-> Spot_i => #if (what == 52214633679529120849900229181229190823836184335472955378023737308807130251264) #then risk #else Spot_i #fi
    Pit.ilks(ilk).line |-> Line_i => #if (what == 49036068503847260643156492622631591831542628249327578363867825373603329736704) #then risk #else Line_i #fi
```

#### setting the global debt ceiling
```
behaviour file-line
interface file(bytes32 what, int256 risk)

vars

    Line : int256
    
storage

    Pit.Line |-> Line => #if (what == 34562057349182736215210119496545603349883880166122507858935627372614188531712) #then risk #else Line #fi
```

#### manipulating a position

```
behaviour frob
interface frob(bytes32 ilk, int256 dink, int256 dart)

vars

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

    Pit.ilks(ilk).line |-> Line_i
    Pit.ilks(ilk).spot |-> Spot_i

storage Vat

    Vat.urns(ilk, lad).gem |-> Gem_u => Gem_u - dink
    Vat.urns(ilk, lad).ink |-> Ink_u => Ink_u + dink
    Vat.urns(ilk, lad).art |-> Art_u => Art_u + dart
    Vat.ilks(ilk).rate     |-> Rate_i
    Vat.ilks(ilk).Art      |-> Art_i => Art_i + dart
    Vat.dai(CALLER_ID)     |-> Dai => Dai + (Rate_i * dart)
    Vat.Tab                |-> Tab => Tab + (Rate_i * dart)

iff

    Rate =/= 0
    ((((Art_u + dart) * Rate_i) <= #wad2rad(Spot_i)) and (((Tab + (Rate_i * dart))) < #wad2rad(Line))) or (dart <= 0)
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

