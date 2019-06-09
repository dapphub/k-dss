### These work

Unfortunately they don't allow for reading the initial usr_tic_end slot
values separately.

```act
behaviour kill2 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : address
  UTE    : uint256

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> UTE => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
```


```act
behaviour kill5 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : address
  UTE    : uint256

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> UTE => 0
  bids[id].gal |-> Gal => #DropAddr(Gal)

iff
  VCallValue == 0
```

```act
behaviour kill6 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : uint256
  UTE    : uint256

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> UTE => 0
  bids[id].gal |-> Gal => #DropAddr(Gal)

iff
  VCallValue == 0
```

### These don't work

This one doesn't work because we overwrite the whole slot that Gal is
in. This is wrong, we should leave the higher bytes untouched.

```act
behaviour kill1 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : uint256
  UTE    : uint256

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> UTE => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
```

These don't work because WorkPackAddrUint48UInt48 is broken somehow.

```act
behaviour kill3 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : address
  UTE    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
```

```act
behaviour kill4 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : address
  UTE    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => #WordPackAddrUInt48UInt48(0, 0, 0)
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
```

```act
behaviour kill7 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Gal    : address
  Guy    : address
  Tic    : uint48
  End    : uint48


storage
  bids[id].bid         |-> Bid => 0
  bids[id].lot         |-> Lot => 0
  bids[id].usr_tic_end |-> #WordPackAddrUInt48UInt48(Guy, Tic, End) => 0
  bids[id].gal         |-> Gal => 0

iff
  VCallValue == 0
```


### Maybe this will work

We try and make something that works with manual unpacking..

```act
behaviour kill8 of Flopper
interface kill(uint256 id)

for all
  Bid    : uint256
  Lot    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48
  Gal    : address

storage
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> End * pow208 + Tic * pow160 + Guy => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
```

This works, but we don't use `End`, `Tic` or `Guy` anywhere.

Try a simple getter that consumes the values:

```act
behaviour look of Flopper
interface look(uint256 id)

for all
  Live   : uint256
  Bid    : uint256
  Lot    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48
  Gal    : address

storage
  live         |-> Live
  bids[id].bid |-> Bid
  bids[id].lot |-> Lot
  bids[id].usr_tic_end |-> End * pow208 + Tic * pow160 + Guy
  bids[id].gal |-> Gal

iff
  VCallValue == 0
  Live == 1
  Tic > 0
  End < TIME
  Guy =/= 0
```

And then try to adjust the values..

```act
behaviour tank of Flopper
interface tank(uint256 id)

for all
  Live   : uint256
  Bid    : uint256
  Lot    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48
  Gal    : address

storage
  live         |-> Live
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> End * pow208 + Tic * pow160 + Guy => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
  Live == 0
  Guy =/= 0
```

```act
behaviour dale of Flopper
interface dale(uint256 id)

for all
  Live   : uint256
  Bid    : uint256
  Lot    : uint256
  Guy    : address
  Tic    : uint48
  End    : uint48
  Gal    : address

storage
  live         |-> Live
  bids[id].bid |-> Bid => 0
  bids[id].lot |-> Lot => 0
  bids[id].usr_tic_end |-> End * pow208 + Tic * pow160 + Guy => 0
  bids[id].gal |-> Gal => 0

iff
  VCallValue == 0
  Live == 1
  (Tic < TIME and Tic =/= 0) or (End < TIME)
```
