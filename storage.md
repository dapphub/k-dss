# dss storage model

### Vat


```
syntax Int ::= "#Vat.root" [function]
// ----------------------------------
rule #Vat.root => 0

syntax Int ::= "#Vat.dai" "(" Int ")" [function]
// ---------------------------------------------
rule #Vat.dai(A) => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#Vat.sin" "(" Int ")" [function]
// ---------------------------------------------
rule #Vat.sin(A) => #hashedLocation("Solidity", 2, A)

syntax Int ::= "#Vat.ilks" "(" Int  ").rate" [function]
// ----------------------------------------------------
rule #Vat.ilks(Ilk).rate => #hashedLocation("Solidity", 3, Ilk) +Int 0

syntax Int ::= "#Vat.ilks" "(" Int  ").Art" [function]
// -----------------------------------------------
rule #Vat.ilks(Ilk).Art => #hashedLocation("Solidity", 3, Ilk) +Int 1

syntax Int ::= "#Vat.urns" "(" Int "," Int ").gem" [function]
// ----------------------------------------------------------
rule #Vat.urns(Ilk, Guy).gem => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

syntax Int ::= "#Vat.urns" "(" Int "," Int ").ink" [function]
// ----------------------------------------------------------
rule #Vat.urns(Ilk, Guy).ink => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

syntax Int ::= "#Vat.urns" "(" Int "," Int ").art" [function]
// ----------------------------------------------------------
rule #Vat.urns(Ilk, Guy).art => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2

syntax Int ::= "#Vat.Tab" [function]
// ---------------------------------
rule #Vat.Tab => 5

syntax Int ::= "#Vat.vice" [function]
// ----------------------------------
rule #Vat.vice => 6

```

### Pit

```
syntax Int ::= "#Pit.vat" [function]
// ---------------------------------
rule #Pit.vat => 0

syntax Int ::= "#Pit.Line" [function]
// ----------------------------------
rule #Pit.Line => 1

syntax Int ::= "#Pit.live" [function]
// ----------------------------------
rule #Pit.live => 2

syntax Int ::= "#Pit.ilks" "(" Int ").spot" [function]
// ---------------------------------------------------
rule #Pit.ilks(Ilk).spot => #hashedLocation("Solidity", 3, Ilk) +Int 0

syntax Int ::= "#Pit.ilks" "(" Int ").line" [function]
// ---------------------------------------------------
rule #Pit.ilks(Ilk).line => #hashedLocation("Solidity", 3, Ilk) +Int 1
   
```

### Vow

```
syntax Int ::= "#Vow.vat" [function]
// ---------------------------------
rule #Vow.vat => 0

syntax Int ::= "#Vow.cow" [function]
// ---------------------------------
rule #Vow.cow => 1

syntax Int ::= "#Vow.row" [function]
// ---------------------------------
rule #Vow.row => 2

syntax Int ::= "#Vow.sin" "(" Int ")" [function]
// ---------------------------------------------
rule #Vow.sin(A) => #hashedLocation("Solidity", 3, A)

syntax Int ::= "#Vow.Sin" [function]
// ---------------------------------
rule #Vow.Sin => 4

syntax Int ::= "#Vow.Woe" [function]
// ---------------------------------
rule #Vow.Woe => 5

syntax Int ::= "#Vow.Ash" [function]
// ---------------------------------
rule #Vow.Ash => 6

syntax Int ::= "#Vow.wait" [function]
// ----------------------------------
rule #Vow.wait => 7

syntax Int ::= "#Vow.lump" [function]
// ----------------------------------
rule #Vow.lump => 8

syntax Int ::= "#Vow.pad" [function]
// ---------------------------------
rule #Vow.pad => 9
```

### Cat

```
syntax Int ::= "#Cat.vat" [function]
// ---------------------------------
rule #Cat.vat => 0

syntax Int ::= "#Cat.pit" [function]
// ---------------------------------
rule #Cat.pit => 1

syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
rule #Cat.vow => 2

syntax Int ::= "#Cat.lump" [function]
// ----------------------------------
rule #Cat.lump => 3

syntax Int ::= "#Cat.ilks" "(" Int ").chop" [function]
// ---------------------------------------------------
rule #Cat.ilks(Ilk).chop => #hashedLocation("Solidity", 4, Ilk) +Int 0

syntax Int ::= "#Cat.ilks" "(" Int ").flip" [function]
// ---------------------------------------------------
rule #Cat.ilks(Ilk).flip => #hashedLocation("Solidity", 4, Ilk) +Int 1

syntax Int ::= "#Cat.nflip" [function]
// -----------------------------------
rule #Cat.nflip => 5

syntax Int ::= "#Cat.Flips" "(" Int ").ilk" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).ilk => #hashedLocation("Solidity", 6, N) +Int 0

syntax Int ::= "#Cat.Flips" "(" Int ").lad" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).lad => #hashedLocation("Solidity", 6, N) +Int 1

syntax Int ::= "#Cat.Flips" "(" Int ").ink" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).ink => #hashedLocation("Solidity", 6, N) +Int 2

syntax Int ::= "#Cat.Flips" "(" Int ").tab" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).tab => #hashedLocation("Solidity", 6, N) +Int 3

```

### Adapter

```
syntax Int ::= "#Adapter.vat" [function]
// -------------------------------------
rule #Adapter.vat => 0

syntax Int ::= "#Adapter.ilk" [function]
// -------------------------------------
rule #Adapter.ilk => 1

syntax Int ::= "#Adapter.gem" [function]
// -------------------------------------
rule #Adapter.gem => 2
```
