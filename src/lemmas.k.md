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

rule (#if C #then A #else B #fi *Int X) <=Int maxUInt256 => true
  requires A *Int X <=Int maxUInt256
  andBool B *Int X <=Int maxUInt256
```

### Solidity Word Packing
We will have to use some of these tricks when reasoning about solidity implementations of `Flip`, `Flap`, and `Flop`:

```k
syntax Int ::= "pow48"  [function]
syntax Int ::= "pow208" [function]
rule pow48  => 281474976710656                                                 [macro]
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

syntax Int ::= "#WordPackAddrUInt8" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackAddrUInt8(X, Y) => Y *Int pow160 +Int X
  requires #rangeAddress(X)
  andBool #rangeUInt(8, Y)
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
rule #Wad => 1000000000000000000           [macro]

syntax Int ::= "#Ray" [function]
// -----------------------------
rule #Ray => 1000000000000000000000000000  [macro]

syntax Int ::= "#rmul" "(" Int "," Int ")" [function]
rule #rmul(X, Y) => (X *Int Y) /Int #Ray
```

We leave these symbolic for now:

```k
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
  requires N =/=Int 0

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
syntax Int ::= "Mask12_32" [function]
syntax Int ::= "Mask0_6" [function]
syntax Int ::= "Mask6_12" [function]
syntax Int ::= "Mask0_12" [function]
syntax Int ::= "Mask0_26" [function]
syntax Int ::= "Mask26_32" [function]
syntax Int ::= "Mask20_26" [function]
// -----------------------------------
// 0x000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffff
rule Mask0_6 => 411376139330301510538742295639337626245683966408394965837152255                  [macro]
// 0xffffffffffff000000000000ffffffffffffffffffffffffffffffffffffffff
rule Mask6_12 => 115792089237315784047431654708638870748305248246218003188207458632603225030655 [macro]
// 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff
rule Mask0_12 => 1461501637330902918203684832716283019655932542975                               [macro]
// 0xffffffffffffffffffffffff0000000000000000000000000000000000000000
rule Mask12_32 => 115792089237316195423570985007226406215939081747436879206741300988257197096960 [macro]
// 0x0000000000000000000000000000000000000000000000000000ffffffffffff
rule Mask0_26 => 281474976710655                                                                 [macro]
// 0xffffffffffffffffffffffffffffffffffffffff000000000000ffffffffffff
rule Mask20_26 => 115792089237316195423570985008687907853269984665561335876943319951794562400255 [macro]
// 0xffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000
rule Mask26_32 => 115792089237316195423570985008687907853269984665640564039457583726438152929280 [macro]

syntax Int ::= "maxUInt208" [function]
rule maxUInt208 => 411376139330301510538742295639337626245683966408394965837152255 [macro]

rule maxUInt208 &Int ((X *Int pow208) +Int A ) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule (X *Int pow208) |Int A => (X *Int pow208 +Int A)
  requires #rangeUInt(48, X)
  andBool #rangeAddress(A)

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

rule Mask12_32 &Int A => 0
  requires #rangeAddress(A)

rule X |Int 0 => X

rule chop(A &Int B) => A &Int B
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule chop(A |Int B) => A |Int B
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// Masking for packed words
rule Mask12_32 &Int (Y *Int pow208 +Int (X *Int pow160 +Int A)) => Y *Int pow208 +Int X *Int pow160
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule B |Int (Y *Int pow208 +Int X *Int pow160) => Y *Int pow208 +Int X *Int pow160 +Int B
  requires #rangeAddress(B)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (Y *Int pow208 +Int ( X *Int pow160 +Int A ) ) /Int pow208 => Y
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (Y *Int pow48 +Int X) /Int pow48 => Y
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule Mask0_6 &Int (X *Int pow208 +Int ( Y *Int pow160 +Int A ) ) => Y *Int pow160 +Int A
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)
  andBool #rangeAddress(A)

