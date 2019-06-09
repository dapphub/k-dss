```k
syntax Int ::= num0 ( Int ) [function, smtlib(smt_num0)]
syntax Int ::= num1 ( Int ) [function, smtlib(smt_num1)]

rule num0(N) >=Int 0 => num0(N) >=Int 1
  requires N >=Int 1
  andBool N modInt 2 ==Int 0

rule num1(N) >=Int 0 => num1(N) >=Int 1
  requires N >Int 1
  andBool N modInt 2 =/=Int 0

rule num0(N /Int 2) => num0(N) -Int 1
  requires N >=Int 1
  andBool N modInt 2 ==Int 0

rule num0(N /Int 2) => num0(N)
  requires N >=Int 1
  andBool N modInt 2 ==Int 1

rule num1(N /Int 2) => num1(N) -Int 1
  requires N >Int 1
  andBool N modInt 2 ==Int 1

rule num1(N /Int 2) => num1(N)
  requires N >Int 1
  andBool N modInt 2 ==Int 0

rule num0(N) => 0
  requires N ==Int 1

rule num1(N) => 0
  requires N ==Int 1

rule (A -Int B) +Int B => A

rule (A -Int B) -Int (C -Int B) => A -Int C
```

### Solidity Word Packing
We will have to use some of these tricks when reasoning about solidity implementations of `Flip`, `Flap`, and `Flop`:

```k
syntax Int ::= "pow48"  [function]
syntax Int ::= "pow96"  [function]
syntax Int ::= "pow208" [function]
rule pow48  => 281474976710656                                                 [macro]
rule pow96  => 79228162514264337593543950336                                   [macro]
rule pow208 => 411376139330301510538742295639337626245683966408394965837152256 [macro]

syntax Int ::= "#WordPackUInt48UInt48" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackUInt48UInt48(X, Y) => Y *Int pow48 +Int X
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

syntax Int ::= "#WordPackAddrUInt48UInt48" "(" Int "," Int "," Int ")" [function]
// ----------------------------------------------------------------------
rule #WordPackAddrUInt48UInt48(A, X, Y) => Y *Int pow208 +Int X *Int pow160 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
```


# dss lemmas

### string literal syntax

```k

syntax Int ::= "#string2Word" "(" String ")" [function]
// ----------------------------------------------------
rule #string2Word(S) => #asWord(#padRightToWidth(32, #parseByteStackRaw(S)))
```

### special fixed-point arithmetic

```k
syntax Int ::= "#Wad" [function]
// -----------------------------
rule #Wad => 1000000000000000000

syntax Int ::= "#Ray" [function]
// -----------------------------
rule #Ray => 1000000000000000000000000000
```

We leave these symbolic for now:

```k
syntax Int ::= "#rmul" "(" Int "," Int ")" [function]

syntax Int ::= "#rpow" "(" Int "," Int "," Int "," Int ")"  [function, smtlib(smt_rpow), smt-prelude]

syntax Int ::= "#ifInt" Bool "#then" Int "#else" Int "#fi" [function, smtlib(ite), hook(KEQUAL.ite)]

rule A *Int C /Int C => A
  requires A *Int C <Int pow256

rule (X *Int Y) /Word Y => #ifInt Y ==Int 0 #then 0 #else chop(X) #fi

rule A /Int B <Int pow256 => true
  requires A <Int pow256

rule Z *Int (X ^Int N) => Z
  requires N ==Int 0

rule Z *Int (X ^Int (N %Int 2)) => Z
  requires N ==Int 0

rule 0 ^Int N => 1
  requires N ==Int 0

rule 0 ^Int N => 0
  requires N >Int 0

rule 0 <=Int (N /Int 2) => true
  requires 0 <=Int N

rule N /Int 2 <Int pow256 => true
  requires N <Int pow256

// TODO - review - do i need it?
rule chop(X *Int X) => X *Int X
  requires #rpow(Z, X, N, B) *Int B <Int pow256
  andBool N >=Int 2


rule #rpow(Z, X, 0, Base) => Z

rule #rpow(Z, X, N, Base) => Z
  requires N modInt 2 ==Int 0
  andBool N /Int 2 ==Int 0

rule #rpow(Z, 0, N, Base) => 0

rule #rpow(Base, X, N, Base) => X
  requires N ==Int 1

rule #rpow(((Z *Int X) +Int Half) /Int Base, X, N /Int 2, Base) =>
     #rpow(Z,                                 X, N,       Base)
  requires Half ==Int Base /Int 2
  andBool  N ==Int 1

rule #rpow(((Z *Int X) +Int Half) /Int Base, ((X *Int X) +Int Half) /Int Base, N /Int 2, Base) =>
     #rpow( Z                               , X                               , N       , Base )
  requires N modInt 2 =/=Int 0
  andBool  N >=Int 2
  andBool Half ==Int Base /Int 2

rule #rpow( Z                              , ((X *Int X) +Int Half) /Int Base, N /Int 2, Base) =>
     #rpow( Z                              , X                               , N       , Base )
  requires N modInt 2 ==Int 0
  andBool  N >=Int 2
andBool Half ==Int Base /Int 2

rule #rpow( X                              , ((X *Int X) +Int Half) /Int Base, N /Int 2, Base) =>
     #rpow( Base                           , X                               , N       , Base )
  requires N modInt 2 =/=Int 0
  andBool  N /Int 2 =/=Int 0
  andBool  Half ==Int Base /Int 2

rule Z *Int X <Int pow256 => true
  requires #rpow(Z, X, N, Base) <Int pow256
```

