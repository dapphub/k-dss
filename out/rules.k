requires "domains.k"
requires "edsl.k"
requires "evm.k"

module RULES
    imports BYTES-SYMBOLIC
    imports EVM
    imports EDSL

// VERIFICATION.k

    syntax Int ::= nthbyteof ( Int , Int , Int ) [function, smtlib(smt_nthbyteof)]
 // ------------------------------------------------------------------------------
    rule nthbyteof(V, I, N) => nthbyteof(V /Int 256, I, N -Int 1) when N  >Int (I +Int 1) [concrete]
    rule nthbyteof(V, I, N) =>           V modInt 256             when N ==Int (I +Int 1) [concrete]









    rule 0 <=Int nthbyteof(V, I, N)          => true
    rule         nthbyteof(V, I, N) <Int 256 => true

    rule #asWord( nthbyteof(V,  0, 32)
                : nthbyteof(V,  1, 32)
                : nthbyteof(V,  2, 32)
                : nthbyteof(V,  3, 32)
                : nthbyteof(V,  4, 32)
                : nthbyteof(V,  5, 32)
                : nthbyteof(V,  6, 32)
                : nthbyteof(V,  7, 32)
                : nthbyteof(V,  8, 32)
                : nthbyteof(V,  9, 32)
                : nthbyteof(V, 10, 32)
                : nthbyteof(V, 11, 32)
                : nthbyteof(V, 12, 32)
                : nthbyteof(V, 13, 32)
                : nthbyteof(V, 14, 32)
                : nthbyteof(V, 15, 32)
                : nthbyteof(V, 16, 32)
                : nthbyteof(V, 17, 32)
                : nthbyteof(V, 18, 32)
                : nthbyteof(V, 19, 32)
                : nthbyteof(V, 20, 32)
                : nthbyteof(V, 21, 32)
                : nthbyteof(V, 22, 32)
                : nthbyteof(V, 23, 32)
                : nthbyteof(V, 24, 32)
                : nthbyteof(V, 25, 32)
                : nthbyteof(V, 26, 32)
                : nthbyteof(V, 27, 32)
                : nthbyteof(V, 28, 32)
                : nthbyteof(V, 29, 32)
                : nthbyteof(V, 30, 32)
                : nthbyteof(V, 31, 32)
                : .WordStack ) => V
      requires 0 <=Int V andBool V <Int pow256


    rule #asWord( nthbyteof(#unsigned(V),  0, 32)
                : nthbyteof(#unsigned(V),  1, 32)
                : nthbyteof(#unsigned(V),  2, 32)
                : nthbyteof(#unsigned(V),  3, 32)
                : nthbyteof(#unsigned(V),  4, 32)
                : nthbyteof(#unsigned(V),  5, 32)
                : nthbyteof(#unsigned(V),  6, 32)
                : nthbyteof(#unsigned(V),  7, 32)
                : nthbyteof(#unsigned(V),  8, 32)
                : nthbyteof(#unsigned(V),  9, 32)
                : nthbyteof(#unsigned(V), 10, 32)
                : nthbyteof(#unsigned(V), 11, 32)
                : nthbyteof(#unsigned(V), 12, 32)
                : nthbyteof(#unsigned(V), 13, 32)
                : nthbyteof(#unsigned(V), 14, 32)
                : nthbyteof(#unsigned(V), 15, 32)
                : nthbyteof(#unsigned(V), 16, 32)
                : nthbyteof(#unsigned(V), 17, 32)
                : nthbyteof(#unsigned(V), 18, 32)
                : nthbyteof(#unsigned(V), 19, 32)
                : nthbyteof(#unsigned(V), 20, 32)
                : nthbyteof(#unsigned(V), 21, 32)
                : nthbyteof(#unsigned(V), 22, 32)
                : nthbyteof(#unsigned(V), 23, 32)
                : nthbyteof(#unsigned(V), 24, 32)
                : nthbyteof(#unsigned(V), 25, 32)
                : nthbyteof(#unsigned(V), 26, 32)
                : nthbyteof(#unsigned(V), 27, 32)
                : nthbyteof(#unsigned(V), 28, 32)
                : nthbyteof(#unsigned(V), 29, 32)
                : nthbyteof(#unsigned(V), 30, 32)
                : nthbyteof(#unsigned(V), 31, 32)
                : .WordStack ) => #unsigned(V)
      requires #rangeSInt(256, V)

    rule #asWord( nthbyteof(keccakIntList(V),  0, 32)
                : nthbyteof(keccakIntList(V),  1, 32)
                : nthbyteof(keccakIntList(V),  2, 32)
                : nthbyteof(keccakIntList(V),  3, 32)
                : nthbyteof(keccakIntList(V),  4, 32)
                : nthbyteof(keccakIntList(V),  5, 32)
                : nthbyteof(keccakIntList(V),  6, 32)
                : nthbyteof(keccakIntList(V),  7, 32)
                : nthbyteof(keccakIntList(V),  8, 32)
                : nthbyteof(keccakIntList(V),  9, 32)
                : nthbyteof(keccakIntList(V), 10, 32)
                : nthbyteof(keccakIntList(V), 11, 32)
                : nthbyteof(keccakIntList(V), 12, 32)
                : nthbyteof(keccakIntList(V), 13, 32)
                : nthbyteof(keccakIntList(V), 14, 32)
                : nthbyteof(keccakIntList(V), 15, 32)
                : nthbyteof(keccakIntList(V), 16, 32)
                : nthbyteof(keccakIntList(V), 17, 32)
                : nthbyteof(keccakIntList(V), 18, 32)
                : nthbyteof(keccakIntList(V), 19, 32)
                : nthbyteof(keccakIntList(V), 20, 32)
                : nthbyteof(keccakIntList(V), 21, 32)
                : nthbyteof(keccakIntList(V), 22, 32)
                : nthbyteof(keccakIntList(V), 23, 32)
                : nthbyteof(keccakIntList(V), 24, 32)
                : nthbyteof(keccakIntList(V), 25, 32)
                : nthbyteof(keccakIntList(V), 26, 32)
                : nthbyteof(keccakIntList(V), 27, 32)
                : nthbyteof(keccakIntList(V), 28, 32)
                : nthbyteof(keccakIntList(V), 29, 32)
                : nthbyteof(keccakIntList(V), 30, 32)
                : nthbyteof(keccakIntList(V), 31, 32)
                : .WordStack ) => keccakIntList(V)


rule ACCTCODE in SetItem( 1 )
                 SetItem ( 2 )
                 SetItem ( 3 )
                 SetItem ( 4 )
                 SetItem ( 5 )
                 SetItem ( 6 )
                 SetItem ( 7 )
                 SetItem ( 8 )
                 => false
     requires 9 <=Int ACCTCODE




    //Useful abstractions for storage related hashing
//    syntax Int ::= symkeccak ( IntList ) [function, smtlib(smt_symkeccak)]
   // -------------------------------------------------------
    rule keccak(WS) => keccakIntList(wordStack2IntList(WS)) requires notBool #isConcrete(WS)

    rule 0 <=Int keccakIntList(N)     => true
    rule keccaktIntList(N) <Int pow256 => true


    rule #padToWidth(32, #asByteStack( #unsigned(V) )) => #asByteStackInWidth( #unsigned(V), 32)
      requires #rangeSInt(256, V)


    rule #padToWidth(32, #asByteStack(V)) => #asByteStackInWidth(V, 32)
      requires 0 <=Int V andBool V <Int pow256


    rule #padToWidth(32, #asByteStack( keccakIntList (V) )) => #asByteStackInWidth( keccakIntList (V), 32)




   // for Vyper
    rule #padToWidth(N, #asByteStack(#asWord(WS))) => WS
      requires #noOverflow(WS) andBool N ==Int #sizeWordStack(WS)

    // for Solidity
    rule #asWord(WS) /Int D => #asWord(#take(#sizeWordStack(WS) -Int log256Int(D), WS))
      requires D modInt 256 ==Int 0 andBool D >=Int 0
       andBool #sizeWordStack(WS) >=Int log256Int(D)
       andBool #noOverflow(WS)

    syntax Bool ::= #noOverflow    ( WordStack ) [function]
                  | #noOverflowAux ( WordStack ) [function]
 // -------------------------------------------------------
    rule #noOverflow(WS) => #sizeWordStack(WS) <=Int 32 andBool #noOverflowAux(WS)

    rule #noOverflowAux(W : WS)     => 0 <=Int W andBool W <Int 256 andBool #noOverflowAux(WS)
    rule #noOverflowAux(.WordStack) => true

    syntax WordStack ::= #asByteStackInWidth    ( Int, Int )                 [function]
                       | #asByteStackInWidthaux ( Int, Int, Int, WordStack ) [function]
 // -----------------------------------------------------------------------------------
    rule #asByteStackInWidth(X, N) => #asByteStackInWidthaux(X, N -Int 1, N, .WordStack)

    rule #asByteStackInWidthaux(X, I, N, WS) => #asByteStackInWidthaux(X, I -Int 1, N, nthbyteof(X, I, N) : WS) when I >Int 0
    rule #asByteStackInWidthaux(X, 0, N, WS) => nthbyteof(X, 0, N) : WS










    rule 0 +Int N => N
    rule N +Int 0 => N

    rule N -Int 0 => N

    rule 1 *Int N => N
    rule N *Int 1 => N
    rule 0 *Int _ => 0
    rule _ *Int 0 => 0

    rule N /Int 1 => N

    rule 0 |Int N => N
    rule N |Int 0 => N
    rule N |Int N => N

    rule 0 &Int N => 0
    rule N &Int 0 => 0
    rule N &Int N => N







    rule (I1 +Int I2) +Int I3 => I1 +Int (I2 +Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
    rule (I1 +Int I2) -Int I3 => I1 +Int (I2 -Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
    rule (I1 -Int I2) +Int I3 => I1 -Int (I2 -Int I3) when #isConcrete(I2) andBool #isConcrete(I3)
    rule (I1 -Int I2) -Int I3 => I1 -Int (I2 +Int I3) when #isConcrete(I2) andBool #isConcrete(I3)

    rule I1 &Int (I2 &Int I3) => (I1 &Int I2) &Int I3 when #isConcrete(I1) andBool #isConcrete(I2)

    // 0xffff...f &Int N = N
    rule MASK &Int N => N  requires MASK ==Int (2 ^Int (log2Int(MASK) +Int 1)) -Int 1 // MASK = 0xffff...f
                            andBool 0 <=Int N andBool N <=Int MASK

    // for gas calculation
    rule A -Int (#if C #then B1 #else B2 #fi) => #if C #then (A -Int B1) #else (A -Int B2) #fi
    rule (#if C #then B1 #else B2 #fi) -Int A => #if C #then (B1 -Int A) #else (B2 -Int A) #fi








    rule bool2Word(A) |Int bool2Word(B) => bool2Word(A  orBool B)
    rule bool2Word(A) &Int bool2Word(B) => bool2Word(A andBool B)

    rule bool2Word(A)  ==K 0 => notBool(A)
    rule bool2Word(A)  ==K 1 => A
    rule bool2Word(A) =/=K 0 => A
    rule bool2Word(A) =/=K 1 => notBool(A)

    rule chop(bool2Word(B)) => bool2Word(B)





    rule 0 <=Int chop(V)             => true
    rule         chop(V) <Int pow256 => true

    rule 0 <=Int keccak(V)             => true
    rule         keccak(V) <Int pow256 => true

    rule 0 <=Int X &Int Y             => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256
    rule         X &Int Y <Int pow256 => true requires 0 <=Int X andBool X <Int pow256 andBool 0 <=Int Y andBool Y <Int pow256





    rule chop(I) => I requires 0 <=Int I andBool I <Int pow256







    rule #sizeWordStack ( _ , _ ) >=Int 0 => true [smt-lemma]
    rule #sizeWordStack ( WS , N:Int )
      => #sizeWordStack ( WS , 0 ) +Int N
      requires N =/=K 0
      [lemma]

rule chop(#unsigned(W)) => #unsigned(W)
  requires #rangeSInt(256, W)

rule #signed(#unsigned(W)) => W
  requires #rangeSInt(256, W)

rule #unsigned(#signed(W)) => W
  requires #rangeUInt(256, W)

rule W0 s<Word W1 => #signed(W0) <Word #signed(W1)

rule A modInt pow160 => A
  requires #rangeAddress(A)

syntax Bool ::= #notPrecompileAddress ( Int ) [function]
// ---------------------------------------
rule #notPrecompileAddress ( X ) => 9 <=Int X

// ABSTRACT SEMANTICS.k

  rule <k> LT W0 W1 => bool2Word(W0  <Int W1) ~> #push ... </k> [trusted]
  rule <k> GT W0 W1 => bool2Word(W0  >Int W1) ~> #push ... </k> [trusted]
  rule <k> EQ W0 W1 => bool2Word(W0 ==Int W1) ~> #push ... </k> [trusted]
  rule <k> ISZERO W => bool2Word(W  ==Int 0 ) ~> #push ... </k> [trusted]



// ./src/storage.k.md

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
syntax Int ::= "#Vat.wards" "[" Int "]" [function]
// -----------------------------------------------
// doc: authorisation to call
// act: address `$0` is `. == 1 ? authorised : unauthorised`
rule #Vat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vat.ilks" "[" Int "].take" [function]
// ----------------------------------------------------
// doc: collateral unit rate of ilk `$0`
// act: ilk `$0` has collateral unit rate `.`
rule #Vat.ilks[Ilk].take => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Vat.ilks" "[" Int "].rate" [function]
// ----------------------------------------------------
// doc: debt unit rate of ilk `$0`
// act: ilk `$0` has debt unit rate `.`
rule #Vat.ilks[Ilk].rate => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Vat.ilks" "[" Int "].Ink" [function]
// -----------------------------------------------
// doc: the total encumbered collateral for the ilk `$0`
// act: ilk `$0` has encumbered collateral `.`
rule #Vat.ilks[Ilk].Ink => #hashedLocation("Solidity", 1, Ilk) +Int 2

syntax Int ::= "#Vat.ilks" "[" Int "].Art" [function]
// -----------------------------------------------
// doc: the total debt issued from the ilk `$0`
// act: ilk `$0` has debt issuance `.`
rule #Vat.ilks[Ilk].Art => #hashedLocation("Solidity", 1, Ilk) +Int 3

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].ink" [function]
// ----------------------------------------------------------
// doc: the amount of encumbered collateral units assigned to `$1`
// act: agent `$1` has `.` collateral units in ilk `$0`
rule #Vat.urns[Ilk][Guy].ink => #hashedLocation("Solidity", 2, Ilk Guy)

syntax Int ::= "#Vat.urns" "[" Int "][" Int "].art" [function]
// ----------------------------------------------------------
// doc: the amount of debt units assigned to `$1`
// act: agent `$1` has `.` debt units in ilk `$0`
rule #Vat.urns[Ilk][Guy].art => #hashedLocation("Solidity", 2, Ilk Guy) +Int 1

syntax Int ::= "#Vat.gem" "[" Int "][" Int "]" [function]
// ---------------------------------------------
// doc: the amount of unencumbered collateral assigned to `$1`
// act: agent `$1` has `.` unencumbered collateral in ilk `$0`
rule #Vat.gem[Ilk][Guy] => #hashedLocation("Solidity", 3, Ilk Guy)

syntax Int ::= "#Vat.dai" "[" Int "]" [function]
// ---------------------------------------------
// doc: the amount of dai assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.dai[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Vat.sin" "[" Int "]" [function]
// ---------------------------------------------
// doc: the amount of system debt assigned to `$0`
// act: agent `$0` has `.` dai
rule #Vat.sin[A] => #hashedLocation("Solidity", 5, A)

syntax Int ::= "#Vat.debt" [function]
// ---------------------------------
// doc: the total debt issued from the system
// act: system has `.` total debt
rule #Vat.debt => 6

syntax Int ::= "#Vat.vice" [function]
// ----------------------------------
// doc: the total system debt
// act: there is `.` system debt
rule #Vat.vice => 7
syntax Int ::= "#Drip.wards" "[" Int "]" [function]
// -----------------------------------------------
rule #Drip.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Drip.ilks" "[" Int "].tax" [function]
// ----------------------------------------------------
rule #Drip.ilks[Ilk].tax => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Drip.ilks" "[" Int "].rho" [function]
// ----------------------------------------------------
rule #Drip.ilks[Ilk].rho => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Drip.vat" [function]
// ----------------------------------
rule #Drip.vat => 2

syntax Int ::= "#Drip.vow" [function]
// ----------------------------------
rule #Drip.vow => 3

syntax Int ::= "#Drip.repo" [function]
// -----------------------------------
rule #Drip.repo => 4
syntax Int ::= "#Pit.wards" "[" Int "]" [function]
// ---------------------------------
rule #Pit.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Pit.ilks" "[" Int "].spot" [function]
// ---------------------------------------------------
rule #Pit.ilks[Ilk].spot => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Pit.ilks" "[" Int "].line" [function]
// ---------------------------------------------------
rule #Pit.ilks[Ilk].line => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Pit.live" [function]
// ----------------------------------
rule #Pit.live => 2

syntax Int ::= "#Pit.Line" [function]
// ----------------------------------
rule #Pit.Line => 3

syntax Int ::= "#Pit.vat" [function]
// ---------------------------------
rule #Pit.vat => 4

syntax Int ::= "#Pit.drip" [function]
// ----------------------------------
rule #Pit.drip => 5
syntax Int ::= "#Vow.wards" "[" Int "]" [function]
// ---------------------------------
rule #Vow.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Vow.vat" [function]
// ---------------------------------
rule #Vow.vat => 1

syntax Int ::= "#Vow.cow" [function]
// ---------------------------------
rule #Vow.cow => 2

syntax Int ::= "#Vow.row" [function]
// ---------------------------------
rule #Vow.row => 3

syntax Int ::= "#Vow.sin" "[" Int "]" [function]
// ---------------------------------------------
rule #Vow.sin[A] => #hashedLocation("Solidity", 4, A)

syntax Int ::= "#Vow.Sin" [function]
// ---------------------------------
rule #Vow.Sin => 5

syntax Int ::= "#Vow.Woe" [function]
// ---------------------------------
rule #Vow.Woe => 6

syntax Int ::= "#Vow.Ash" [function]
// ---------------------------------
rule #Vow.Ash => 7

syntax Int ::= "#Vow.wait" [function]
// ----------------------------------
rule #Vow.wait => 8

syntax Int ::= "#Vow.sump" [function]
// ----------------------------------
rule #Vow.sump => 9

syntax Int ::= "#Vow.bump" [function]
// ----------------------------------
rule #Vow.bump => 10

syntax Int ::= "#Vow.hump" [function]
// ---------------------------------
rule #Vow.hump => 11
syntax Int ::= "#Cat.wards" "[" Int "]" [function]
// ---------------------------------
rule #Cat.wards[A] => #hashedLocation("Solidity", 0, A)

syntax Int ::= "#Cat.ilks" "[" Int "].flip" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].flip => #hashedLocation("Solidity", 1, Ilk) +Int 0

syntax Int ::= "#Cat.ilks" "[" Int "].chop" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].chop => #hashedLocation("Solidity", 1, Ilk) +Int 1

syntax Int ::= "#Cat.ilks" "[" Int "].lump" [function]
// ---------------------------------------------------
rule #Cat.ilks[Ilk].lump => #hashedLocation("Solidity", 1, Ilk) +Int 2

syntax Int ::= "#Cat.flips" "[" Int "].ilk" [function]
// ---------------------------------------------------
rule #Cat.flips[N].ilk => #hashedLocation("Solidity", 2, N) +Int 0

syntax Int ::= "#Cat.flips" "[" Int "].urn" [function]
// ---------------------------------------------------
rule #Cat.flips[N].urn => #hashedLocation("Solidity", 2, N) +Int 1

syntax Int ::= "#Cat.flips" "[" Int "].ink" [function]
// ---------------------------------------------------
rule #Cat.flips[N].ink => #hashedLocation("Solidity", 2, N) +Int 2

syntax Int ::= "#Cat.flips" "[" Int "].tab" [function]
// ---------------------------------------------------
rule #Cat.flips[N].tab => #hashedLocation("Solidity", 2, N) +Int 3

syntax Int ::= "#Cat.nflip" [function]
// -----------------------------------
rule #Cat.nflip => 3

syntax Int ::= "#Cat.live" [function]
// ----------------------------------
rule #Cat.live => 4

syntax Int ::= "#Cat.vat" [function]
// ---------------------------------
rule #Cat.vat => 5

syntax Int ::= "#Cat.pit" [function]
// ---------------------------------
rule #Cat.pit => 6

syntax Int ::= "#Cat.vow" [function]
// ---------------------------------
rule #Cat.vow => 7
syntax Int ::= "#GemJoin.vat" [function]
// -------------------------------------
rule #GemJoin.vat => 0

syntax Int ::= "#GemJoin.ilk" [function]
// -------------------------------------
rule #GemJoin.ilk => 1

syntax Int ::= "#GemJoin.gem" [function]
// -------------------------------------
rule #GemJoin.gem => 2
syntax Int ::= "#ETHJoin.vat" [function]
// -------------------------------------
rule #ETHJoin.vat => 0

syntax Int ::= "#ETHJoin.ilk" [function]
// -------------------------------------
rule #ETHJoin.ilk => 1
syntax Int ::= "#DaiJoin.vat" [function]
// -------------------------------------
rule #DaiJoin.vat => 0

syntax Int ::= "#DaiJoin.dai" [function]
// -------------------------------------
rule #DaiJoin.dai => 1
// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.ttl_tau" [function]
// -----------------------------------------
rule #Flipper.ttl_tau => 3

syntax Int ::= "#Flipper.kicks" [function]
// ---------------------------------------
rule #Flipper.kicks => 4

syntax Int ::= "#Flipper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flipper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flipper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flipper.bids[N].guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flipper.bids" "[" Int "].urn" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].urn => #hashedLocation("Solidity", 5, N) +Int 3

syntax Int ::= "#Flipper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].gal => #hashedLocation("Solidity", 5, N) +Int 4

syntax Int ::= "#Flipper.bids" "[" Int "].tab" [function]
// ------------------------------------------------------
rule #Flipper.bids[N].tab => #hashedLocation("Solidity", 5, N) +Int 5
// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.ttl_tau" [function]
// -----------------------------------------
rule #Flapper.ttl_tau => 3

syntax Int ::= "#Flapper.kicks" [function]
// ---------------------------------------
rule #Flapper.kicks => 4

syntax Int ::= "#Flapper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
rule #Flapper.bids[N].bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flapper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
rule #Flapper.bids[N].lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flapper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flapper.bids[N].guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flapper.bids" "[" Int "].gal" [function]
// ------------------------------------------------------
rule #Flapper.bids[N].gal => #hashedLocation("Solidity", 5, N) +Int 3
syntax Int ::= "#Flopper.wards" "[" Int "]" [function]
// ---------------------------------------
rule #Flopper.wards[A] => #hashedLocation("Solidity", 0, A)

// packed, use #WordPackUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.ttl_tau" [function]
// -----------------------------------------
rule #Flopper.ttl_tau => 3

syntax Int ::= "#Flopper.kicks" [function]
// ---------------------------------------
rule #Flopper.kicks => 4

syntax Int ::= "#Flopper.bids" "[" Int "].bid" [function]
// ------------------------------------------------------
rule #Flopper.bids[N].bid => #hashedLocation("Solidity", 5, N) +Int 0

syntax Int ::= "#Flopper.bids" "[" Int "].lot" [function]
// ------------------------------------------------------
rule #Flopper.bids[N].lot => #hashedLocation("Solidity", 5, N) +Int 1

// packed, use #WordPackAddrUInt48UInt48 to unpack this
syntax Int ::= "#Flopper.bids" "[" Int "].guy_tic_end" [function]
// --------------------------------------------------------------
rule #Flopper.bids[N].guy_tic_end => #hashedLocation("Solidity", 5, N) +Int 2

syntax Int ::= "#Flopper.bids" "[" Int "].vow" [function]
// ------------------------------------------------------
rule #Flopper.bids[N].vow => #hashedLocation("Solidity", 5, N) +Int 3
syntax Int ::= "#GemLike.balances" "[" Int "]" [function]
// --------------------------------------------------
rule #GemLike.balances[A] => #hashedLocation("Solidity", 1, A)
// ./src/lemmas.k.md

syntax Int ::= "#rightPadInt" "(" Int "," Int ")" [function]
// ---------------------------------------------------------
rule #rightPadInt(N, X) => X
  requires 256 *Int X >=Int (2 ^Int (8 *Int N))
rule #rightPadInt(N, X) => #rightPadInt(N, 256 *Int X)
  requires 256 *Int X <Int (2 ^Int (8 *Int N))

syntax Int ::= "#string2Word" "(" String ")" [function]
// ----------------------------------------------------
rule #string2Word(S) => #rightPadInt(32, Bytes2Int(String2Bytes(S), bigEndianBytes(.KList), unsignedBytes(.KList)))
syntax Int ::= "#Wad" [function]
// -----------------------------
rule #Wad => 1000000000000000000

syntax Int ::= "#Ray" [function]
// -----------------------------
rule #Ray => 1000000000000000000000000000
syntax Int ::= "#rmul" "(" Int "," Int ")" [function]

syntax Int ::= "#rpow" "(" Int "," Int "," Int "," Int ")"  [function, smtlib(smt_rpow)]
// hashed storage offsets never overflow (probabilistic assumption):
rule chop(keccakIntList(L) +Int N) => keccakIntList(L) +Int N
  requires N <=Int 100

// solidity also needs:
rule chop(keccakIntList(L)) => keccakIntList(L)
// and
rule chop(N +Int keccakIntList(L)) => keccakIntList(L) +Int N
  requires N <=Int 100
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
rule #unsigned(X) ==K 0 => X ==Int 0

rule 0 <Int #unsigned(X) => 0 <Int X

// uadd
// lemmas for necessity
rule chop(A +Int B) >Int A => (A +Int B <=Int maxUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// usub
// lemmas for necessity
rule A -Word B <Int A => (A -Int B >=Int minUInt256)
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

// addui
// lemmas for sufficiency
rule chop(A +Int #unsigned(B)) => A +Int B
  requires #rangeUInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeUInt(256, A +Int B)

// lemmas for necessity
// rule chop(A +Int #unsigned(B)) >Int A => (A +Int B <=Int maxUInt256)
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B >=Int 0

rule (A +Int #unsigned(B) <=Int maxUInt256) => (A +Int B <=Int maxUInt256)
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
// rule A -Word #unsigned(B) <Int A => (A -Int B >=Int minUInt256)
//   requires #rangeUInt(256, A)
//   andBool #rangeSInt(256, B)
//   andBool B >=Int 0

rule (A -Int #unsigned(B) >=Int minUInt256) => (A -Int B >=Int minUInt256)
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

rule (chop(A *Int B) /Int B ==K A) => A *Int B <=Int maxUInt256
  requires #rangeUInt(256, A)
  andBool #rangeUInt(256, B)

endmodule
