This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

```k
rule chop((X *Int pow208) +Int A) => (X *Int pow208) +Int A
  requires #rangeAddress(A)
  andBool #rangeUint(48, X)

rule chop(X *Int pow208) => X *Int pow208
  requires #rangeUint(48, X)

syntax Int ::= "maxUInt208" [function]
rule maxUInt208 => 411376139330301510538742295639337626245683966408394965837152255 [macro]

rule maxUInt208 &Int ((X *Int pow208) +Int A ) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule (X *Int pow208) |Int A => (X *Int pow208 +Int A)
  requires #rangeUInt(48, X)
  andBool #rangeAddress(A)
```
```k
syntax Int ::= "#WordPackAddrUInt8" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackAddrUInt8(X, Y) => Y *Int pow160 +Int X
  requires #rangeAddress(X)
  andBool #rangeUInt(8, Y)


```


### DSToken

```k
syntax Int ::= "#DSToken.supply" [function]
rule #DSToken.supply => 0

syntax Int ::= "#DSToken.balances" "[" Int "]" [function]
rule #DSToken.balances[A] => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#DSToken.allowance" "[" Int "][" Int "]" [function]
rule #DSToken.allowance[A][B] => #hashedLocation("Solidity", 2, A B)

syntax Int ::= "#DSToken.authority" [function]
rule #DSToken.authority => 3

syntax Int ::= "#DSToken.owner_stopped" [function]
rule #DSToken.owner_stopped => 4

syntax Int ::= "#DSToken.symbol" [function]
rule #DSToken.symbol => 5

syntax Int ::= "#DSToken.decimals" [function]
rule #DSToken.decimals => 6
```
