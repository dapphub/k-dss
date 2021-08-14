# dss storage model

### Vat

```k
// act: public
syntax Int ::= "#Vat.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `Vat`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Vat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vat.can" "[" Int "][" Int "]" [function]
// -----------------------------------------------
// doc: whether `$1` can spend the resources of `$0`
// act: address `$0` has authorized `$1`
rule #Vat.can[A][B] => #hashedLocation("Solidity", 1, A B)

syntax Int ::= "#Vat.ilks" "[" Int "].Art" [function]
// ----------------------------------------------------
// doc: total debt units issued from `$0`
// act: `$0` has debt issuance `.`
rule #Vat.ilks[Ilk].Art => #hashedLocation("Solidity", 2, Ilk) +Int 0

syntax Int ::= "#Vat.ilks" "[" Int "].rate" [function]
// ----------------------------------------------------
// doc: debt unit rate of `$0`
// act: `$0` has debt unit rate `.`
rule #Vat.ilks[Ilk].rate => #hashedLocation("Solidity", 2, Ilk) +Int 1

syntax Int ::= "#Vat.ilks" "[" Int "].spot" [function]
// -----------------------------------------------
// doc: price with safety margin for `$0`
// act: `$0` has safety margin `.`
rule #Vat.ilks[Ilk].spot => #hashedLocation("Solidity", 2, Ilk) +Int 2

syntax Int ::= "#Vat.ilks" "[" Int "].line" [function]
// -----------------------------------------------
// doc: debt ceiling for `$0`
// act: `$0` has debt ceiling `.`
rule #Vat.ilks[Ilk].line => #hashedLocation("Solidity", 2, Ilk) +Int 3

syntax Int ::= "#Vat.ilks" "[" Int "].dust" [function]
// -----------------------------------------------
// doc: urn debt floor for `$0`
// act: `$0` has debt floor `.`
rule #Vat.ilks[Ilk].dust => #hashedLocation("Solidity", 2, Ilk) +Int 4

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].ink" [function]
// ----------------------------------------------------------
// doc: locked collateral units in `$0` assigned to `$1`
// act: agent `$1` has `.` collateral units in `$0`
rule #Vat.urns[Ilk][Usr].ink => #hashedLocation("Solidity", 3, Ilk Usr)

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].art" [function]
// ----------------------------------------------------------
// doc: debt units in `$0` assigned to `$1`
// act: agent `$1` has `.` debt units in `$0`
rule #Vat.urns[Ilk][Usr].art => #hashedLocation("Solidity", 3, Ilk Usr) +Int 1

syntax Int ::= "#Vat.gem" "[" Int "][" Int "]" [function]
// ---------------------------------------------
// doc: unlocked collateral in `$0` assigned to `$1`
// act: agent `$1` has `.` unlocked collateral in `$0`
rule #Vat.gem[Ilk][Usr] => #hashedLocation("Solidity", 4, Ilk Usr)

syntax Int ::= "#Vat.dai" "[" Int "]" [function]
// ---------------------------------------------
// doc: dai assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.dai[A] => #hashedLocation("Solidity", 5, A)

syntax Int ::= "#Vat.sin" "[" Int "]" [function]
// ---------------------------------------------
// doc: system debt assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.sin[A] => #hashedLocation("Solidity", 6, A)

syntax Int ::= "#Vat.debt" [function]
// ---------------------------------
// doc: total dai issued from the system
// act: there is `.` dai in total
rule #Vat.debt => 7

syntax Int ::= "#Vat.vice" [function]
// ----------------------------------
// doc: total system debt
// act: there is `.` system debt
rule #Vat.vice => 8

syntax Int ::= "#Vat.Line" [function]
// ----------------------------------
// doc: global debt ceiling
// act: the global debt ceiling is `.`
rule #Vat.Line => 9

syntax Int ::= "#Vat.live" [function]
// ----------------------------------
// doc: system status
// act: the system is `. == 1 ? : not` live
rule #Vat.live => 10
```

### Dai

```k
syntax Int ::= "#Dai.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `Vat`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Dai.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Dai.totalSupply" [function]
// -----------------------------------------------
// doc: the total supply of this token
// act: the total supply is .`
rule #Dai.totalSupply => 1

syntax Int ::= "#Dai.balanceOf" "[" Int "]" [function]
// -----------------------------------------------
// doc: the balance of a user
// act: the balance of `$0 is .` us ,
rule #Dai.balanceOf[A] => #hashedLocation("Solidity", 2, A)

