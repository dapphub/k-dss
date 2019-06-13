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
```
