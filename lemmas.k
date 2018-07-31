rule #take(N, #padToWidth(N, WS) ++ WS' ) => #padToWidth(N, WS)

// shifting trick in the beginning of ABI thing:
// dividing by 16^56 == 2^224 is the same as shifting to last 4 bytes
rule #asWord(W : X : Y : Z : WS) /Int 26959946667150639794667015087019630673637144422540572481103610249216 => #asWord(W : X : Y : Z : .WordStack)

rule #asWord(#padToWidth(32, #asByteStack(#unsigned(X)))) => #unsigned(X)
  requires #rangeSInt(256, X)

rule #asWord( #asByteStack( X ) ) => X

rule #hashedLocation("DappHub", BASE, OFFSET OFFSETS) => #hashedLocation("DappHub", keccakIntList(BASE OFFSET),       OFFSETS)

// propositional rules
rule notBool (P orBool Q) => (notBool P) andBool (notBool Q)
rule notBool (P andBool Q) => (notBool P) orBool (notBool Q)
rule notBool (notBool P) => P

// lemmas to tell us that our non-overflow conditions are sufficient
rule (#unsigned(A) -Word #unsigned(B)) => #unsigned(A -Int B)
  requires #rangeSInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A -Int B)

// n.b. how + cases use +Int because of earlier application of +Word 
rule (#unsigned(A) +Int #unsigned(B)) => #unsigned(A +Int B)
  requires #rangeSInt(256, A)
  andBool #rangeSInt(256, B)
  andBool #rangeSInt(256, A +Int B)

rule #signed(#unsigned(W)) => W
  requires #rangeSInt(256, W)

rule #unsigned(#signed(W)) => W
  requires #rangeUInt(256, W)

rule W0 s<Word W1 => #signed(W0) <Word #signed(W1)

// lemmas to tell us that our non-overflow conditions are necessary for
// the overflow checks in iadd and isub

// these just encode implications
// (¬A or B) is (A -> B) 
rule (notBool (0 <Int B))
    orBool
     (#signed (#unsigned(A) -Word #unsigned(B)) <Int A)
    => (A -Int B >=Int minSInt256)	      
  requires #rangeSInt(256, A)
  andBool  #rangeSInt(256, B)

rule (notBool (B <Int 0))
    orBool
     (A <Int #signed (#unsigned(A) -Word #unsigned(B)))
    => (A -Int B <=Int maxSInt256)	      
  requires #rangeSInt(256, A)
  andBool  #rangeSInt(256, B)

// n.b. how + cases use chop and +Int because of earlier application of +Word 
rule (notBool (0 <Int B))
    orBool
     (A <Int #signed (chop (#unsigned (A) +Int #unsigned (B))))
    => (A +Int B <=Int maxSInt256)
  requires #rangeSInt(256, A)
  andBool  #rangeSInt(256, B)

rule (notBool (B <Int 0))
    orBool
     (#signed (chop (#unsigned (A) +Int #unsigned (B))) <Int A)
    => (A +Int B >=Int minSInt256)
  requires #rangeSInt(256, A)
  andBool  #rangeSInt(256, B)
 

