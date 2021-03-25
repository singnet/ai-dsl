module Compo3

import Incrementer
import Twicer
import Halfer

%default total

-- Realized (halfer . incrementer . twicer).  If halfer can only take
-- an even interger, then such composition is not valid.
rlz_compo3_attrs : RealizedAttributes
rlz_compo3_attrs = MkRealizedAttributes (MkCosts 600 60 6) 0.8
rlz_compo3 : RealizedFunction (Int -> Int) Compo3.rlz_compo3_attrs
rlz_compo3 = (compose rlz_halfer (compose rlz_incrementer rlz_twicer))