syntax Int ::= "#Dai.allowance" "[" Int "][" Int "]" [function]
// -----------------------------------------------
// doc: the amount that can be spent on someones behalf
// act: `$1 can spend `.` tokens belonging to `$0`
rule #Dai.allowance[A][B] => #hashedLocation("Solidity", 3, A B)

syntax Int ::= "#Dai.nonces" "[" Int "]" [function]
// -----------------------------------------------
// doc: the amount that can be spent on someones behalf
// act: `$1 can spend `.` tokens belonging to `$0`
rule #Dai.nonces[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Dai.DOMAIN_SEPARATOR" [function]
// -----------------------------------------------
// doc: the amount that can be spent on someones behalf
// act: `$1 can spend `.` tokens belonging to `$0`
rule #Dai.DOMAIN_SEPARATOR => 5
```

### Jug

```k
syntax Int ::= "#Jug.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `Jug`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Jug.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Jug.ilks" "[" Int "].duty" [function]
// ----------------------------------------------------
// doc:
// act:
rule #Jug.ilks[Ilk].duty => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Jug.ilks" "[" Int "].rho" [function]
// ----------------------------------------------------
// doc:
// act:
rule #Jug.ilks[Ilk].rho => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Jug.vat" [function]
// ----------------------------------
// doc: `Vat` that this `Jug` points to
// act: this Jug points to Vat `.`
rule #Jug.vat => 2

syntax Int ::= "#Jug.vow" [function]
// ----------------------------------
// doc: `Vow` that this `Jug` points to
// act: this Jug points to Vow `.`
rule #Jug.vow => 3

syntax Int ::= "#Jug.base" [function]
// ----------------------------------
// doc:
// act:
rule #Jug.base => 4
```

### Drip

```k
syntax Int ::= "#Drip.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `Drip`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Drip.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Drip.ilks" "[" Int "].tax" [function]
// ----------------------------------------------------
// doc: stability fee of `$0`
// act: `$0` has stability fee `.`
rule #Drip.ilks[Ilk].tax => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Drip.ilks" "[" Int "].rho" [function]
// ----------------------------------------------------
// doc: last drip time of `$0`
// act: `$0` was dripped at `.`
rule #Drip.ilks[Ilk].rho => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Drip.vat" [function]
// ----------------------------------
// doc: `Vat` that this `Drip` points to
// act: this Drip points to Vat `.`
rule #Drip.vat => 2

syntax Int ::= "#Drip.vow" [function]
// ----------------------------------
// doc: `Vow` that this `Drip` points to
// act: this Drip points to Vow `.`
rule #Drip.vow => 3

syntax Int ::= "#Drip.repo" [function]
// -----------------------------------
// doc: base interest rate
// act: the base interest rate is `.`
rule #Drip.repo => 4
```

### Vow

```k
syntax Int ::= "#Vow.wards" "[" Int "]" [function]
// ---------------------------------
// doc: whether `$0` is an owner of `Vow`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Vow.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vow.vat" [function]
// ---------------------------------
// doc: `Vat` that this `Vow` points to
// act: this Vow points to Vat `.`
rule #Vow.vat => 1

syntax Int ::= "#Vow.flapper" [function]
// ---------------------------------
// doc: `Flapper` that this `Vow` points to
// act: this Vow points to Flapper `.`
rule #Vow.flapper => 2

syntax Int ::= "#Vow.flopper" [function]
// ---------------------------------
// doc: `Flopper` that this `Vow` points to
// act: this Vow points to Flopper `.`
rule #Vow.flopper => 3

syntax Int ::= "#Vow.sin" "[" Int "]" [function]
// ---------------------------------------------
// doc: sin queued at timestamp `$0`
// act: `.` sin queued at timestamp `$0`
rule #Vow.sin[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Vow.Sin" [function]
// ---------------------------------
// doc: total queued sin
// act: the total queued sin is `.`
rule #Vow.Sin => 5

syntax Int ::= "#Vow.Ash" [function]
// ---------------------------------
// doc: total sin in debt auctions
// act: the total sin in debt auctions is `.`
rule #Vow.Ash => 6

syntax Int ::= "#Vow.wait" [function]
// ----------------------------------
// doc: sin maturation time
// act: the sin maturation time is `.`
rule #Vow.wait => 7

syntax Int ::= "#Vow.dump" [function]
// ----------------------------------
// doc: flop initial lot size
// act: the flop initial lot size is `.`
rule #Vow.dump => 8

