# dss storage model

### tune.sol

TODO: check K string literal comparison!

```
   syntax Int ::= "#root" [function]
// ---------------------------------
   rule #root => 0

   syntax Int ::= #dai( Int ) [function]
// -------------------------------------
   rule #dai(A) => #hashedLocation("Solidity", 1, A)

   syntax Int ::= #sin( Int ) [function]
// -------------------------------------
   rule #sin(A) => #hashedLocation("Solidity", 2, A)

   syntax Int ::= #ilks( Int , String ) [function]
// -----------------------------------------------
   rule #ilks(Ilk, S) => #hashedLocation("Solidity", 3, Ilk) +Int 0
	 requires S ==K "rate"

   rule #ilks(Ilk, S) => #hashedLocation("Solidity", 3, Ilk) +Int 1
	 requires S ==K "Art"

   syntax Int ::= #urns( Int , Int , String ) [function]
// -----------------------------------------------------
   rule #urns(Ilk, Guy, S) => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0
	 requires S ==K "gem"

   rule #urns(Ilk, Guy, S) => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1
	 requires S ==K "ink"

   rule #urns(Ilk, Guy, S) => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2
	 requires S ==K "art"

   syntax Int ::= "#Tab" [function]
// --------------------------------
   rule #Tab => 5

   syntax Int ::= "#vice" [function]
// ---------------------------------
   rule #vice => 6
	
```
