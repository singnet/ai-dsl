module Incrementer

import RealizedFunction

%default total

-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)
incrementer_attrs : RealizedAttributes
incrementer_attrs = MkRealizedAttributes (MkCosts 100 10 1) 1
rlz_incrementer : RealizedFunction (Int -> Int) Incrementer.incrementer_attrs
rlz_incrementer = MkRealizedFunction incrementer incrementer_attrs
