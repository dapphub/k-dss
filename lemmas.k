// uint48 support:

syntax Int ::= "minUInt48"      [function]
             | "maxUInt48"      [function]

rule minUInt48      =>  0               [macro]
rule maxUInt48      =>  281474976710655 [macro]  /*   2^48 - 1  */

rule #rangeUInt ( 48 , X ) => #range ( minUInt48 <= X <= maxUInt48) [macro]

// solidity word packing support
// unpacking these might require some easy lemmas about division

syntax Int ::= "#WordPackUInt48UInt48" "(" Int "," Int ")" [function]
// ----------------------------------------------------------
rule #WordPackUInt48UInt48(X, Y) => Y *Int (2 ^Int 48) +Int X
  requires #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

syntax Int ::= "#WordPackAddrUInt48UInt48" "(" Int "," Int "," Int ")" [function]
// ----------------------------------------------------------------------
rule #WordPackAddrUInt48UInt48(A, X, Y) => Y *Int (2 ^Int 208) +Int X *Int (2 ^Int 160) +Int A
  requires #rangeAddress(A)
  andBool #rangeUInt(48, X)
  andBool #rangeUInt(48, Y)

// DSL for abstracted storage:
syntax Int ::= "#Vat.dai" "(" Int ")" [function]
// ---------------------------------------------
rule #Vat.dai(A) => #hashedLocation("Solidity", 1, A)

syntax Int ::= "#Vat.sin" "(" Int ")" [function]
// ---------------------------------------------
rule #Vat.sin(A) => #hashedLocation("Solidity", 2, A)

syntax Int ::= "#Vat.ilks" "(" Int ").rate" [function]
// ----------------------------------------------------
rule #Vat.ilks(Ilk).rate => #hashedLocation("Solidity", 3, Ilk) +Int 0

syntax Int ::= "#Vat.ilks" "(" Int ").Art" [function]
// -----------------------------------------------
rule #Vat.ilks(Ilk).Art => #hashedLocation("Solidity", 3, Ilk) +Int 1

syntax Int ::= "#Vat.urns" "(" Int "," Int ").ink" [function]
// ----------------------------------------------------------
rule #Vat.urns(Ilk, Guy).ink => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

syntax Int ::= "#Vat.urns" "(" Int "," Int ").art" [function]
// ----------------------------------------------------------
rule #Vat.urns(Ilk, Guy).art => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2

syntax Int ::= "#Vat.debt" [function]
// ---------------------------------
rule #Vat.debt => 5

syntax Int ::= "#Vat.vice" [function]
// ----------------------------------
rule #Vat.vice => 6

syntax Int ::= "#Vat.gem" "(" Int "," Int ")" [function]
// ---------------------------------------------
rule #Vat.gem(Ilk, Guy) => #hashedLocation("Solidity", 7, Ilk Guy)

syntax Int ::= "#Pit.vat" [function]
// ---------------------------------
rule #Pit.vat => 0

syntax Int ::= "#Pit.Line" [function]
// ----------------------------------
rule #Pit.Line => 1

syntax Int ::= "#Pit.live" [function]
// ----------------------------------
rule #Pit.live => 2

syntax Int ::= "#Pit.ilks" "(" Int ").spot" [function]
// ---------------------------------------------------
rule #Pit.ilks(Ilk).spot => #hashedLocation("Solidity", 3, Ilk) +Int 0

syntax Int ::= "#Pit.ilks" "(" Int ").line" [function]
// ---------------------------------------------------
rule #Pit.ilks(Ilk).line => #hashedLocation("Solidity", 3, Ilk) +Int 1

syntax Int ::= "#Vow.vat" [function]
// ---------------------------------
rule #Vow.vat => 0

syntax Int ::= "#Vow.cow" [function]
// ---------------------------------
rule #Vow.cow => 1

syntax Int ::= "#Vow.row" [function]
// ---------------------------------
rule #Vow.row => 2

syntax Int ::= "#Vow.sin" "(" Int ")" [function]
// ---------------------------------------------
rule #Vow.sin(A) => #hashedLocation("Solidity", 3, A)

syntax Int ::= "#Vow.Sin" [function]
// ---------------------------------
rule #Vow.Sin => 4

syntax Int ::= "#Vow.Woe" [function]
// ---------------------------------
rule #Vow.Woe => 5

