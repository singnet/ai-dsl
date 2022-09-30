module Experiments.MinProofs

import Search.OrdProofs

import Data.Vect
import Data.Vect.Quantifiers

--------------------------------------------------------------------
-- Excercises to prove                                            --
--                                                                --
--   min(x, y) ≤ x and min(x, y) ≤ y                              --
--                                                                --
-- and other properties like commutativity.                       --
--                                                                --
-- According to                                                   --
--                                                                --
-- https://en.wikipedia.org/wiki/Maximal_and_minimal_elements     --
--                                                                --
-- The minimal element m of set S, is defined such that           --
--                                                                --
--   ∀s∈S, if s ≤ m then m ≤ s                                    --
--                                                                --
-- given as only assumption about ≤ that it is a preorder,        --
-- i.e. reflexive and transitive.                                 --
--                                                                --
-- Thus in our case, strictly following the definition, what we   --
-- want to ensure is that                                         --
--                                                                --
--   if x ≤ min(x, y) then min(x, y) ≤ x                          --
--   if y ≤ min(x, y) then min(x, y) ≤ y                          --
--                                                                --
-- If ≤ is antisymmetric, i.e. a partial order, then it becomes   --
--                                                                --
--   if x ≤ min(x, y) then min(x, y) = x                          --
--   if y ≤ min(x, y) then min(x, y) = y                          --
--                                                                --
-- Finally if ≤ is total, then it follows that                    --
--                                                                --
--   min(x, y) ≤ x and min(x, y) ≤ y                              --
--                                                                --
-- which is what we set out to prove at the beginning.            --
--------------------------------------------------------------------

---------------------------------------
-- Alternative implementation of min --
---------------------------------------

%hide min

||| Redefine min for full control
min : Ord a => a -> a -> a
min x y = if x < y then x else y

-----------------
-- Test min --
-----------------

test_min_1 : min 3.1 4.1 === 3.1
test_min_1 = Refl

test_min_2 : min 12.0 (-3.0) === -3.0
test_min_2 = Refl

test_min_3 : Either (min 3.1 4.1 = 3.1) (min 3.1 4.1 = 4.1)
test_min_3 = Left Refl

-------------------------
-- Proofs about min --
-------------------------

||| Proof that min x y returns either x or y
min_eq : Ord a => (x, y : a) -> Either (min x y === x) (min x y === y)
min_eq x y with (x < y)
  _ | True = Left Refl
  _ | False = Right Refl

||| Proof that min is commutative
min_commutative : Ord a => (x, y : a) -> min x y === min y x
min_commutative x y with (x < y) proof eq1 | (y < x) proof eq2
  _ | True | False = Refl
  _ | False | True = Refl
  _ | False | False = sym (lt_connected eq1 eq2)
  _ | True | True = absurd (trans (sym (lt_asymmetric eq1)) eq2)
  -- Below are more decomposed proofs for the absurd and connected cases
  -- _ | True | True = absurd f_eq_t -- eq1 := (x < y) === True, eq2 := (y < x) === True
  --                   where f_eq_t : False === True
  --                         f_eq_t = trans f_eq_y_lt_x eq2
  --                         where f_eq_y_lt_x : False === (y < x)
  --                               f_eq_y_lt_x = sym y_lt_x_eq_f
  --                               where y_lt_x_eq_f : (y < x) === False
  --                                     y_lt_x_eq_f = lt_asymmetric eq1
  -- _ | False | False = sym x_eq_y
  --                     where x_eq_y : x = y
  --                           x_eq_y = lt_connected eq1 eq2

||| Proof that min x y is not greater than x and y
min_ngt : Ord a => (x, y : a) -> ((x < min x y) === False, (y < min x y) === False)
min_ngt x y with (x < y) proof eq
  _ | True = (lt_irreflexive, lt_asymmetric eq)
  _ | False = (eq, lt_irreflexive)

||| Proof that min x y is equal to or lower than x and y
min_le : Ord a => (x, y : a) -> ((min x y <= x) === True, (min x y <= y) === True)
min_le x y with (x < y) proof eq
  _ | True = (le_reflexive, le_strongly_connected_imp x_nle_y)
             where x_nle_y : y <= x = False
                   x_nle_y = le_converse_complement eq
  _ | False = (le_converse_complement eq, le_reflexive)

||| Minimum function decorated with the proof of its correctness.
||| This is to explore the pros and cons of having the specification
||| inside the type signature of the function.
min_with : Ord a => (x, y : a) -> (m : a ** ((m <= x) === True, (m <= y) === True))
min_with x y = (min x y ** min_le x y)

-------------------------------------------------------
-- Assuming a total order, prove that                --
--                                                   --
--   If m∈S is a minimal element of S, then ∀s∈S m≤s --
-------------------------------------------------------

||| Return the minimal element of a vector of at least one element.
min_element : Ord a => Vect (S n) a -> a
min_element (x :: []) = x
min_element (x :: (y :: ys)) = min x (min_element (y :: ys))

||| Proof that min_element [x₁, ..., xₙ] is equal to or lower than x₁ to xₙ
min_element_le : Ord a => (xs : Vect (S n) a)
                       -> All (\x : a => ((min_element xs) <= x) === True) xs
min_element_le (x :: []) = le_reflexive :: []
min_element_le (x :: (y :: ys)) = head :: tail
  where head : ((min_element (x :: (y :: ys))) <= x) === True
        head = fst (min_le x (min_element (y :: ys)))
        tail : All (\z : a => ((min_element (x :: (y :: ys))) <= z) === True) (y :: ys)
        tail = mapProperty prf_f (min_element_le (y :: ys))
        where prf_f : {0 w : a} -> (min_element (y :: ys) <= w) === True
                                -> (min_element (x :: (y :: ys)) <= w) === True
              prf_f prf with (x < min_element (y :: ys)) proof eq
                _ | True = le_transitive (le_reflexive_closure_lt (Left eq)) prf
                _ | False = prf

||| Minimal element function decorated with the proof of its
||| correctness.  This is to explore the pros and cons of having the
||| specification inside the type signature of the function.
min_element_with : Ord a => (xs : Vect (S n) a)
                         -> (m : a ** All (\x : a => (m <= x) === True) xs)
min_element_with xs = (min_element xs ** min_element_le xs)