syntax Int ::= "#Vow.sump" [function]
// ----------------------------------
// doc: debt auction lot size
// act: the debt auction lot size is `.`
rule #Vow.sump => 9

syntax Int ::= "#Vow.bump" [function]
// ----------------------------------
// doc: surplus auction lot size
// act: the surplus auction lot size is `.`
rule #Vow.bump => 10

syntax Int ::= "#Vow.hump" [function]
// ---------------------------------
// doc: surplus dai cushion
// act: the surplus dai cushion is `.`
rule #Vow.hump => 11

syntax Int ::= "#Vow.live" [function]
// ---------------------------------
// doc: liveness flag
// act: the system is active/inactive `.`
rule #Vow.live => 12

```

### Cat

```k
syntax Int ::= "#Cat.wards" "[" Int "]" [function]
// ---------------------------------
// doc: whether `$0` is an owner of `Cat`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Cat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Cat.ilks" "[" Int "].flip" [function]
// ---------------------------------------------------
// doc: `Flipper` for `$0`
// act:
rule #Cat.ilks[Ilk].flip => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Cat.ilks" "[" Int "].chop" [function]
// ---------------------------------------------------
// doc: liquidation penalty for `$0`
// act:
rule #Cat.ilks[Ilk].chop => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Cat.ilks" "[" Int "].lump" [function]
// ---------------------------------------------------
// doc: liquidation lot size for `$0`
// act:
rule #Cat.ilks[Ilk].lump => #hashedLocation("Solidity", 1, Ilk) +Int 2

syntax Int ::= "#Cat.live" [function]
// ----------------------------------
// doc: system liveness
// act:
rule #Cat.live => 2

syntax Int ::= "#Cat.vat" [function]
// ---------------------------------
// doc: `Vat` that this `Cat` points to
// act:
rule #Cat.vat => 3

syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
// doc: `Vow` that this `Cat` points to
// act:
rule #Cat.vow => 4
```

### GemJoin

```k
syntax Int ::= "#GemJoin.wards" "[" Int "]"  [function]
// ---------------------------------
// doc: whether `$0` is an owner of `GemJoin`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #GemJoin.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#GemJoin.vat" [function]
// -------------------------------------
// doc: `Vat` that this adapter points to
// act:
rule #GemJoin.vat => 1

syntax Int ::= "#GemJoin.ilk" [function]
// -------------------------------------
// doc: collateral type of this adapter
// act:
rule #GemJoin.ilk => 2

syntax Int ::= "#GemJoin.gem" [function]
// -------------------------------------
// doc: underlying token of this adapter
// act:
rule #GemJoin.gem => 3

syntax Int ::= "#GemJoin.dec" [function]
// -------------------------------------
// doc: decimals of the underlying token
// act:
rule #GemJoin.dec => 4

syntax Int ::= "#GemJoin.live" [function]
// -------------------------------------
// doc: whether collateral can still be joined
// act:
rule #GemJoin.live => 5
```

### DaiJoin

```k
syntax Int ::= "#DaiJoin.wards" "[" Int "]"  [function]
// ---------------------------------
// doc: whether `$0` is an owner of `DaiJoin`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #DaiJoin.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#DaiJoin.vat" [function]
// -------------------------------------
// doc: `Vat` that this adapter points to
// act:
rule #DaiJoin.vat => 1

syntax Int ::= "#DaiJoin.dai" [function]
// -------------------------------------
// doc: underlying dai token of this adapter
// act:
rule #DaiJoin.dai => 2

syntax Int ::= "#DaiJoin.live" [function]
// -------------------------------------
// doc: whether dai can still be withdrawn
// act:
rule #DaiJoin.live => 3
```

### Flip

```k
syntax Int ::= "#Flipper.wards" "[" Int "]" [function]
// ---------------------------------------
// doc: whether `$0` is an owner of `Flip`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Flipper.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Flipper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
// doc: current bid (dai)
// act:
rule #Flipper.bids[N].bid => #hashedLocation("Solidity", 1, N) +Int 0

syntax Int ::= "#Flipper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
// doc: current lot (gem)
// act:
rule #Flipper.bids[N].lot => #hashedLocation("Solidity", 1, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flipper.bids[N].guy_tic_end => #hashedLocation("Solidity", 1, N) +Int 2

syntax Int ::= "#Flipper.bids" "[" Int "].usr" [function]
// ------------------------------------------------------
// doc: CDP owner
// act:
rule #Flipper.bids[N].usr => #hashedLocation("Solidity", 1, N) +Int 3

