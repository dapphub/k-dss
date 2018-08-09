# dss storage model

### Vat


```
syntax Int ::= "#Vat.root" [function]
// ---------------------------------
rule #Vat.root => 0


syntax Int ::= "#Vat.dai" "(" Int ")" [function]
// -------------------------------------
rule #Vat.dai(A) => #hashedLocation("Solidity", 1, A)


syntax Int ::= "#Vat.sin" "(" Int ")" [function]
// -------------------------------------
rule #Vat.sin(A) => #hashedLocation("Solidity", 2, A)


syntax Int ::= "#Vat.ilks" "(" Int "," String ")" [function]
// -----------------------------------------------
rule #Vat.ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Vat.ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= "#Vat.urns" "(" Int "," Int "," String ")" [function]
// -----------------------------------------------------
rule #Vat.urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

rule #Vat.urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

rule #Vat.urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


syntax Int ::= "#Vat.Tab" [function]
// --------------------------------
rule #Vat.Tab => 5


syntax Int ::= "#Vat.vice" [function]
// ---------------------------------
rule #Vat.vice => 6

```

### Lad

```
syntax Int ::= "#Lad.vat" [function]
// ------------------------------
rule #Lad.vat => 0


syntax Int ::= "#Lad.Line" [function]
// -------------------------------
rule #Lad.Line => 1


syntax Int ::= "#Lad.live" [function]
// -------------------------------
rule #Lad.live => 2


syntax Int ::= "#Lad.ilks" "(" Int "," String ")" [function]
// ------------------------------------------------
rule #Lad.ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Lad.ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1
   
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
// ---------------------------------
rule #Vow.wait => 7


syntax Int ::= "#Vow.lump" [function]
// ---------------------------------
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


syntax Int ::= "#Cat.lad" [function]
// ---------------------------------
rule #Cat.lad => 1


syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
rule #Cat.vow => 2


syntax Int ::= "#Cat.lump" [function]
// ----------------------------------
rule #Cat.lump => 3


syntax Int ::= "#Cat.ilks" "(" Int "," String ")" [function]
// ---------------------------------------------------------
rule #Cat.ilks(Ilk, "chop") => #hashedLocation("Solidity", 4, Ilk) +Int 0

rule #Cat.ilks(Ilk, "flip") => #hashedLocation("Solidity", 4, Ilk) +Int 1


syntax Int ::= "#Cat.nflip" [function]
// -----------------------------------
rule #Cat.nflip => 5


syntax Int ::= "#Cat.Flips" "(" Int "," String ")" [function]
// ----------------------------------------------------------
rule #Cat.Flips(N, \"ilk\") => #hashedLocation("Solidity", 6, N) +Int 0

rule #Cat.Flips(N, \"guy\") => #hashedLocation("Solidity", 6, N) +Int 1

rule #Cat.Flips(N, \"ink\") => #hashedLocation("Solidity", 6, N) +Int 2

rule #Cat.Flips(N, \"tab\") => #hashedLocation("Solidity", 6, N) +Int 3

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
