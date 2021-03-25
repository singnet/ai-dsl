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

-- Realized halfer
halfer : Int -> Int
halfer = (flip div 2)
halfer_attrs : RealizedAttributes
halfer_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.8
rlz_halfer : RealizedFunction (Int -> Int) Main.halfer_attrs
rlz_halfer = MkRealizedFunction halfer halfer_attrs

-- Realized (twicer . incrementer).
rlz_compo1_attrs : RealizedAttributes
rlz_compo1_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.9
-- The following does not work because 301 ≠ 200+100
-- rlz_compo1_attrs = MkRealizedAttributes (MkCosts 301 30 3) 0.9
rlz_compo1 : RealizedFunction (Int -> Int) Main.rlz_compo1_attrs
rlz_compo1 = compose rlz_twicer rlz_incrementer

-- Realized (incrementer . twicer . halfer).
rlz_compo2_attrs : RealizedAttributes
rlz_compo2_attrs = MkRealizedAttributes (MkCosts 600 60 6) 0.8
-- The following does not work because 601 ≠ 300+200+100
-- rlz_compo2_attrs = MkRealizedAttributes (MkCosts 601 60 6) 0.8
rlz_compo2 : RealizedFunction (Int -> Int) Main.rlz_compo2_attrs
rlz_compo2 = (compose rlz_incrementer (compose rlz_twicer rlz_halfer))

-- Realized (halfer . incrementer . twicer).  If halfer can only take
-- an even integer, then such composition is not valid.
rlz_compo3_attrs : RealizedAttributes
rlz_compo3_attrs = MkRealizedAttributes (MkCosts 600 60 6) 0.8
rlz_compo3 : RealizedFunction (Int -> Int) Main.rlz_compo3_attrs
rlz_compo3 = (compose rlz_halfer (compose rlz_incrementer rlz_twicer))

-- Tests

-- Result should be (20+1)*2 = 42
lifted_compo1 : Int -> Int
lifted_compo1 = apply rlz_compo1
test1 : lifted_compo1 20 = 42
test1 = Refl

-- Result should be 1+2*(40/2) = 41
lifted_compo2 : Int -> Int
lifted_compo2 = apply rlz_compo2
test2 : lifted_compo2 40 = 41
test2 = Refl

-- Result should be (40*2+1)/2 = 40 [assuming no even integer
-- constraint on halfer's input].
lifted_compo3 : Int -> Int
lifted_compo3 = apply rlz_compo3
test2 : lifted_compo3 40 = 40
test2 = Refl
