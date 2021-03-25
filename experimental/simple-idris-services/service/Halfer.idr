-- Define module to wrap constants starting with lower case to not
-- confuse them with implicitly bound argument.  See
-- https://docs.idris-lang.org/en/latest/faq/faq.html#why-can-t-i-use-a-function-with-no-arguments-in-a-type
module Halfer

import public RealizedFunction

%default total

-- Realized halfer
public export
halfer : Int -> Int
halfer = (flip div 2)

public export
halfer_attrs : RealizedAttributes
halfer_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.8

public export
rlz_halfer : RealizedFunction (Int -> Int) Halfer.halfer_attrs
rlz_halfer = MkRealizedFunction halfer halfer_attrs