rule Mask6_12 &Int (Y *Int pow208 +Int ( X *Int pow160 +Int A) ) => Y *Int pow208 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (Y *Int pow208) |Int (X *Int pow160 +Int A) => Y *Int pow208 +Int X *Int pow160 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule (X *Int pow160) |Int (Y *Int pow208 +Int A) => Y *Int pow208 +Int X *Int pow160 +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt160 &Int ((X *Int pow208) +Int ((Y *Int pow160) +Int A)) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt160 &Int ((X *Int pow208) +Int (Y *Int pow160)) => 0
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt160 &Int ((X *Int pow208) +Int A) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule maxUInt160 &Int ((X *Int pow160) +Int A) => A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule maxUInt160 &Int (X *Int pow208) => 0
  requires #rangeUInt(48, X)

rule maxUInt160 &Int (X *Int pow160) => 0
  requires #rangeUInt(48, X)

rule (((X *Int pow208) +Int ( (Y *Int pow160) +Int A)) /Int pow160) => (X *Int pow48) +Int Y
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule maxUInt48 &Int (X *Int pow48) +Int Y => Y
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

rule ((X *Int pow208) +Int A) /Int pow160 => X *Int pow48
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)

rule ((X *Int pow160) +Int A) /Int pow160 => X
  requires #rangeAddress(A)

rule (Y *Int pow208 +Int X *Int pow160) /Int pow208 => Y
  requires #rangeUInt(48, X)

rule (Y *Int pow208 +Int A) /Int pow208 => Y
  requires #rangeAddress(A)

rule maxUInt48 &Int (X *Int pow48) => 0
  requires #rangeUInt(48, X)
```

### miscellaneous

```k
rule WS ++ .WordStack => WS

rule #sizeWordStack ( #padToWidth ( 32 , #asByteStack ( #unsigned ( W ) ) ) ) => 32
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
rule notBool((Mask0_26 &Int (A +Int B)) <Int A) => A +Int B <=Int maxUInt48
  requires #rangeUInt(48, A)
  andBool #rangeUInt(48, B)
```

### signed 256-bit integer arithmetic

```k
rule #unsigned(X) ==K 0 => X ==Int 0
  requires #rangeSInt(256, X)

// rule 0 <Int #unsigned(X) => 0 <Int X
//   requires #rangeSInt(256, X)

// usub
// lemmas for necessity
// rule A <=Int A -Word B => 0 <=Int A -Int B
//   requires #rangeUInt(256, A)
//   andBool #rangeUInt(256, B)

