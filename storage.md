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
