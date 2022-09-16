module SuperOverSimplifiedDescent

import OrdProofs

-- Super over simplified descent algorithm that does not take a
-- candidate.  Instead it just takes a cost and jumps from cost to
-- cost and assumes that (d f (f x)) is less than or equal to (f x)
-- instead of using induction.

||| Descend as much as possible
d : Ord a => (f : a -> a) -> (x : a) -> a
d f x = if (f x) < x then d f (f x) else x

||| Proof that, if (f x) < x, then d f x = d f (f x)
dx_eq_dfx : Ord a => (f : a -> a)
                  -> (x : a)
                  -> ((f x) < x) === True
                  -> d f x === d f (f x)
dx_eq_dfx f x lt with ((f x) < x)
  _ | True = Refl
  _ | False = absurd lt

||| Assume that d f (f x) <= f x
dfx_le_fx : Ord a => (f : a -> a) -> (x : a) -> (d f (f x) <= f x) === True
dfx_le_fx f x = believe_me ()

||| Prove that d f x <= f x
dx_le_fx : Ord a => (f : a -> a)
                 -> (x : a)
                 -> ((f x) < x) === True
                 -> (d f x <= f x) === True
dx_le_fx @{o} f x lt = rewrite (dx_eq_dfx @{o} f x lt) in (dfx_le_fx f x)

-- The following also works:
-- ||| Prove that (d f x) is less than or equal to (f x)
-- dx_le_fx : Ord a => (f : a -> a) -> (x : a) ->
--                     ((f x) < x) === True -> (d f x <= f x) === True
-- dx_le_fx f x lt = let eq = dx_eq_dfx f x lt
--                       le = dfx_le_fx f x
--                    in rewrite eq in le
