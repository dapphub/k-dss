# dss lemmas

### string literal syntax

```
syntax Int ::= "#rightPadInt" "(" Int "," Int ")" [function]
// ---------------------------------------------------------
rule #rightPadInt(N, X) => X
  requires 256 *Int X >=Int (2 ^Int (8 *Int N))
rule #rightPadInt(N, X) => #rightPadInt(N, 256 *Int X)
  requires 256 *Int X <Int (2 ^Int (8 *Int N))

syntax Int ::= "#string2Word" "(" String ")" [function]
// ----------------------------------------------------
rule #string2Word(S) => #rightPadInt(32, Bytes2Int(String2Bytes(S), bigEndianBytes(.KList), unsignedBytes(.KList)))
```

### special fixed-point arithmetic

```
syntax Int ::= "#Wad" [function]
// -----------------------------
rule #Wad => 1000000000000000000

syntax Int ::= "#Ray" [function]
// -----------------------------
rule #Ray => 1000000000000000000000000000
```

We leave these symbolic for now:

```
syntax Int ::= "#rmul" "(" Int "," Int ")" [function]

syntax Int ::= "#rpow" "(" Int "," Int "," Int "," Int ")"  [function, smtlib(smt_rpow)]
```

### hashed storage

```
// hashed storage offsets never overflow (probabilistic assumption):
rule chop(keccakIntList(L) +Int N) => keccakIntList(L) +Int N
  requires N <=Int 100

// solidity also needs:
rule chop(keccakIntList(L)) => keccakIntList(L)
// and
rule chop(N +Int keccakIntList(L)) => keccakIntList(L) +Int N
  requires N <=Int 100
```

### miscellaneous

```
rule WS ++ .WordStack => WS

rule #sizeWordStack ( #padToWidth ( 32 , #asByteStack ( #unsigned ( W ) ) ) , 0) => 32
  requires #rangeSInt(256, W)

// custom ones:
rule #asWord(#padToWidth(32, #asByteStack(#unsigned(X)))) => #unsigned(X)
  requires #rangeSInt(256, X)

// rule #take(N, #padToWidth(N, WS) ++ WS' ) => #padToWidth(N, WS)

// potentially useful
// rule #padToWidth(N, WS) ++ WS' => #padToWidth(N + #sizeWordStack(WS'), WS ++ WS')
// and the N, M versions

rule #take(N, #padToWidth(N, WS) ) => #padToWidth(N, WS)
```

### signed 256-bit integer arithmetic

```
rule #unsigned(X) ==K 0 => X ==Int 0

rule 0 <Int #unsigned(X) => 0 <Int X

// uadd
// lemmas for necessity
rule chop(A +Int B) >Int A => (A +Int B <=Int maxUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// usub
// lemmas for necessity
rule A -Word B <Int A => (A -Int B >=Int minUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// addui
// lemmas for sufficiency
rule chop(A +Int #unsigned(B)) => A +Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A +Int B)

// lemmas for necessity
// rule chop(A +Int #unsigned(B)) >Int A => (A +Int B <=Int maxUInt256)
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B >=Int 0

rule (A +Int #unsigned(B) <=Int maxUInt256) => (A +Int B <=Int maxUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >=Int 0

rule chop(A +Int #unsigned(B)) <Int A => (A +Int B >=Int minUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// subui
// lemmas for sufficiency
rule A -Word #unsigned(B) => A -Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A -Int B)

// lemmas for necessity
// rule A -Word #unsigned(B) <Int A => (A -Int B >=Int minUInt256)
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B >=Int 0

rule (A -Int #unsigned(B) >=Int minUInt256) => (A -Int B >=Int minUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >=Int 0

rule A -Word #unsigned(B) >Int A => (A -Int B <=Int maxUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// mului
// lemmas for sufficiency
rule A *Int #unsigned(B) => #unsigned(A *Int B)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)

rule abs(#unsigned(A *Int B)) /Int abs(#unsigned(B)) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool notBool (#unsigned(B) ==Int 0)

// possibly get rid of
rule #sgnInterp(sgn(W), abs(W)) => W
  requires #rangeUInt(256, W)

rule #sgnInterp(sgn(#unsigned(A *Int B)), A) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool B >=Int 0

rule #sgnInterp(sgn(#unsigned(A *Int B)) *Int (-1), A) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool B <Int 0

// lemmas for necessity
rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))), abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B))) ==K A) => A *Int B <=Int maxSInt256
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >Int 0

rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))) *Int (-1), abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B))) ==K A) => A *Int B >=Int minSInt256
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

rule (chop(A *Int B) /Int B ==K A) => A *Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)
```
