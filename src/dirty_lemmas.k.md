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

### DSToken storage layout

### DSToken

A hypothetical token contract, based on `ds-token`:

```k
syntax Int ::= "#DSToken.balances" "[" Int "]" [function]
// --------------------------------------------------
// doc: `gem` balance of `$0`
// act:
rule #DSToken.balances[A] => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#DSToken.stopped" [function]
// --------------------------------------------------
// doc: `gem` balance of `$0`
// act:
rule #DSToken.stopped => 4

syntax Int ::= "#DSToken.allowance" "[" Int "][" Int "]" [function]
// -----------------------------------------------
// doc: the amount that can be spent on someones behalf
// act: `$1 can spend `.` tokens belonging to `$0`
rule #DSToken.allowance[A][B] => #hashedLocation("Solidity", 2, A B)
```
