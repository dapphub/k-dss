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
    
```
