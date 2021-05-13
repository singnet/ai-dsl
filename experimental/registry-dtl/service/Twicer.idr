module Twicer

import public Numeric

%default total

-- TODO: fix the hole ?pr by using even nat instead of integer

public export
||| Guaranteed to produce a value divisible by 2
twicer : Integer -> EvenInteger
twicer b = ((2 * wfb) ** (Factor (wfb ** (?pr)))) where
  wfb : WFInt
  wfb = cast b
