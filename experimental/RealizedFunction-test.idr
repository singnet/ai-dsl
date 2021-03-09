-- Define module to wrap constants starting with lower case to not
-- confuse them with implicitly bound argument.  See
-- https://docs.idris-lang.org/en/latest/faq/faq.html#why-can-t-i-use-a-function-with-no-arguments-in-a-type
module Main

import RealizedFunction

%default total

-- Realized incrementer
incrementer : Int -> Int
incrementer = (+1)
incrementer_attrs : RealizedAttributes
incrementer_attrs = MkRealizedAttributes (MkCosts 100 10 1) 1
rlz_incrementer : RealizedFunction (Int -> Int) Main.incrementer_attrs
rlz_incrementer = MkRealizedFunction incrementer incrementer_attrs

-- Realized twicer
twicer : Int -> Int
twicer = (*2)
twicer_attrs : RealizedAttributes
twicer_attrs = MkRealizedAttributes (MkCosts 200 20 2) 0.9
rlz_twicer : RealizedFunction (Int -> Int) Main.twicer_attrs
rlz_twicer = MkRealizedFunction twicer twicer_attrs

-- Realized (twicer . incrementer).
rlz_composition_attrs : RealizedAttributes
rlz_composition_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.9
-- The following does not work because 301 ≠ 200+100
-- rlz_composition_attrs = MkRealizedAttributes (MkCosts 301 30 3) 0.9
rlz_composition : RealizedFunction (Int -> Int) Main.rlz_composition_attrs
rlz_composition = compose rlz_twicer rlz_incrementer

-- Simple test, result should be (3+1)*2 = 8
lifted_composition : Int -> Int
lifted_composition = apply rlz_composition

test : (lifted_composition 3) = 8
test = Refl
