import SimpleDataRealizedFunction
%default total

-- module Main



-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)


rlz_incrementer : SimpleDataRealizedFunction (Int -> Int)  100 1.0
rlz_incrementer = MkSimpleDataRealizedFunction incrementer 100 1.0

-- Realized twicer
twicer : Int -> Int
twicer = (*2)


rlz_twicer : SimpleDataRealizedFunction (Int -> Int)  500 0.9
rlz_twicer = MkSimpleDataRealizedFunction twicer 500 0.9

-- Realized (twicer . incrementer).
rlz_composition : SimpleDataRealizedFunction (Int -> Int)  600 0.9
-- The following does not work because 601 ≠ 100+500 and 1.0 ≠ (min 1.0 0.9)
-- rlz_composition : SimpleDataRealizedFunction (Int -> Int) 601 1.0
rlz_composition = compose rlz_twicer rlz_incrementer

-- Simple test, result should be (3+1)*2 = 8
lifted_composition : Int -> Int
lifted_composition = apply rlz_composition

test : (lifted_composition 3) = 8
test = Refl
