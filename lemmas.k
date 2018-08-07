// DSL for abstracted storage:

syntax Int ::= "#Vat_root" [function]
// ---------------------------------
rule #Vat_root => 0


syntax Int ::= #Vat_dai( Int ) [function]
// -------------------------------------
rule #Vat_dai(A) => #hashedLocation("Solidity", 1, A)


syntax Int ::= #Vat_sin( Int ) [function]
// -------------------------------------
rule #Vat_sin(A) => #hashedLocation("Solidity", 2, A)


syntax Int ::= #Vat_ilks( Int , String ) [function]
// -----------------------------------------------
rule #Vat_ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Vat_ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= #Vat_urns( Int , Int , String ) [function]
// -----------------------------------------------------
rule #Vat_urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

rule #Vat_urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

rule #Vat_urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


syntax Int ::= "#Vat_Tab" [function]
// --------------------------------
rule #Vat_Tab => 5


syntax Int ::= "#Vat_vice" [function]
// ---------------------------------
rule #Vat_vice => 6


syntax Int ::= #Lad_vat [function]
// ------------------------------
rule #Lad_vat => 0


syntax Int ::= #Lad_Line [function]
// -------------------------------
rule #Lad_Line => 1


syntax Int ::= #Lad_live [function]
// -------------------------------
rule #Lad_live => 2


syntax Int ::= #Lad_ilks ( Int , String ) [function]
// ------------------------------------------------
rule #Lad_ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #Lad_ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= #Adapter_vat [function]
// -------------------------------------
rule #Adapter_vat => 0


syntax Int ::= #Adapter_ilk [function]
// -------------------------------------
rule #Adapter_ilk => 1


syntax Int ::= #Adapter_gem [function]
// -------------------------------------
rule #Adapter_gem => 2


// misc:
syntax Int ::= #wad2rad ( Int ) [function]
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