syntax Int ::= "#Vow.Ash" [function]
// ---------------------------------
rule #Vow.Ash => 6

syntax Int ::= "#Vow.wait" [function]
// ----------------------------------
rule #Vow.wait => 7

syntax Int ::= "#Vow.lump" [function]
// ----------------------------------
rule #Vow.lump => 8

syntax Int ::= "#Vow.pad" [function]
// ---------------------------------
rule #Vow.pad => 9

syntax Int ::= "#Cat.vat" [function]
// ---------------------------------
rule #Cat.vat => 0

syntax Int ::= "#Cat.pit" [function]
// ---------------------------------
rule #Cat.pit => 1

syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
rule #Cat.vow => 2

syntax Int ::= "#Cat.lump" [function]
// ----------------------------------
rule #Cat.lump => 3

syntax Int ::= "#Cat.ilks" "(" Int ").chop" [function]
// ---------------------------------------------------
rule #Cat.ilks(Ilk).chop => #hashedLocation("Solidity", 4, Ilk) +Int 0

syntax Int ::= "#Cat.ilks" "(" Int ").flip" [function]
// ---------------------------------------------------
rule #Cat.ilks(Ilk).flip => #hashedLocation("Solidity", 4, Ilk) +Int 1

syntax Int ::= "#Cat.nflip" [function]
// -----------------------------------
rule #Cat.nflip => 5

syntax Int ::= "#Cat.Flips" "(" Int ").ilk" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).ilk => #hashedLocation("Solidity", 6, N) +Int 0

syntax Int ::= "#Cat.Flips" "(" Int ").lad" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).lad => #hashedLocation("Solidity", 6, N) +Int 1

syntax Int ::= "#Cat.Flips" "(" Int ").ink" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).ink => #hashedLocation("Solidity", 6, N) +Int 2

syntax Int ::= "#Cat.Flips" "(" Int ").tab" [function]
// ---------------------------------------------------
rule #Cat.Flips(N).tab => #hashedLocation("Solidity", 6, N) +Int 3

syntax Int ::= "#Adapter.vat" [function]
// -------------------------------------
rule #Adapter.vat => 0

syntax Int ::= "#Adapter.ilk" [function]
// -------------------------------------
rule #Adapter.ilk => 1

syntax Int ::= "#Adapter.gem" [function]
// -------------------------------------
rule #Adapter.gem => 2

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.ttl_tau" [function]
// -----------------------------------------
rule #Flipper.ttl_tau => 3

syntax Int ::= "#Flipper.kicks" [function]
// ---------------------------------------
rule #Flipper.kicks => 4

syntax Int ::= "#Flipper.bids" "(" Int ").bid" [function]
// ------------------------------------------------------
rule #Flipper.bids(N).bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flipper.bids" "(" Int ").lot" [function]
// ------------------------------------------------------
rule #Flipper.bids(N).lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.bids" "(" Int ").guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flipper.bids(N).guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flipper.bids" "(" Int ").lad" [function]
// ------------------------------------------------------
rule #Flipper.bids(N).lad => #hashedLocation("Solidity", 5, N) +Int 3

syntax Int ::= "#Flipper.bids" "(" Int ").gal" [function]
// ------------------------------------------------------
rule #Flipper.bids(N).gal => #hashedLocation("Solidity", 5, N) +Int 4

syntax Int ::= "#Flipper.bids" "(" Int ").tab" [function]
// ------------------------------------------------------
rule #Flipper.bids(N).tab => #hashedLocation("Solidity", 5, N) +Int 5

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.ttl_tau" [function]
// -----------------------------------------
rule #Flapper.ttl_tau => 3

syntax Int ::= "#Flapper.kicks" [function]
// ---------------------------------------
rule #Flapper.kicks => 4

syntax Int ::= "#Flapper.bids" "(" Int ").bid" [function]
// ------------------------------------------------------
rule #Flapper.bids(N).bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flapper.bids" "(" Int ").lot" [function]
// ------------------------------------------------------
rule #Flapper.bids(N).lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.bids" "(" Int ").guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flapper.bids(N).guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flapper.bids" "(" Int ").gal" [function]
// ------------------------------------------------------
rule #Flapper.bids(N).gal => #hashedLocation("Solidity", 5, N) +Int 3

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.ttl_tau" [function]
// -----------------------------------------
rule #Flopper.ttl_tau => 3

