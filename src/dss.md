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
    (Ilk_Art + dart) * Ilk_rate
    Ilk_Art * Ilk_rate
    Urn_art * Ilk_rate
    (Urn_ink + ABI_dink) * Ilk_spot


iff in range int256

    Ilk_rate
    Ilk_rate * dart

if

    u =/= v
    v =/= w
    u =/= w

iff

    ((((Ilk_Art + dart) * Ilk_rate <= Ilk_line) and ((Debt + Ilk_rate * dart) <= Line)) or (dart <= 0))
    (dart <= 0 and dink >= 0) or (((Urn_art + dart) * Ilk_rate) <= ((Urn_ink + dink) * Ilk_spot))
    (u == CALLER_ID or Can_u == 1) or (dart <= 0 and dink >= 0)
    (v == CALLER_ID or Can_v == 1) or (dink < 0)
    (w == CALLER_ID or Can_w == 1) or (dart > 0)
    (((Urn_art + dart) * Ilk_rate) >= Ilk_dust) or ((Urn_art + dart) == 0)
    Ilk_rate =/= 0
    Live == 1
    VCallValue == 0

calls

    Vat.addui
    Vat.subui
    Vat.mului
    Vat.muluu
```
