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
