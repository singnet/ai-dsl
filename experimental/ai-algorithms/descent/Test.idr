module Test

import OrdProofs

-- Super duper uber over simplified descent algorithm.

||| Descend as long as possible
d : Ord a => (a -> a) -> a -> a
d f x = if (f x) < x then d f (f x) else x

||| Proof that, if (f x) < x, then d (f x) = d x
dfx_eq_dx : Ord a => (f : a -> a) -> (x : a) ->
            (fx_lt_x : (f x) < x = True) -> Test.d f (f x) = Test.d f x
dfx_eq_dx f x fx_lt_x with ((f x) < x)
  _ | True = Refl
  _ | False = absurd fx_lt_x

||| Proof that, if (f x) < x, then d f x = d f (f x)
dx_eq_dfx : Ord a => (f : a -> a) -> (x : a) ->
            (fx_lt_x : (f x) < x = True) -> Test.d f x = Test.d f (f x)
dx_eq_dfx f x fx_lt_x with ((f x) < x)
  _ | True = Refl
  _ | False = absurd fx_lt_x

||| Proof that (d f x) is less than or equal to (f x)
dx_le_fx : Ord a => (f : a -> a) -> (x : a) ->
           (eq : f x < x = True) -> ((Test.d f x) <= (f x)) = True
dx_le_fx f x eq = believe_me ()

||| Proof that (f x) is less than or equal to x
fx_le_x : Ord a => (f : a -> a) -> (x : a) ->
          (eq : f x < x = True) -> f x <= x = True
fx_le_x f x eq = believe_me ()

||| Proof that the output of d is less than or equal to its input
dx_le_x : Ord a => (f : a -> a) -> (x : a) -> ((Test.d f x) <= x) = True
dx_le_x f x with ((f x) < x) proof eq
  -- _ | True = le_transitive ?dx_le_fx_hole (fx_le_x f x eq)
  -- _ | True = ?h (dx_le_fx f x eq) (fx_le_x f x eq)
  _ | True = ?h (le_transitive (dx_le_fx f x eq) (fx_le_x f x eq))
  _ | False = le_reflexive
