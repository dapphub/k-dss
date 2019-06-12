This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

```k
syntax Int ::= "Mask6_12" [function]
// 0xffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffff
rule Mask6_12 => 115792089237315784047431654708638870748305248246218003188207458632603225030655 [macro]
rule Mask6_12 &Int (Y *Int pow208 +Int X *Int pow160 +Int A) => Y *Int pow208 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (X *Int pow208) |Int (Y *Int pow208 +Int A) => Y *Int pow208 +Int X *Int pow160 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
```

### DSValue

```k
syntax Int ::= "#DSValue.has" [function]
rule #DSValue.has => 0

syntax Int ::= "#DSValue.val" [function]
rule #DSValue.val => 0
```

### Spotter

```act
syntax Int ::= "#Spotter.wards" "[" Int "]" [function]
rule #Spotter.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Spotter.ilks" "[" Int "].pip" [function]
rule #Spotter.ilks[Ilk].pip => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Spotter.ilks" "[" Int "].mat" [function]
rule #Spotter.ilks[Ilk].mat => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Spotter.vat" [function]
rule #Spotter.vat => 2

syntax Int ::= "#Spotter.par" [function]
rule #Spotter.par => 3
```
