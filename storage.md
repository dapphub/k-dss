# dss storage model

### Vat


```
   syntax Int ::= "#root" [function]
// ---------------------------------
   rule #root => 0


   syntax Int ::= #dai( Int ) [function]
// -------------------------------------
   rule #dai(A) => #hashedLocation("Solidity", 1, A)


   syntax Int ::= #sin( Int ) [function]
// -------------------------------------
   rule #sin(A) => #hashedLocation("Solidity", 2, A)


   syntax Int ::= #ilks( Int , String ) [function]
// -----------------------------------------------
   rule #ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

   rule #ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


   syntax Int ::= #urns( Int , Int , String ) [function]
// -----------------------------------------------------
   rule #urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

   rule #urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

   rule #urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


   syntax Int ::= "#Tab" [function]
// --------------------------------
   rule #Tab => 5


   syntax Int ::= "#vice" [function]
// ---------------------------------
   rule #vice => 6

```

### Lad

```

```

### Vow

```

```
