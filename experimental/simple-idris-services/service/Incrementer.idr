module Incrementer

import public RealizedFunction

%default total

-- Realized incrementer
public export
incrementer : Int -> Int
incrementer = (+1)

public export
incrementer_attrs : RealizedAttributes
incrementer_attrs = MkRealizedAttributes (MkCosts 100 10 1) 1

public export
rlz_incrementer : RealizedFunction (Int -> Int) Incrementer.incrementer_attrs
rlz_incrementer = MkRealizedFunction incrementer incrementer_attrs
