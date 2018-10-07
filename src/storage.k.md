# dss storage model

### Solidity Word Packing
We will have to use some of these tricks when reasoning about solidity implementations of `Flip`, `Flap`, and `Flop`:

**TODO** : unpacking these might require some easy lemmas about division
```k
syntax Int ::= "pow48"  [function]
syntax Int ::= "pow208" [function]
rule pow48  => 281474976710656                                                 [macro]
rule pow208 => 411376139330301510538742295639337626245683966408394965837152256 [macro]

syntax Int ::= "#WordPackUInt48UInt48" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackUInt48UInt48(X, Y) => Y *Int pow48 +Int X
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

syntax Int ::= "#WordPackAddrUInt48UInt48" "(" Int "," Int "," Int ")" [function]
// ----------------------------------------------------------------------
rule #WordPackAddrUInt48UInt48(A, X, Y) => Y *Int pow208 +Int X *Int pow160 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
```

### Vat

```k
syntax Int ::= "#Vat.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: authorisation to call
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Vat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vat.ilks" "[" Int "].take" [function]
// ----------------------------------------------------
// doc: collateral unit rate of ilk `$0`
// act: ilk `$0` has collateral unit rate `.`
rule #Vat.ilks[Ilk].take => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Vat.ilks" "[" Int "].rate" [function]
// ----------------------------------------------------
// doc: debt unit rate of ilk `$0`
// act: ilk `$0` has debt unit rate `.`
rule #Vat.ilks[Ilk].rate => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Vat.ilks" "[" Int "].Ink" [function]
// -----------------------------------------------
// doc: the total encumbered collateral for the ilk `$0`
// act: ilk `$0` has encumbered collateral `.`
rule #Vat.ilks[Ilk].Ink => #hashedLocation("Solidity", 1, Ilk) +Int 2

syntax Int ::= "#Vat.ilks" "[" Int "].Art" [function]
// -----------------------------------------------
// doc: the total debt issued from the ilk `$0`
// act: ilk `$0` has debt issuance `.`
rule #Vat.ilks[Ilk].Art => #hashedLocation("Solidity", 1, Ilk) +Int 3

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].ink" [function]
// ----------------------------------------------------------
// doc: the amount of encumbered collateral units assigned to `$1`
// act: agent `$1` has `.` collateral units in ilk `$0`
rule #Vat.urns[Ilk][Guy].ink => #hashedLocation("Solidity", 2, Ilk Guy)

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].art" [function]
// ----------------------------------------------------------
// doc: the amount of debt units assigned to `$1`
// act: agent `$1` has `.` debt units in ilk `$0`
rule #Vat.urns[Ilk][Guy].art => #hashedLocation("Solidity", 2, Ilk Guy) +Int 1

syntax Int ::= "#Vat.gem" "[" Int "][" Int "]" [function]
// ---------------------------------------------
// doc: the amount of unencumbered collateral assigned to `$1`
// act: agent `$1` has `.` unencumbered collateral in ilk `$0`
rule #Vat.gem[Ilk][Guy] => #hashedLocation("Solidity", 3, Ilk Guy)

syntax Int ::= "#Vat.dai" "[" Int "]" [function]
// ---------------------------------------------
// doc: the amount of dai assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.dai[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Vat.sin" "[" Int "]" [function]
// ---------------------------------------------
// doc: the amount of system debt assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.sin[A] => #hashedLocation("Solidity", 5, A)

syntax Int ::= "#Vat.debt" [function]
// ---------------------------------
// doc: the total debt issued from the system
// act: system has `.` total debt
rule #Vat.debt => 6

syntax Int ::= "#Vat.vice" [function]
// ----------------------------------
// doc: the total system debt
// act: there is `.` system debt
rule #Vat.vice => 7
```

### Drip

