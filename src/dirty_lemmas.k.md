This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

```k
syntax Int ::= "maxUInt208" [function]
rule maxUInt208 => 411376139330301510538742295639337626245683966408394965837152255 [macro]

rule maxUInt208 &Int ((X *Int pow208) +Int A ) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule (X *Int pow208) |Int A => (X *Int pow208 +Int A)
  requires #rangeUInt(48, X)
  andBool #rangeAddress(A)

syntax Int ::= "Mask26_32" [function]
// 0xffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000
rule Mask26_32 => 115792089237316195423570985008687907853269984665640564039457583726438152929280 [macro]
syntax Int ::= "Mask20_26" [function]
// 0xffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffff
rule Mask20_26 => 115792089237316195423570985008687907853269984665561335876943319951794562400255 [macro]

rule Mask26_32 &Int (Y *Int pow48 +Int X) => Y *Int pow48
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule Mask20_26 &Int (Y *Int pow48 +Int X) => X
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule X |Int Y *Int pow48 => Y *Int pow48 +Int X
  requires #rangeUInt(48, Y)
  andBool #rangeUInt(48, X)

rule (X *Int pow48) |Int Y => (X *Int pow48) +Int Y
  requires #rangeUInt(48, Y)
  andBool #rangeUInt(48, X)

syntax Int ::= "#DropAddr" "(" Int ")" [function]
rule #DropAddr(W) => MaskLast20 &Int W
  requires #rangeUInt(256, W)
```


```k
syntax Int ::= "#WordPackAddrUInt8" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackAddrUInt8(X, Y) => Y *Int pow160 +Int X
  requires #rangeAddress(X)
  andBool #rangeUInt(8, Y)
```

```k
rule #rmul(X, Y) => (X *Int Y) /Int #Ray
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
