module Main

import SimpleRealizedFunction

-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)
rlz_incrementer : SimpleRealizedFunction (Int -> Int) 100 1.0
rlz_incrementer = MkSimpleRealizedFunction incrementer

-- Realized twicer
twicer : Int -> Int
twicer = (*2)
rlz_twicer : SimpleRealizedFunction (Int -> Int) 500 0.9
rlz_twicer = MkSimpleRealizedFunction twicer

-- Realized (twicer . incrementer).
rlz_composition : SimpleRealizedFunction (Int -> Int) 600 0.9
-- The following does not work because 601 ≠ 100+500 and 1.0 ≠ (min 1.0 0.9)
-- rlz_composition : SimpleRealizedFunction (Int -> Int) 601 1.0
rlz_composition = compose rlz_twicer rlz_incrementer

-- Simple test, result should be (3+1)*2 = 8
rslt : Int
rslt = apply rlz_composition 3