// addui
// lemmas for sufficiency
rule chop(A +Int #unsigned(B)) => A +Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A +Int B)

rule A <=Int chop(A +Int #unsigned(B)) => A +Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool 0 <Int B

rule chop(A +Int #unsigned(B)) <=Int A => 0 <=Int A +Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// rule (A +Int #unsigned(B) <=Int maxUInt256) => (A +Int B <=Int maxUInt256)
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B >=Int 0

// rule A <=Int chop(A +Int #unsigned(B)) => A +Int B <Int 0
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B <Int 0

// subui
// lemmas for sufficiency
rule A -Word #unsigned(B) => A -Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A -Int B)

 rule A -Word #unsigned(B) <=Int A => minUInt256 <=Int A -Int B
   requires #rangeUInt(256, A)
   andBool #rangeSInt(256, B)
   andBool 0 <=Int B

 rule A <Int A -Word #unsigned(B) => A -Int B <=Int maxUInt256
   requires #rangeUInt(256, A)
   andBool #rangeSInt(256, B)
   andBool B <Int 0

rule A -Word #unsigned(B) <Int A => maxUInt256 <Int A -Int B
   requires #rangeUInt(256, A)
   andBool #rangeSInt(256, B)
   andBool B <Int 0

rule (A +Int pow256) -Int #unsigned(B) => A -Int B
   requires #rangeUInt(256, A)
   andBool #rangeSInt(256, B)
   andBool #rangeUInt(256, A -Int B)
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

// rule #sgnInterp(sgn(chop(A *Int B)), abs(chop(A *Int B)) /Int B) ==K A => #rangeSInt(256, A *Int B)
// requires #rangeUInt(256, A)
// andBool  #rangeSInt(256, B)

// rule #sgnInterp(sgn(chop(A *Int (pow256 +Int B))) *Int -1, chop(abs(chop(A *Int (pow256 +Int B))) /Int (pow256 -Int (pow256 +Int B)))) ==K A => #rangeSInt(256, A *Int B)
// requires #rangeUInt(256, A)
// andBool  #rangeSInt(256, B)

rule (chop(A *Int B) /Int B ==K A) => #rangeUInt(256, A *Int B)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))) *Int sgn(#unsigned(B)), abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B))) ==K A) => #rangeSInt(256, A *Int B)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B =/=Int 0
```

from `dirty_lemmas.k.md` on 23/08/2019:

```k
rule WM[ N := #take(X, WS) ] => WM [ N := #asByteStackInWidth(#asWord(#take(X, WS)), X) ]

rule 0 -Word X => #unsigned(0 -Int X)
  requires 0 <=Int X andBool X <=Int pow255
/*
  proof:

  1) rule W0 -Word W1 => chop( (W0 +Int pow256) -Int W1 ) requires W0 <Int W1
  2) rule chop ( I:Int ) => I modInt pow256 [concrete, smt-lemma]
  3) rule W0 -Word W1 => chop( W0 -Int W1 ) requires W0 >=Int W1

  Assume X != 0:

  0 < X                   : 0 -W X =(1)=> chop( pow256 - X )
  0 < pow256 - X < pow256 : chop( pow256 - X ) =(2)=> pow256 - X

  Assume X == 0:

  0 == X                  : 0 -W 0 =(3)=> chop( 0 - 0 )
*/

rule #range(WS [ X := #padToWidth(32, Y) ], Z, 32, WSS) => #range(WS, Z, 32, WSS)
  requires Z +Int 32 <Int X

// possibly wrong but i'll keep using it as a hack
rule #sizeWordStack(#range(WS, Y, Z, WSS)) => Z

//assume ecrec returns an address
rule maxUInt160 &Int #symEcrec(MSG, V, R, S) => #symEcrec(MSG, V, R, S)

    rule 0 <=Int #symEcrec(MSG, V, R, S)             => true
    rule         #symEcrec(MSG, V, R, S) <Int pow256 => true

rule A -Word B <=Int A => 0 <=Int A -Int B
 requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule A <=Int chop(A +Int B) => A +Int B <=Int maxUInt256
 requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule #sgnInterp(sgn(chop(A *Int #unsigned(B))) *Int -1, abs(chop(A *Int #unsigned(B))) /Int (pow256 -Int #unsigned(B))) ==K A => #rangeSInt(256, A *Int B)
 requires #rangeUInt(256, A)
 andBool #rangeSInt(256, B)
 andBool B <Int 0

rule #sgnInterp(sgn(chop(A *Int #unsigned(B))), abs(chop(A *Int #unsigned(B))) /Int #unsigned(B)) ==K A => #rangeSInt(256, A *Int B)
 requires #rangeUInt(256, A)
 andBool #rangeSInt(256, B)
 andBool 0 <Int B

// Lemmas for Vat_frob_fail
rule A +Int #unsigned(B) => A +Int B
  requires #rangeUInt(256, A)
  andBool  #rangeUInt(256, B)
  andBool  #rangeUInt(256, A +Int B)

rule A +Int #unsigned(B) => A
  requires B ==K 0

// lemma for Jug_drip
rule A -Word B => #unsigned(A -Int B)
 requires #rangeSInt(256, A)
  andBool #rangeSInt(256, B)
  andBool 0 <=Int B
  andBool 0 <=Int A

// lemmas for End_skim
rule (A +Int (0 -Int B)) => A -Int B
rule (A *Int (0 -Int B)) => (0 -Int (A *Int B))
rule (A -Int (0 -Int B)) => A +Int B
//lemmas for End_bail
rule (0 -Int A) <Int B => (0 -Int B) <Int A
  requires (notBool #isConcrete(A))
  andBool #isConcrete(B)
rule (0 -Int A) <=Int B => (0 -Int B) <=Int A
  requires (notBool #isConcrete(A))
  andBool #isConcrete(B)
rule A <=Int (0 -Int B) => B <=Int 0 -Int A
  requires (notBool #isConcrete(B))
  andBool #isConcrete(A)
rule A <Int (0 -Int B) => B <Int 0 -Int A
  requires (notBool #isConcrete(B))
  andBool #isConcrete(A)

// Lemmas dealing with stupid 0
rule (0 -Int X) *Int Y => 0 -Int (X *Int Y)
rule (0 -Int X) /Int Y => 0 -Int (X /Int Y)

rule #unsigned( X *Int Y ) /Int #unsigned( Y ) => X
  requires #rangeSInt(256, X *Int Y)
  andBool #rangeSInt(256, X)
  andBool #rangeSInt(256, Y)
  andBool 0 <=Int X
  andBool 0 <Int Y

rule A +Int B => A
  requires B ==K 0
  andBool #isVariable(A)
  andBool #isVariable(B)

rule A +Int B => B
  requires A ==K 0
  andBool #isVariable(A)
  andBool #isVariable(B)

// lemma for Cat_bite-full to prevent unsigned(0 - X) devision
rule pow256 -Int #unsigned(0 -Int X) => X
  requires X >Int 0


// lemma to deal with deep nested calls - gas stuff
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int (A16 +Int (A17 +Int (X +Int AS)))))))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int (A16 +Int (A17 +Int AS)))))))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int (A16 +Int (X +Int AS))))))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int (A16 +Int AS))))))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int (X +Int AS)))))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (A15 +Int AS)))))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int (X +Int AS))))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (A14 +Int AS))))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int (X +Int AS)))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (A13 +Int AS)))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int (X +Int AS))))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (A12 +Int AS))))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int (X +Int AS)))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (A11 +Int AS)))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int (X +Int AS))))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (A10 +Int AS))))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int (X +Int AS)))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (A9 +Int AS)))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int (X +Int AS))))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (A8 +Int AS))))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int (X +Int AS)))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (A7 +Int AS)))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int (X +Int AS))))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (A6 +Int AS))))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int (X +Int AS)))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (A5 +Int AS)))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int (X +Int AS))))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int (A4 +Int AS))))
rule X -Int (A1 +Int (A2 +Int (A3 +Int (X +Int AS)))) => 0 -Int (A1 +Int (A2 +Int (A3 +Int AS)))
rule X -Int (A1 +Int (A2 +Int (X +Int AS))) => 0 -Int (A1 +Int (A2 +Int AS))

