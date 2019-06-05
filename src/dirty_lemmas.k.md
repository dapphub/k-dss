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
Syntax Int ::= "#GemLike.supply" [function]
rule #GemLike.supply => 0

syntax Int ::= "#GemLike.balances" "[" Int "]" [function]
rule #GemLike.balances[A] => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#GemLike.allowance" "[" Int "][" Int "]" [function]
rule #GemLike.allowance[A][B] => #hashedLocation("Solidity", 2, A B)

Syntax Int ::= "#GemLike.authority" [function]
rule #GemLike.authority => 3

Syntax Int ::= "#GemLike.owner" [function]
rule #GemLike.owner => 4

syntax Int ::= "#GemLike.stopped" [function]
rule #GemLike.stopped => 5

syntax Int ::= "#GemLike.symbol" [function]
rule #GemLike.symbol => 6

syntax Int ::= "#GemLike.decimals" [function]
rule #GemLike.decimals => 7
```
