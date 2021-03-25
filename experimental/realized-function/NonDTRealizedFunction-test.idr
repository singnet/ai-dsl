module Main

import NonDTRealizedFunction

-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)
incrementer_attrs : NonDTRealizedAttributes
incrementer_attrs = MkNonDTRealizedAttributes (MkCosts 1 1 1) 1
rlz_incrementer : NonDTRealizedFunction (Int -> Int)
rlz_incrementer = MkNonDTRealizedFunction incrementer incrementer_attrs

-- Realized twicer
twicer : Int -> Int
twicer = (*2)
twicer_attrs : NonDTRealizedAttributes
twicer_attrs = MkNonDTRealizedAttributes (MkCosts 2 2 2) 0.9
rlz_twicer : NonDTRealizedFunction (Int -> Int)
rlz_twicer = MkNonDTRealizedFunction twicer twicer_attrs

-- Realized (twicer . incrementer)
rlz_composition : NonDTRealizedFunction (Int -> Int)
rlz_composition = compose rlz_twicer rlz_incrementer

-- Simple test, result should be (3+1)*2 = 8
rslt : Int
rslt = apply rlz_composition 3
