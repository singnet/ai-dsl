-- Define module to wrap constants starting with lower case to not
-- confuse them with implicitly bound argument.  See
-- https://docs.idris-lang.org/en/latest/faq/faq.html#why-can-t-i-use-a-function-with-no-arguments-in-a-type
module Halfer

import RealizedFunction

%default total

-- Realized halfer
halfer : Int -> Int
halfer = (flip div 2)
halfer_attrs : RealizedAttributes
halfer_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.8
rlz_halfer : RealizedFunction (Int -> Int) Main.halfer_attrs
rlz_halfer = MkRealizedFunction halfer halfer_attrs