### hashed storage

```k
// hashed storage offsets never overflow (probabilistic assumption):
rule chop(keccakIntList(L) +Int N) => keccakIntList(L) +Int N
  requires N <=Int 100

// solidity also needs:
rule chop(keccakIntList(L)) => keccakIntList(L)
// and
rule chop(N +Int keccakIntList(L)) => keccakIntList(L) +Int N
  requires N <=Int 100
```

### solidity masking

**TODO**: refactor and tidy these.

```k
syntax Int ::= "MaskLast20" [function]
syntax Int ::= "MaskFirst6" [function]
syntax Int ::= "MaskFirst12" [function]
syntax Int ::= "MaskFirst26" [function]
// -----------------------------------
// 0xffffffffffffffffffffffff0000000000000000000000000000000000000000
rule MaskLast20 => 115792089237316195423570985007226406215939081747436879206741300988257197096960 [macro]
// 0x000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffff
rule MaskFirst6 => 411376139330301510538742295639337626245683966408394965837152255                [macro]
rule MaskFirst12 => 1461501637330902918203684832716283019655932542975  [macro]
// 0x0000000000000000000000000000000000000000000000000000ffffffffffff
rule MaskFirst26 => 281474976710655                                                               [macro]

rule MaskLast20 &Int A => 0
  requires #rangeAddress(A)

rule X |Int 0 => X

rule chop(A &Int B) => A &Int B
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule chop(A |Int B) => A |Int B
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// Masking for packed words
rule MaskLast20 &Int (Y *Int pow208 +Int X *Int pow160 +Int A) => Y *Int pow208 +Int X *Int pow160
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule B |Int (Y *Int pow208 +Int X *Int pow160) => Y *Int pow208 +Int X *Int pow160 +Int B
  requires #rangeAddress(B)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (Y *Int pow208 +Int X *Int pow160 +Int A) /Int pow208 => Y
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (Y *Int pow48 +Int X) /Int pow48 => Y
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule MaskFirst6 &Int (X *Int pow208 +Int Y *Int pow160 +Int A) => Y *Int pow160 +Int A
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
  andBool #rangeAddress(A)

rule (X *Int pow208) |Int (Y *Int pow160 +Int A) => (X *Int pow208 +Int Y *Int pow160 +Int A)
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
  andBool #rangeAddress(A)

rule maxUInt160 &Int (((X *Int pow208) +Int (Y *Int pow160)) +Int A) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt160 &Int ((X *Int pow208) +Int (Y *Int pow160)) => 0
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule ((((X *Int pow208) +Int (Y *Int pow160)) +Int A) /Int pow160) => (X *Int pow48) +Int Y
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt48 &Int (X *Int pow48) +Int Y => Y
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule ((X *Int pow208) +Int A) /Int pow160 => X *Int pow48
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule maxUInt48 &Int (X *Int pow48) => 0
  requires #rangeUInt(48, X)
```

### miscellaneous

```k
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

### 48-bit integer arithmetic

```k
rule notBool((MaskFirst26 &Int (A +Int B)) <Int A) => A +Int B <=Int maxUInt48
  requires #rangeUInt(48, A)
  andBool #rangeUInt(48, B)
```

### signed 256-bit integer arithmetic

```k
rule #unsigned(X) ==K 0 => X ==Int 0
  requires #rangeSInt(256, X)

// rule 0 <Int #unsigned(X) => 0 <Int X
//   requires #rangeSInt(256, X)

// uadd
// lemmas for necessity
rule notBool(chop(A +Int B) <Int A) => A +Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// usub
// lemmas for necessity
rule notBool(A -Word B >Int A) => (A -Int B >=Int minUInt256)
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

rule chop(A +Int B) >Int A => (A +Int B <=Int maxUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

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

rule A -Word B <Int A => (A -Int B >=Int minUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

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


rule abs(B) ==K 0 => B ==K 0

rule #sgnInterp(sgn(#unsigned(A *Int B)) *Int sgn(#unsigned(B)), A) => A
  requires #rangeSInt(256, A *Int B)
  andBool #rangeUInt(256, A)
  andBool #rangeSInt(256, B)

// lemmas for necessity
rule #signed(X) <Int 0 => notBool #rangeSInt(256, X)
   requires #rangeUInt(256, X)

rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))) *Int sgn(#unsigned(B)), chop(abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B)))) ==K A) => false
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B =/=Int 0
  andBool notBool #rangeSInt(256, A *Int B)

rule (chop(A *Int B) /Int B ==K A) => A *Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)
```
