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
   syntax Int ::= #vat [function]
// ------------------------------
   rule #vat => 0


   syntax Int ::= #Line [function]
// -------------------------------
   rule #Line => 1


   syntax Int ::= #live [function]
// -------------------------------
   rule #live => 2
   
   
   syntax Int ::= #ilks ( Int , String ) [function]
// ------------------------------------------------
   rule #ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

   rule #ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1
   
```

### Vow

```

```
