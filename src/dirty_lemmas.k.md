This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

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

```
