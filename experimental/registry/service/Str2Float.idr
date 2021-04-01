module Str2Float

import RealizedFunction

%default total

-- Realized str2float
public export
str2float : String -> Double
str2float = cast

public export
str2float_attrs : RealizedAttributes
str2float_attrs = MkRealizedAttributes (MkCosts 200 20 2) 0.9

public export
rlz_str2float : RealizedFunction (String -> Double) Str2Float.str2float_attrs
rlz_str2float = MkRealizedFunction str2float str2float_attrs
