module OverSimplifiedDescent

import OrdProofs

-- Over simplified descent algorithm that does not take a candidate.
-- Instead it just takes a cost and jumps from cost to cost.

||| Descend as long as possible.  Given a function, f, and an initial
||| value, x, iteratively call f as long as the output is less than
||| the input.
d : Ord a => (f : a -> a) -> (x : a) -> a
d f x = if (f x) < x then d f (f x) else x

||| Proof that the output of d is less than or equal to its input
dx_le_x : Ord a => (f : a -> a) -> (x : a) -> ((d f x) <= x) = True
dx_le_x f x with ((f x) < x) proof eq
  _ | True = let dfx_le_fx = dx_le_x f (f x)
                 fx_le_x = le_reflexive_closure_lt (Left eq)
              in le_transitive dfx_le_fx fx_le_x
  _ | False = le_reflexive
