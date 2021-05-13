module Halfer

import public Numeric

%default total

||| Divide even integer by 2
public export
halfer : EvenInteger -> Integer
-- a: input integer
-- x: half of a
-- p: proof that x is the half of a
halfer (a ** (Factor (x ** p))) = cast x