// Vat_fork-same_fail lemma
rule X +Int (pow256 -Int #unsigned(Y)) => X -Int Y
  requires Y <Int 0
  andBool  0 <=Int X -Int Y

rule #unsigned(X) -Int (pow256 +Int X) => 0
  requires X <Int 0

// Cat_bite_full_fail_rough lemma
// rule #sgnInterp(sgn(chop(A *Int #unsigned(0 -Int B))) *Int -1, abs(chop(A *Int #unsigned(0 -Int B))) /Int B) ==K A => #rangeSInt(256, A *Int (0 -Int B))
//   requires #rangeUInt(256, A)
//   andBool 0 <Int B
//   andBool #rangeSInt(256, 0 -Int B)

// skim/bail Rate * Art <= pow255 (condition for grab)
rule #signed(chop((A *Int #unsigned((0 -Int B))))) <=Int 0 => #rangeSInt(256, 0 -Int (A *Int B))
  requires #rangeUInt(256, A)
  andBool 0 <Int B
  andBool #rangeSInt(256, 0 -Int B)

rule chop(A *Int #unsigned(0 -Int B)) <=Int maxSInt256 andBool minSInt256 <=Int chop(A *Int #unsigned(0 -Int B)) => #rangeSInt(256, A *Int (0 -Int B))
  requires #rangeUInt256(A)
  andBool #rangeUInt256(A *Int B)
  andBool 0 <Int B
  andBool #rangeSInt(256, 0 -Int B)
```
