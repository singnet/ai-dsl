module Int2Str

import public RealizedFunction

%default total

-- Realized int2str
public export
int2str : Int -> String
int2str = cast

public export
int2str_attrs : RealizedAttributes
int2str_attrs = MkRealizedAttributes (MkCosts 300 30 3) 0.8

public export
rlz_int2str : RealizedFunction (Int -> String) Int2Str.int2str_attrs
rlz_int2str = MkRealizedFunction int2str int2str_attrs
