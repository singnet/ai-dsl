module OverSimplifiedDescent

import OrdProofs

-- Over simplified descent algorithm that does not take a candidate.
-- Instead if only takes a cost instead and a jump function from cost
-- to cost.

||| Descend as long as possible.  Given a function, f, and an initial
||| value, x, iteratively call f as long as the output is less than
||| the input.
-- NEXT: add note about well founded cost to guaranty termination
-- NEXT: Epsilon
d : Ord a => (f : a -> a) -> (x : a) -> a
d f x = if (f x) < x then d f (f x) else x

||| Proof that, if (f x) < x, then d (f x) = d x
dfx_eq_dx : Ord a => (f : a -> a) -> (x : a) ->
            -- Property expressing that if (f x) < x then d f (f x) = d f x
            (fx_lt_x : (f x) < x = True) -> d f (f x) = d f x
dfx_eq_dx f x fx_lt_x with ((f x) < x)
  _ | True = Refl
  _ | False = absurd fx_lt_x

||| Proof that, if (f x) < x, then d f x = d f (f x)
dx_eq_dfx : Ord a => (f : a -> a) -> (x : a) ->
            -- Property expressing that if (f x) < x then d f x = d f (f x)
            (fx_lt_x : (f x) < x = True) -> d f x = d f (f x)
dx_eq_dfx f x fx_lt_x with ((f x) < x)
  _ | True = Refl
  _ | False = absurd fx_lt_x

||| Proof that the output of d is less than or equal to its input
dx_le_x : Ord a => (f : a -> a) -> (x : a) ->
          -- Property expressing that the output of d
          -- is less than or equal to the input
          ((d f x) <= x) === True
dx_le_x f x with ((f x) < x) proof eq
  _ | True = le_transitive dx_le_fx fx_le_x
             where dffx_le_fx : d f (f x) <= (f x) = True
                   dffx_le_fx = dx_le_x f (f x)
                   dx_eq_dfx_prf : d f x = d f (f x)
                   dx_eq_dfx_prf = dx_eq_dfx f x eq
                   dx_le_fx : (d f x) <= (f x) = True
                   dx_le_fx = rewrite dx_eq_dfx_prf in dffx_le_fx
                   fx_le_x : (f x) <= x = True
                   fx_le_x = le_reflexive_closure_lt (Left eq)
                   -- conclusion : ((d f x) <= x) === True
                   -- conclusion = believe_me ()
                   -- conclusion = le_transitive dx_le_fx fx_le_x
  _ | False = le_reflexive

-- ||| Descend as long as possible.  Given a function, f, and an initial
-- ||| value, x, iteratively call f as long as the output is less than
-- ||| the input.
-- d : Ord a => (f : a -> a) -> (x : a) -> a
-- d f x = if (f x) < x then d f (f x) else x

-- ||| Proof that the output of d is less than or equal to its input
-- prf : Ord a => (f : a -> a) -> (x : a) -> ((d f x) <= x) === True
-- prf f x with ((f x) < x) proof eq
--   _ | True = conclusion
--              where conclusion : ((d f x) <= x) === True
--                    conclusion = believe_me ()
--   _ | False = believe_me ()
