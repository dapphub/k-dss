This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

```k
rule WM[ N := #take(X, WS) ] => WM [ N := #asByteStackInWidth(#asWord(#take(X, WS)), X) ]

rule 0 -Word X => #unsigned(0 -Int X)
  requires 0 <=Int X
  andBool X <=Int pow255
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
rule #sizeWordStack(#range(WS, Y, Z, WSS), 0) => Z

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

//transitivity mf
rule X <=Int 0 => X ==Int 0
  requires 0 ==Int X

rule 0 <=Int X => X ==Int 0
  requires X ==Int 0


// Lemmas for Vat_frob_fail
rule A +Int #unsigned(B) => A +Int B
  requires #rangeUInt(256, A)
  andBool  #rangeUInt(256, B)
  andBool  #rangeUInt(256, A +Int B)

rule A +Int #unsigned(B) => A
  requires B ==K 0

// lemma for Jug_drip
rule A -Word B => #unsigned(A -Int B)
  requires #inRangeSInt(256, A)
  andBool #inRangeSInt(256, B)
  andBool 0 <Int B

// lemmas for End_skim
rule (A +Int (0 -Int B)) => A -Int B
rule (A *Int (0 -Int B)) => (0 -Int (A *Int B))
rule (A -Int (0 -Int B)) => A +Int B
//lemmas for End_bail
rule (0 -Int A) <Int B => B <Int A
rule (0 -Int A) <=Int B => B <=Int A
rule A <=Int (0 -Int B) => B <=Int A
rule A <Int (0 -Int B) => B <Int A

```
