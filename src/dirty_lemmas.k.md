This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

```k
rule WM[ N := #take(X, WS) ] => WM [ N := #asByteStackInWidth(#asWord(#take(X, WS)), X) ]

syntax Int ::= "posMinSInt256"
rule posMinSInt256 => 57896044618658097711785492504343953926634992332820282019728792003956564819968  [macro]  /*  2^255      */

rule 0 -Word X => #unsigned(0 -Int X)
  requires 0 <=Int X
  andBool X <=Int posMinSInt256
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
```
