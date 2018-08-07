// DSL for abstracted storage:

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
rule #ilks(Ilk, "rate") => #hashedLocation("Solidity", 3, Ilk) +Int 0

rule #ilks(Ilk, "Art") => #hashedLocation("Solidity", 3, Ilk) +Int 1


syntax Int ::= #urns( Int , Int , String ) [function]
// -----------------------------------------------------
rule #urns(Ilk, Guy, "gem") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 0

rule #urns(Ilk, Guy, "ink") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 1

rule #urns(Ilk, Guy, "art") => #hashedLocation("Solidity", 4, Ilk Guy) +Int 2


syntax Int ::= "#Tab" [function]
// --------------------------------
rule #Tab => 5


syntax Int ::= "#vice" [function]
// ---------------------------------
rule #vice => 6



   syntax Int ::= "#vat" [function]
// ------------------------------
   rule #vat => 0


   syntax Int ::= "#Line" [function]
// -------------------------------
   rule #Line => 1


   syntax Int ::= "#live" [function]
// -------------------------------
   rule #live => 2


   syntax Int ::= #ilks ( Int , String ) [function]
// ------------------------------------------------
   rule #ilks(Ilk, "spot") => #hashedLocation("Solidity", 3, Ilk) +Int 0

   rule #ilks(Ilk, "line") => #hashedLocation("Solidity", 3, Ilk) +Int 1


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