syntax Int ::= "#Flopper.kicks" [function]
// ---------------------------------------
rule #Flopper.kicks => 4

syntax Int ::= "#Flopper.bids" "(" Int ").bid" [function]
// ------------------------------------------------------
rule #Flopper.bids(N).bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flopper.bids" "(" Int ").lot" [function]
// ------------------------------------------------------
rule #Flopper.bids(N).lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.bids" "(" Int ").guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flopper.bids(N).guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flopper.bids" "(" Int ").vow" [function]
// ------------------------------------------------------
rule #Flopper.bids(N).vow => #hashedLocation("Solidity", 5, N) +Int 3

syntax Int ::= "#Gem.balances" "(" Int ")" [function]
// --------------------------------------------------
rule #Gem.balances(A) => #hashedLocation("Solidity", 1, A)

// misc:

// hashed storage offsets never overflow (probabilistic assumption):
rule chop(keccakIntList(L) +Int N) => keccakIntList(L) +Int N
  requires N <=Int 100

syntax Int ::= "#wad2rad" "(" Int ")" [function]
// ---------------------------------------
rule #wad2rad(X) => X *Int 1000000000000000000000000000

// Lemmas:

rule WS ++ .WordStack => WS

rule #sizeWordStack ( #padToWidth ( 32 , #asByteStack ( #unsigned ( W ) ) ) , 0) => 32
  requires #rangeSInt(256, W)

// custom ones:
rule #asWord(#padToWidth(32, #asByteStack(#unsigned(X)))) => #unsigned(X)
  requires #rangeSInt(256, X)

// rule #take(N, #padToWidth(N, WS) ++ WS' ) => #padToWidth(N, WS)

// potentially useful
// rule #padToWidth(N, WS) ++ WS' => #padToWidth(N + #sizeWordStack(WS'), WS ++ WS')
// and the N, M versions

rule #take(N, #padToWidth(N, WS) ) => #padToWidth(N, WS)

rule W0 s<Word W1 => #signed(W0) <Word #signed(W1)

rule #signed(#unsigned(W)) => W
  requires #rangeSInt(256, W)

rule #unsigned(#signed(W)) => W
  requires #rangeUInt(256, W)

rule #unsigned(X) ==K 0 => X ==Int 0

rule 0 <Int #unsigned(X) => 0 <Int X

// addui
// lemmas for sufficiency
rule chop(A +Int #unsigned(B)) => A +Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A +Int B)

// lemmas for necessity
rule chop(A +Int #unsigned(B)) >Int A => (A +Int B <=Int maxUInt256)	      
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >=Int 0

rule chop(A +Int #unsigned(B)) <Int A => (A +Int B >=Int minUInt256)	      
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// subui
// lemmas for sufficiency
rule A -Word #unsigned(B) => A -Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A -Int B)

// lemmas for necessity
rule A -Word #unsigned(B) <Int A => (A -Int B >=Int minUInt256)	      
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >=Int 0

rule A -Word #unsigned(B) >Int A => (A -Int B <=Int maxUInt256)	      
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// mului
// lemmas for sufficiency
rule A *Int #unsigned(B) => #unsigned(A *Int B)
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)

rule abs(#unsigned(A *Int B)) /Int abs(#unsigned(B)) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool notBool (#unsigned(B) ==Int 0)

// possibly get rid of
rule #sgnInterp(sgn(W), abs(W)) => W
  requires #rangeUInt(256, W)

rule #sgnInterp(sgn(#unsigned(A *Int B)), A) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool B >=Int 0

rule #sgnInterp(sgn(#unsigned(A *Int B)) *Int (-1), A) => A
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A *Int B)
  andBool B <Int 0

// lemmas for necessity
rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))), abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B))) ==K A) => A *Int B <=Int maxSInt256
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B >Int 0

rule (#sgnInterp(sgn(chop(A *Int #unsigned(B))) *Int (-1), abs(chop(A *Int #unsigned(B))) /Int abs(#unsigned(B))) ==K A) => A *Int B >=Int minSInt256
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool B <Int 0

// idk?
rule A modInt pow160 => A
  requires #rangeAddress(A)

syntax Bool ::= #rangeNotPrecompileAddress ( Int ) [function]
// ---------------------------------------
rule #rangeNotPrecompileAddress ( X ) =>
     #rangeAddress ( X )
     andBool 9 <=Int X
     andBool X =/=Int ACCT_ID
