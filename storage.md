# dss storage model

### Vat


```
   syntax Int ::= "#Vat_root" [function]
// ---------------------------------
   rule #Vat_root => 0


   syntax Int ::= #Vat_dai( Int ) [function]
// -------------------------------------
   rule #Vat_dai(A) => #hashedLocation("Solidity", 1, A)


   syntax Int ::= #Vat_sin( Int ) [function]
// -------------------------------------
   rule #Vat_sin(A) => #hashedLocation("Solidity", 2, A)


   syntax Int ::= #Vat_ilks( Int , String ) [function]
// -----------------------------------------------
   rule #Vat_ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

   rule #Vat_ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


   syntax Int ::= #Vat_urns( Int , Int , String ) [function]
// -----------------------------------------------------
   rule #Vat_urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

   rule #Vat_urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

   rule #Vat_urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


   syntax Int ::= "#Vat_Tab" [function]
// --------------------------------
   rule #Vat_Tab => 5


   syntax Int ::= "#Vat_vice" [function]
// ---------------------------------
   rule #Vat_vice => 6

```

### Lad

```
   syntax Int ::= #Lad_vat [function]
// ------------------------------
   rule #Lad_vat => 0


   syntax Int ::= #Lad_Line [function]
// -------------------------------
   rule #Lad_Line => 1


   syntax Int ::= #Lad_live [function]
// -------------------------------
   rule #Lad_live => 2
   
   
   syntax Int ::= #Lad_ilks ( Int , String ) [function]
// ------------------------------------------------
   rule #Lad_ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

   rule #Lad_ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1
   
```

### Vow

```

```

### Adapter

```
   syntax Int ::=
```
