This is an example for rules that won't affect the proof hashes
this should be "flushed" once in a while to the real lemmas.k file

### DSValue

```k
syntax Int ::= "#DSValue.authority" [function]
rule #DSValue.authority => 0

syntax Int ::= "#DSValue.owner_has" [function]
rule #DSValue.owner_has => 1

syntax Int ::= "#DSValue.val" [function]
rule #DSValue.val => 2

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

rule WM[ N := #take(X, WS) ] => WM [ N := #asByteStackInWidth(#asWord(#take(X, WS)), X) ]

rule (chop(chop(A *Int B) /Int B) ==K A) => A *Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

rule posMinSInt256      => 57896044618658097711785492504343953926634992332820282019728792003956564819968  [macro]  /*  2^255      */


```