```k
syntax Int ::= "#Drip.wards" "[" Int "]" [function]
// -----------------------------------------------
rule #Drip.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Drip.ilks" "[" Int "].tax" [function]
// ----------------------------------------------------
rule #Drip.ilks[Ilk].tax => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Drip.ilks" "[" Int "].rho" [function]
// ----------------------------------------------------
rule #Drip.ilks[Ilk].rho => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Drip.vat" [function]
// ----------------------------------
rule #Drip.vat => 2

syntax Int ::= "#Drip.vow" [function]
// ----------------------------------
rule #Drip.vow => 3

syntax Int ::= "#Drip.repo" [function]
// -----------------------------------
rule #Drip.repo => 4
```

### Pit

```k
syntax Int ::= "#Pit.wards" "[" Int "]" [function]
// ---------------------------------
rule #Pit.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Pit.ilks" "[" Int "].spot" [function]
// ---------------------------------------------------
rule #Pit.ilks[Ilk].spot => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Pit.ilks" "[" Int "].line" [function]
// ---------------------------------------------------
rule #Pit.ilks[Ilk].line => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Pit.live" [function]
// ----------------------------------
rule #Pit.live => 2

syntax Int ::= "#Pit.Line" [function]
// ----------------------------------
rule #Pit.Line => 3

syntax Int ::= "#Pit.vat" [function]
// ---------------------------------
rule #Pit.vat => 4
```

### Vow

```k
syntax Int ::= "#Vow.wards" "[" Int "]" [function]
// ---------------------------------
rule #Vow.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vow.vat" [function]
// ---------------------------------
rule #Vow.vat => 1

syntax Int ::= "#Vow.cow" [function]
// ---------------------------------
rule #Vow.cow => 2

syntax Int ::= "#Vow.row" [function]
// ---------------------------------
rule #Vow.row => 3

syntax Int ::= "#Vow.sin" "[" Int "]" [function]
// ---------------------------------------------
rule #Vow.sin[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Vow.Sin" [function]
// ---------------------------------
rule #Vow.Sin => 5

syntax Int ::= "#Vow.Woe" [function]
// ---------------------------------
rule #Vow.Woe => 6

syntax Int ::= "#Vow.Ash" [function]
// ---------------------------------
rule #Vow.Ash => 7

syntax Int ::= "#Vow.wait" [function]
// ----------------------------------
rule #Vow.wait => 8

syntax Int ::= "#Vow.sump" [function]
// ----------------------------------
rule #Vow.sump => 9

syntax Int ::= "#Vow.bump" [function]
// ----------------------------------
rule #Vow.bump => 10

syntax Int ::= "#Vow.hump" [function]
// ---------------------------------
rule #Vow.hump => 11
```

### Cat

```k
syntax Int ::= "#Cat.wards" "[" Int "]" [function]
// ---------------------------------
rule #Cat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Cat.ilks" "[" Int "].flip" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].flip => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Cat.ilks" "[" Int "].chop" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].chop => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Cat.ilks" "[" Int "].lump" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].lump => #hashedLocation("Solidity", 1, Ilk) +Int 2

syntax Int ::= "#Cat.flips" "[" Int "].ilk" [function]
// ---------------------------------------------------
rule #Cat.flips[N].ilk => #hashedLocation("Solidity", 2, N) +Int 0

syntax Int ::= "#Cat.flips" "[" Int "].urn" [function]
// ---------------------------------------------------
rule #Cat.flips[N].urn => #hashedLocation("Solidity", 2, N) +Int 1

syntax Int ::= "#Cat.flips" "[" Int "].ink" [function]
// ---------------------------------------------------
rule #Cat.flips[N].ink => #hashedLocation("Solidity", 2, N) +Int 2

syntax Int ::= "#Cat.flips" "[" Int "].tab" [function]
// ---------------------------------------------------
rule #Cat.flips[N].tab => #hashedLocation("Solidity", 2, N) +Int 3

syntax Int ::= "#Cat.nflip" [function]
// -----------------------------------
rule #Cat.nflip => 3

syntax Int ::= "#Cat.live" [function]
// ----------------------------------
rule #Cat.live => 4

syntax Int ::= "#Cat.vat" [function]
// ---------------------------------
rule #Cat.vat => 5

syntax Int ::= "#Cat.pit" [function]
// ---------------------------------
rule #Cat.pit => 6

syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
rule #Cat.vow => 7
```