syntax Int ::= "#Flipper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
// doc: beneficiary of the auction
// act:
rule #Flipper.bids[N].gal => #hashedLocation("Solidity", 1, N) +Int 4

syntax Int ::= "#Flipper.bids" "[" Int "].tab" [function]
// ------------------------------------------------------
// doc: beneficiary of the auction
// act:
rule #Flipper.bids[N].tab => #hashedLocation("Solidity", 1, N) +Int 5

syntax Int ::= "#Flipper.vat" [function]
// ---------------------------------------
// doc: CDP engine
// act:
rule #Flipper.vat => 2

syntax Int ::= "#Flipper.ilk" [function]
// ---------------------------------------
// doc: collateral type
// act:
rule #Flipper.ilk => 3

syntax Int ::= "#Flipper.beg" [function]
// ---------------------------------------
// doc: minimum bid increment
// act:
rule #Flipper.beg => 4

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flipper.ttl_tau => 5

syntax Int ::= "#Flipper.kicks" [function]
// ---------------------------------------
// doc: auction counter
// act:
rule #Flipper.kicks => 6
```


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
syntax Int ::= "#Flopper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flopper.bids[N].guy_tic_end => #hashedLocation("Solidity", 1, N) +Int 2

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

syntax Int ::= "#Flopper.pad" [function]
// -----------------------------------------
// doc: fractional increase on tick
// act:
rule #Flopper.pad => 5

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flopper.ttl_tau => 6

syntax Int ::= "#Flopper.kicks" [function]
// ---------------------------------------
// doc: auction counter
// act:
rule #Flopper.kicks => 7

syntax Int ::= "#Flopper.live" [function]
// ---------------------------------------
// doc: liveness flag
// act:
rule #Flopper.live => 8

syntax Int ::= "#Flopper.vow" [function]
// ---------------------------------------
// doc: Vow address
// act:
rule #Flopper.vow => 9
```

### Flap

```k
syntax Int ::= "#Flapper.wards" "[" Int "]" [function]
// ---------------------------------------
// doc: whether `$0` is an owner of `Flop`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Flapper.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Flapper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
// doc: current bid (dai)
// act:
rule #Flapper.bids[N].bid => #hashedLocation("Solidity", 1, N) +Int 0

syntax Int ::= "#Flapper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
// doc: current lot (gem)
// act:
rule #Flapper.bids[N].lot => #hashedLocation("Solidity", 1, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
// doc:
// act:
rule #Flapper.bids[N].guy_tic_end => #hashedLocation("Solidity", 1, N) +Int 2

syntax Int ::= "#Flapper.vat" [function]
// ---------------------------------------
// doc: dai token
// act:
rule #Flapper.vat => 2

syntax Int ::= "#Flapper.gem" [function]
// ---------------------------------------
// doc: mkr token
// act:
rule #Flapper.gem => 3

syntax Int ::= "#Flapper.beg" [function]
// ---------------------------------------
// doc: minimum bid increment
// act:
rule #Flapper.beg => 4

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.ttl_tau" [function]
// -----------------------------------------
// doc:
// act:
rule #Flapper.ttl_tau => 5

syntax Int ::= "#Flapper.kicks" [function]
// ---------------------------------------
// doc: auction counter
// act:
rule #Flapper.kicks => 6

syntax Int ::= "#Flapper.live" [function]
// ---------------------------------------
// doc: liveness flag
// act:
rule #Flapper.live => 7
```

### GemLike

A hypothetical token contract, based on `ds-token`:

```k
syntax Int ::= "#Gem.balances" "[" Int "]" [function]
// --------------------------------------------------
// doc: `gem` balance of `$0`
// act:
rule #Gem.balances[A] => #hashedLocation("Solidity", 3, A)

syntax Int ::= "#Gem.stopped" [function]
// --------------------------------------------------
// doc: `gem` balance of `$0`
// act:
rule #Gem.stopped => 4

syntax Int ::= "#Gem.allowance" "[" Int "][" Int "]" [function]
// -----------------------------------------------
// doc: the amount that can be spent on someones behalf
// act: `$1 can spend `.` tokens belonging to `$0`
rule #Gem.allowance[A][B] => #hashedLocation("Solidity", 8, A B)
```

### End

```k
// act: public
syntax Int ::= "#End.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: whether `$0` is an owner of `End`
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #End.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#End.vat" [function]
// ---------------------------------
// doc: `Vat` that this `End` points to
// act:
rule #End.vat => 1

