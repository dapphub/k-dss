# dss storage model

TODO: check K string literal comparison!

```
rule #root => 0

rule #dai(A) => #hashedLocation(\"Solidity\", 1, A)

rule #sin(A) => #hashedLocation(\"Solidity\", 2, A)

rule #ilks(Ilk, S) => #hashedLocation(\"Solidity\", 3, Ilk) +Int 0
  requires S == "rate"

rule #ilks(Ilk, S) => #hashedLocation(\"Solidity\", 3, Ilk) +Int 1
  requires S == "Art"

rule #urns(Ilk, Guy, S) => #hashedLocation(\"Solidity\", 4, Ilk Guy) +Int 0
  requires S == "gem"
  
rule #urns(Ilk, Guy, S) => #hashedLocation(\"Solidity\", 4, Ilk Guy) +Int 1
  requires S == "ink"
  
rule #urns(Ilk, Guy, S) => #hashedLocation(\"Solidity\", 4, Ilk Guy) +Int 2
  requires S == "art"

rule #Tab => 5

rule #vice => 6
```
