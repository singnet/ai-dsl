module MinProof

---------------------------------------------------------------
-- Excercises to prove                                       --
--                                                           --
-- min(x, y) <= x and min(x, y) <= y                         --
--                                                           --
-- and a few other properties like commutativity.            --
---------------------------------------------------------------

----------------------------------------------------------------
-- Alternative implementation of min to have its full control --
----------------------------------------------------------------

||| Redefinition of min for more control
my_min : Ord a => a -> a -> a
-- my_min x y = if x < y then x else y
my_min x y with (x < y)
  _ | True = x
  _ | False = y

-----------------
-- Test my_min --
-----------------

test_my_min_1 : my_min 3.1 4.1 = 3.1
test_my_min_1 = Refl

test_my_min_2 : my_min 12.0 (-3.0) = -3.0
test_my_min_2 = Refl

test_my_min_3 : Either (my_min 3.1 4.1 = 3.1) (my_min 3.1 4.1 = 4.1)
test_my_min_3 = Left Refl

-------------------------
-- Proofs about my_min --
-------------------------

||| Proof that my_min x y returns either x or y
my_min_eq_prf : Ord a => (x, y : a) -> Either (my_min x y = x) (my_min x y = y)
my_min_eq_prf x y with (x < y)
  _ | True = Left Refl
  _ | False = Right Refl

-- NEXT: study Decidable.Order.Strict, for more constrained Ord

||| Proof that < is asymmetric (not generally true, assumed for now)
lt_asymmetric_prf : Ord a => (x, y : a) -> x < y = True -> y < x = False
lt_asymmetric_prf _ _ _ = believe_me Void

||| Proof that < is connected (not generally true, assumed for now)
lt_connected_prf : Ord a => (x, y : a) -> x < y = False -> y < x = False -> x = y
lt_connected_prf _ _ _ _ = believe_me Void

||| Proof that my_min is commutative
my_min_commutative_prf : Ord a => (x, y: a) -> my_min x y = my_min y x
my_min_commutative_prf x y with (x < y) proof eq1 | (y < x) proof eq2
  _ | True | False = Refl
  _ | False | True = Refl
  _ | False | False = sym (lt_connected_prf x y eq1 eq2)
  _ | True | True = absurd (trans (sym (lt_asymmetric_prf x y eq1)) eq2)
  -- Below are more decomposed proofs for the absurd and connected cases
  -- _ | True | True = absurd f_eq_t -- eq1 := x < y = True, eq2 := y < x = True
  --                   where f_eq_t : False = True
  --                         f_eq_t = trans f_eq_y_lt_x eq2
  --                         where f_eq_y_lt_x : False = y < x /\ y < x = True
  --                               f_eq_y_lt_x = sym y_lt_x_eq_f
  --                               where y_lt_x_eq_f : y < x = False
  --                                     y_lt_x_eq_f = lt_asymmetric_prf x y eq1
  -- _ | False | False = sym x_eq_y
  --                     where x_eq_y : x = y
  --                           x_eq_y = lt_connected_prf x y eq1 eq2

||| Proof that my_min x y is equal to or lower than x and y
my_min_lte_prf : Ord a => (x, y: a) -> (((my_min x y <= x) = True), ((my_min x y <= y) = True))
my_min_lte_prf x y = believe_me Void

||| Proof that my_min x y is not greater than x and y
my_min_ngt_prf : Ord a => (x, y: a) -> (x < (min x y) = False, y < (min x y) = False)
my_min_ngt_prf x y = believe_me Void -- NEXT

-- -- From Stefan Höck, for more see
-- -- https://github.com/stefan-hoeck/idris2-prim

-- -- ||| This is unsafe! We could well implement `Ord` in such a
-- -- ||| way that this does not hold!
-- OrdLaw1 : Ord a => (0 x,y : a) -> (0 prf : (x < y) === False) -> (y <= x) === True
-- OrdLaw1 _ _ _ = believe_me Void

-- ||| This is unsafe! We could well implement `Ord` in such a
-- ||| way that this does not hold!
-- OrdLaw2 : Ord a => (0 x : a) -> (x <= x) === True
-- OrdLaw2 _ = believe_me Void

-- MyMinLaw2 : Ord a => (x,y : a) -> (my_min x y <= x) === True
-- MyMinLaw2 x y with (x < y) proof prf
--   MyMinLaw2 x y | True  = OrdLaw2 x
--   MyMinLaw2 x y | False = OrdLaw1 x y prf

-- From gallais

-- Today at 3:12 PM
-- hmm, that's weird:
--
-- my_min_commutative_prf x y
--   with (lt_asymmetric_prf x y) | (y < x) | (x < y)
--
--
-- is rejected but
--
-- my_min_commutative_prf x y
--   with (lt_asymmetric_prf x y) | (y < x)
--   _ | prf | p with (x < y)
--     _ | q = ?a
--
--
-- is accepted
-- (they should be equivalent)