syntax Int ::= "#End.cat" [function]
// ---------------------------------
// doc: `cat` that this `End` points to
// act:
rule #End.cat => 2

syntax Int ::= "#End.vow" [function]
// ---------------------------------
// doc: `Vow` that this `End` points to
// act:
rule #End.vow => 3

syntax Int ::= "#End.pot" [function]
// ---------------------------------
// doc: `Pot` that this `End` points to
// act:
rule #End.pot => 4

syntax Int ::= "#End.spot" [function]
// ---------------------------------
// doc: `Spot` that this `End` points to
// act:
rule #End.spot => 5

syntax Int ::= "#End.live" [function]
// ----------------------------------
// doc: system liveness
// act:
rule #End.live => 6

syntax Int ::= "#End.when" [function]
// ----------------------------------
// doc: time of cage
// act:
rule #End.when => 7

syntax Int ::= "#End.wait" [function]
// ----------------------------------
// doc: processing period
// act:
rule #End.wait => 8

syntax Int ::= "#End.debt" [function]
// ----------------------------------
// doc: total outstanding debt following processing
// act:
rule #End.debt => 9

syntax Int ::= "#End.tag" "[" Int "]" [function]
// -----------------------------------------------
// doc: the cage price of ilk `$0`
// act:
rule #End.tag[Ilk] => #hashedLocation("Solidity", 10, Ilk)

syntax Int ::= "#End.gap" "[" Int "]" [function]
// -----------------------------------------------
// doc: the collateral shortfall of ilk `$0`
// act:
rule #End.gap[Ilk] => #hashedLocation("Solidity", 11, Ilk)

syntax Int ::= "#End.Art" "[" Int "]" [function]
// -----------------------------------------------
// doc: the total debt of ilk `$0`
// act:
rule #End.Art[Ilk] => #hashedLocation("Solidity", 12, Ilk)

syntax Int ::= "#End.fix" "[" Int "]" [function]
// -----------------------------------------------
// doc: the final cash price of ilk `$0`
// act:
rule #End.fix[Ilk] => #hashedLocation("Solidity", 13, Ilk)

syntax Int ::= "#End.bag" "[" Int "]" [function]
// -----------------------------------------------
// doc: the packed dai of user `$0`
// act:
rule #End.bag[Usr] => #hashedLocation("Solidity", 14, Usr)

syntax Int ::= "#End.out" "[" Int "][" Int "]" [function]
// ---------------------------------------------
// doc: cashed collateral of ilk `$0` assigned to `$1`
// act:
rule #End.out[Ilk][Usr] => #hashedLocation("Solidity", 15, Ilk Usr)
```

### Pot

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

syntax Int ::= "#Pot.live" [function]
// ----------------------------------
// doc:
// act:
rule #Pot.live => 8
```
### DSToken

```k
syntax Int ::= "#DSToken.supply" [function]
rule #DSToken.supply => 0

syntax Int ::= "#DSToken.balances" "[" Int "]" [function]
rule #DSToken.balances[A] => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#DSToken.allowance" "[" Int "][" Int "]" [function]
rule #DSToken.allowance[A][B] => #hashedLocation("Solidity", 2, A B)

syntax Int ::= "#DSToken.authority" [function]
rule #DSToken.authority => 3

syntax Int ::= "#DSToken.owner_stopped" [function]
rule #DSToken.owner_stopped => 4

syntax Int ::= "#DSToken.symbol" [function]
rule #DSToken.symbol => 5

syntax Int ::= "#DSToken.decimals" [function]
rule #DSToken.decimals => 6
```

### DSValue

```k
syntax Int ::= "#DSValue.authority" [function]
rule #DSValue.authority => 0

syntax Int ::= "#DSValue.owner_has" [function]
rule #DSValue.owner_has => 1

syntax Int ::= "#DSValue.val" [function]
rule #DSValue.val => 2

```

### Spotter

```act
syntax Int ::= "#Spotter.wards" "[" Int "]" [function]
rule #Spotter.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Spotter.ilks" "[" Int "].pip" [function]
rule #Spotter.ilks[Ilk].pip => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Spotter.ilks" "[" Int "].mat" [function]
rule #Spotter.ilks[Ilk].mat => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Spotter.vat" [function]
rule #Spotter.vat => 2

syntax Int ::= "#Spotter.par" [function]
rule #Spotter.par => 3

syntax Int ::= "#Spotter.live" [function]
rule #Spotter.live => 4
```
