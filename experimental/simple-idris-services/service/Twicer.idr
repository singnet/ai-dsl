module Twicer

import RealizedFunction

%default total

-- Realized twicer
public export
twicer : Int -> Int
twicer = (*2)

public export
twicer_attrs : RealizedAttributes
twicer_attrs = MkRealizedAttributes (MkCosts 200 20 2) 0.9

public export
rlz_twicer : RealizedFunction (Int -> Int) Twicer.twicer_attrs
rlz_twicer = MkRealizedFunction twicer twicer_attrs
