This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

### DSValue

```k
rule WM[ N := #take(X, WS) ] => WM [ N := #asByteStackInWidth(#asWord(#take(X, WS)), X) ]

rule 1 |Int bool2Word(X) => 1

rule bool2Word(X) |Int 1 => 1

rule 1 &Int bool2Word(X) => bool2Word(X)

rule bool2Word(X) &Int 1 => bool2Word(X)


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


// rule 0 <Int #signed(#if X ==K 0 #then 0 #else pow256 -Int X #fi) => false
// requires 0 <=Int X
// andBool X <=Int posMinSInt256

/*
  4) rule #signed(DATA) => DATA
     requires 0 <=Int DATA andBool DATA <=Int maxSInt256

  5) rule #signed(DATA) => DATA -Int pow256
     requires maxSInt256 <Int DATA andBool DATA <=Int maxUInt256


  Assume X == 0:
    s(0) =(4)=> 0

  Assume 0 < X <= posMinSInt256(2^255):

  a) posMinSInt256(2^255) = maxSInt256(2^255 - 1) + 1

  proof pow255  - 1 <  pow256(2^256) - X <= pow256 - 1:
  proof pow255  - 1 <  pow256 - X
      -pow255 - 1   <  - X                               |-pow256
        X           <  pow255 + 1                        |*-1
        X           <= pow255
        X           <= posMinSInt256

  proof pow256 - X <= pow256 - 1
    -X <= -1                                          |-pow256
     1 <=  X                                          |*-1


  need: 0 <= X < maxSInt256


*/


rule #range(WS [ X := #padToWidth(32, Y) ], Z, 32, WSS) => #range(WS, Z, 32, WSS)
  requires Z +Int 32 <Int X

// possibly wrong but i'll keep using it as a hack
rule #sizeWordStack(#range(WS, Y, Z, WSS), 0) => Z

// wrong but something like this is needed
// rule #range( WS [ X := #padToWidth(32, #asByteStack(DATA))], Y, Z, WSS) => #range( WS, Y - 32, Z -Int 32, #padToWidth(32, #asByteStack(DATA)) : WSS)
// requires X +Int 31 ==Int Y

//assume ecrec returns an address
rule maxUInt160 &Int #symEcrec(MSG, V, R, S) => #symEcrec(MSG, V, R, S)

    rule 0 <=Int #symEcrec(MSG, V, R, S)             => true
    rule         #symEcrec(MSG, V, R, S) <Int pow256 => true


syntax IntList ::= bytesToWords ( WordStack )       [function]
 // --------------------------------------------------------------
    rule bytesToWords ( WS )
         => #asWord(#take(#sizeWordStack(WS) modInt 32, WS)) byteStack2IntList(#drop(#sizeWordStack(WS) modInt 32, WS))
         requires #sizeWordStack(WS) modInt 32 >Int 0
    rule bytesToWords ( WS ) => byteStack2IntList(WS)
    requires #sizeWordStack(WS) modInt 32 ==Int 0
    rule keccak(WS) => keccakIntList(bytesToWords(WS))
      requires ( notBool #isConcrete(WS) )
       andBool notBool( #sizeWordStack(WS) modInt 32 ==Int 0)

// another gas optimisation
rule ((A -Int (X +Int C)) +Int ((C -Int D) -Int Y)) => ((A -Int X) -Int Y) -Int D

rule (#if C #then A #else B #fi *Int X) <=Int maxUInt256 => true
  requires A *Int X <=Int maxUInt256
  andBool B *Int X <=Int maxUInt256

```

### Pot storage

```k
syntax Int ::= "#Pot.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `Pot`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Pot.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Pot.pie" "[" Int "]" [function]
// ----------------------------------------------------
// doc: balance that `$0` has locked in this pot
// act:
rule #Pot.pie[Usr] => #hashedLocation("Solidity", 1, Usr)

syntax Int ::= "#Pot.Pie" [function]
// ----------------------------------
// doc: total amount of dai locked in this `Pot`
// act: this Pot points to Vat `.`
rule #Pot.Pie => 2

syntax Int ::= "#Pot.dsr" [function]
// ----------------------------------
// doc: the current deposit interest rate of this `Pot`
// act:
rule #Pot.dsr => 3

syntax Int ::= "#Pot.chi" [function]
// ----------------------------------
// doc: `Vat` that this `Pot` points to
// act: this Pot points to Vat `.`
rule #Pot.chi => 4

syntax Int ::= "#Pot.vat" [function]
// ----------------------------------
// doc: `Vat` that this `Pot` points to
// act: this Pot points to Vat `.`
rule #Pot.vat => 5

syntax Int ::= "#Pot.vow" [function]
// ----------------------------------
// doc: `Vow` that this `Pot` points to
// act: this Pot points to Vow `.`
rule #Pot.vow => 6

syntax Int ::= "#Pot.rho" [function]
// ----------------------------------
// doc:
// act:
rule #Pot.rho => 7
```
