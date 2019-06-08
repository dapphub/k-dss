### Flop

```k
syntax Int ::= "#Flopper.wards" "[" Int "]" [function]
// ---------------------------------------
// doc: whether `$0` is an owner of `Flop`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Flopper.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Flopper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
// doc: current bid (dai)
// act:
rule #Flopper.bids[N].bid => #hashedLocation("Solidity", 1, N) +Int 0

syntax Int ::= "#Flopper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
// doc: current lot (gem)
// act:
rule #Flopper.bids[N].lot => #hashedLocation("Solidity", 1, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.bids" "[" Int "].usr_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].usr_tic_end => #hashedLocation("Solidity", 1, N) +Int 2

syntax Int ::= "#Flopper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
// doc: beneficiary of the auction
// act:
rule #Flopper.bids[N].gal => #hashedLocation("Solidity", 1, N) +Int 3

syntax Int ::= "#Flopper.vat" [function]
// ---------------------------------------
// doc: dai token
// act:
rule #Flopper.vat => 2

syntax Int ::= "#Flopper.gem" [function]
// ---------------------------------------
// doc: mkr token
// act:
rule #Flopper.gem => 3

syntax Int ::= "#Flopper.beg" [function]
// ---------------------------------------
// doc: minimum bid increment
// act:
rule #Flopper.beg => 4

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flopper.ttl_tau => 5

syntax Int ::= "#Flopper.kicks" [function]
// ---------------------------------------
// doc: auction counter
// act:
rule #Flopper.kicks => 6

syntax Int ::= "#Flopper.live" [function]
// ---------------------------------------
// doc: liveness flag
// act:
rule #Flopper.live => 7
```
