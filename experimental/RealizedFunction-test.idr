module Main

import RealizedFunction

-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)
incrementer_attrs : RealizedAttributes
incrementer_attrs = MkRealizedAttributes (MkCosts 1 1 1) 1
rlz_incrementer : RealizedFunction (Int -> Int)
rlz_incrementer = MkRealizedFunction incrementer incrementer_attrs

-- Realized twicer
twicer : Int -> Int
twicer = (*2)
twicer_attrs : RealizedAttributes
twicer_attrs = MkRealizedAttributes (MkCosts 2 2 2) 0.9
rlz_twicer : RealizedFunction (Int -> Int)
rlz_twicer = MkRealizedFunction twicer twicer_attrs

-- Realized (twicer . incrementer)
rlz_composition : RealizedFunction (Int -> Int)
rlz_composition = compose rlz_twicer rlz_incrementer

-- Simple test, result should be (3+1)*2 = 8
rslt : Int
rslt = apply rlz_composition 3
