// DSL for abstracted storage:

syntax Int ::= "#Vat.root" [function]
// ---------------------------------
rule #Vat.root => 0


syntax Int ::= "#Vat.dai" "(" Int ")" [function]
// -------------------------------------
rule #Vat.dai(A) => #hashedLocation("Solidity", 1, A)


syntax Int ::= "#Vat.sin" "(" Int ")" [function]
// -------------------------------------
rule #Vat.sin(A) => #hashedLocation("Solidity", 2, A)


syntax Int ::= "#Vat.ilks" "(" Int "," String ")" [function]
// -----------------------------------------------
rule #Vat.ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Vat.ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= "#Vat.urns" "(" Int "," Int "," String ")" [function]
// -----------------------------------------------------
rule #Vat.urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

rule #Vat.urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

rule #Vat.urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


syntax Int ::= "#Vat.Tab" [function]
// --------------------------------
rule #Vat.Tab => 5


syntax Int ::= "#Vat.vice" [function]
// ---------------------------------
rule #Vat.vice => 6


syntax Int ::= "#Lad.vat" [function]
// ------------------------------
rule #Lad.vat => 0


syntax Int ::= "#Lad.Line" [function]
// -------------------------------
rule #Lad.Line => 1


syntax Int ::= "#Lad.live" [function]
// -------------------------------
rule #Lad.live => 2


syntax Int ::= "#Lad.ilks" "(" Int "," String ")" [function]
// ------------------------------------------------
rule #Lad.ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Lad.ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= "#Adapter.vat" [function]
// -------------------------------------
rule #Adapter.vat => 0


syntax Int ::= "#Adapter.ilk" [function]
// -------------------------------------
rule #Adapter.ilk => 1


syntax Int ::= "#Adapter.gem" [function]
// -------------------------------------
rule #Adapter.gem => 2


// misc:

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
// and the N, M versions of below

rule #take(N, #padToWidth(N, WS) ) => #padToWidth(N, WS)

// n.b. how + cases use +Int because of earlier application of +Word
rule (#unsigned(A) +Int #unsigned(B)) => #unsigned(A +Int B)
  requires #rangeSInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A +Int B)

rule chop(#unsigned(W)) => #unsigned(W)
  requires #rangeSInt(256, W)

rule #signed(#unsigned(W)) => W
  requires #rangeSInt(256, W)

rule #unsigned(#signed(W)) => W
  requires #rangeUInt(256, W)

rule W0 s<Word W1 => #signed(W0) <Word #signed(W1)

// converse:
rule (#signed (chop (#unsigned(A) +Int #unsigned(B)))) => A +Int B -Int pow256
  requires notBool (#rangeSInt(256, A +Int B))
  andBool B >=Int 0
  andBool #rangeSInt(256, A)
  andBool #rangeSInt(256, B)

rule (#signed (chop (#unsigned(A) +Int #unsigned(B)))) => A +Int B +Int pow256
  requires notBool (#rangeSInt(256, A +Int B))
  andBool B <=Int 0
  andBool #rangeSInt(256, A)
  andBool #rangeSInt(256, B)

rule A modInt pow160 => A
  requires #rangeAddress(A)