### GemJoin

```k
syntax Int ::= "#GemJoin.vat" [function]
// -------------------------------------
rule #GemJoin.vat => 0

syntax Int ::= "#GemJoin.ilk" [function]
// -------------------------------------
rule #GemJoin.ilk => 1

syntax Int ::= "#GemJoin.gem" [function]
// -------------------------------------
rule #GemJoin.gem => 2
```

### ETHJoin

```k
syntax Int ::= "#ETHJoin.vat" [function]
// -------------------------------------
rule #ETHJoin.vat => 0

syntax Int ::= "#ETHJoin.ilk" [function]
// -------------------------------------
rule #ETHJoin.ilk => 1
```

### DaiJoin

```k
syntax Int ::= "#DaiJoin.vat" [function]
// -------------------------------------
rule #DaiJoin.vat => 0

syntax Int ::= "#DaiJoin.dai" [function]
// -------------------------------------
rule #DaiJoin.dai => 1
```

### Flipper

```k
// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.ttl_tau" [function]
// -----------------------------------------
rule #Flipper.ttl_tau => 3

syntax Int ::= "#Flipper.kicks" [function]
// ---------------------------------------
rule #Flipper.kicks => 4

syntax Int ::= "#Flipper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flipper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flipper.bids[N].guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flipper.bids" "[" Int "].urn" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].urn => #hashedLocation("Solidity", 5, N) +Int 3

syntax Int ::= "#Flipper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].gal => #hashedLocation("Solidity", 5, N) +Int 4

syntax Int ::= "#Flipper.bids" "[" Int "].tab" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].tab => #hashedLocation("Solidity", 5, N) +Int 5
```


### Flopper

```k
syntax Int ::= "#Flopper.wards" "[" Int "]" [function]
// ---------------------------------------
// doc: authorisation to call
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Flopper.wards[A] => #hashedLocation("Solidity", 0, A)

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flopper.ttl_tau => 5

syntax Int ::= "#Flopper.kicks" [function]
// ---------------------------------------
// doc:
// act:
rule #Flopper.kicks => 6

syntax Int ::= "#Flopper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].bid => #hashedLocation("Solidity", 1, N) +Int 0

syntax Int ::= "#Flopper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].lot => #hashedLocation("Solidity", 1, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].guy_tic_end => #hashedLocation("Solidity", 1, N) +Int 2

syntax Int ::= "#Flopper.bids" "[" Int "].vow" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].vow => #hashedLocation("Solidity", 1, N) +Int 3
```

### Flapper

```k
// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flapper.ttl_tau => 4

syntax Int ::= "#Flapper.kicks" [function]
// ---------------------------------------
// doc:
// act:
rule #Flapper.kicks => 5

syntax Int ::= "#Flapper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flapper.bids[N].bid => #hashedLocation("Solidity", 0, N) +Int 0

syntax Int ::= "#Flapper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flapper.bids[N].lot => #hashedLocation("Solidity", 0, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flapper.bids[N].guy_tic_end => #hashedLocation("Solidity", 0, N) +Int 2

syntax Int ::= "#Flapper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
// doc:
// act:
rule #Flapper.bids[N].gal => #hashedLocation("Solidity", 0, N) +Int 3

syntax Int ::= "#Flapper.dai" [function]
// ---------------------------------------
// doc:
// act:
rule #Flapper.dai => 1
```

### DaiMove
```k
syntax Int ::= "#DaiMove.vat" [function]
// ---------------------------------------
// doc:
// act:
rule #DaiMove.vat => 0

syntax Int ::= "#DaiMove.can" "[" Int "]" [function]
// ---------------------------------------
// doc:
// act:
rule #DaiMove.can[A] => #hashedLocation("Solidity", 1, A)
```


### GemLike

A hypothetical token contract, based on `ds-token`:

```k
syntax Int ::= "#GemLike.balances" "[" Int "]" [function]
// --------------------------------------------------
rule #GemLike.balances[A] => #hashedLocation("Solidity", 1, A)
```
