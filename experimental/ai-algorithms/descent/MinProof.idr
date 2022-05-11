module MinProof

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

||| Redefinition of min for full control
my_min : Ord a => a -> a -> a
my_min x y = if x < y then x else y

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

-- NEXT.-1: do the same of minimal element of a container

-- NEXT.0: see if we can use quantifiers (as in QTT)

-- NEXT.1: redefine LT x y as y < x = True and use interfaces in
-- Control.Relation and Decidable.Order.Strict

-- NEXT.2: use Not y < x = True instead of y < x = False

||| Proof that < is irreflexive (not generally true, assumed for now)
lt_irreflexive_prf : Ord a => (x : a) -> x < x = False
lt_irreflexive_prf _ = believe_me Void

||| Proof that < is asymmetric (not generally true, assumed for now)
lt_asymmetric_prf : Ord a => (x, y : a) -> x < y = True -> y < x = False
lt_asymmetric_prf _ _ _ = believe_me Void

||| Proof that < is connected (not generally true, assumed for now)
lt_connected_prf : Ord a => (x, y : a) -> x < y = False -> y < x = False -> x = y
lt_connected_prf _ _ _ _ = believe_me Void

||| Proof that <= is reflexive (maybe not generally true, assumed for now)
ge_reflexive_prf : Ord a => (x : a) -> x <= x = True
ge_reflexive_prf _ = believe_me Void

||| Proof that <= is the complement of the converse of < (not
||| generally true, assumed for now)
ge_converse_complement_prf : Ord a => (x, y : a) -> (b : Bool) -> x < y = b -> y <= x = not b
ge_converse_complement_prf _ _ _ _ = believe_me Void

||| Proof that <= is strongly connected (not generally true, assumed
||| for now)
ge_strongly_connected_prf : Ord a => (x, y : a) -> Either (x <= y = True) (y <= x = True)
ge_strongly_connected_prf _ _ = believe_me Void

||| Implicative form that <= is strongly connected (not generally
||| true, assumed for now).  This can perhaps be inferred from
||| ge_strongly_connected_prf.
ge_strongly_connected_imp_prf : Ord a => (x, y : a) -> x <= y = False -> y <= x = True
ge_strongly_connected_imp_prf _ _ = believe_me Void

||| Proof that my_min x y returns either x or y
my_min_eq_prf : Ord a => (x, y : a) -> Either (my_min x y = x) (my_min x y = y)
my_min_eq_prf x y with (x < y)
  _ | True = Left Refl
  _ | False = Right Refl

||| Proof that my_min is commutative
my_min_commutative_prf : Ord a => (x, y : a) -> my_min x y = my_min y x
my_min_commutative_prf x y with (x < y) proof eq1 | (y < x) proof eq2
  _ | True | False = Refl
  _ | False | True = Refl
  _ | False | False = sym (lt_connected_prf x y eq1 eq2)
  _ | True | True = absurd (trans (sym (lt_asymmetric_prf x y eq1)) eq2)
  -- Below are more decomposed proofs for the absurd and connected cases
  -- _ | True | True = absurd f_eq_t -- eq1 := x < y = True, eq2 := y < x = True
  --                   where f_eq_t : False = True
  --                         f_eq_t = trans f_eq_y_lt_x eq2
  --                         where f_eq_y_lt_x : False = y < x
  --                               f_eq_y_lt_x = sym y_lt_x_eq_f
  --                               where y_lt_x_eq_f : y < x = False
  --                                     y_lt_x_eq_f = lt_asymmetric_prf x y eq1
  -- _ | False | False = sym x_eq_y
  --                     where x_eq_y : x = y
  --                           x_eq_y = lt_connected_prf x y eq1 eq2

||| Proof that my_min x y is not greater than x and y
my_min_ngt_prf : Ord a => (x, y : a) -> (x < my_min x y = False, y < my_min x y = False)
my_min_ngt_prf x y with (x < y) proof eq
  _ | True = (lt_irreflexive_prf x, lt_asymmetric_prf x y eq)
  _ | False = (eq, lt_irreflexive_prf y)

||| Proof that my_min x y is equal to or lower than x and y
my_min_le_prf : Ord a => (x, y : a) -> (my_min x y <= x = True, my_min x y <= y = True)
my_min_le_prf x y with (x < y) proof eq
  _ | True = (ge_reflexive_prf x, ge_strongly_connected_imp_prf y x x_nle_y)
             where x_nle_y : y <= x = False
                   x_nle_y = ge_converse_complement_prf x y True eq
  _ | False = (ge_converse_complement_prf x y False eq, ge_reflexive_prf y)

-------------------------------------------------------
-- Assuming a total order, prove that                --
--                                                   --
--   If m∈S is a minimal element of S, then ∀s∈S m≤s --
-------------------------------------------------------

||| Return the minimal element of a vector of at least one element.
min_element : Ord a => Vect (S n) a -> a
min_element (x :: []) = x
min_element (x :: (y :: xs)) = my_min x (min_element (y :: xs))

||| Proof that min_element [x₁, ..., xₙ] is equal to or lower than x₁ to xₙ
min_element_le_prf : Ord a => (xs : Vect (S n) a) -> All (?p (min_element xs)) xs

-- From Thomas (CodingCellist)
--
-- -- proof that an `Ord` is less-than-or-equal-to another `Ord`
-- data ORD_LTE : Ord t => t -> t -> Type where
--   IsLT :  Ord t
--        => (x : t)
--        -> (y : t)
--        -> {auto 0 prf : (compare x y === LT)}
--        -> ORD_LTE x y
--   IsEQ :  Ord t
--        => (x : t)
--        -> (y : t)
--        -> {auto 0 prf : (compare x y === EQ)}
--        -> ORD_LTE x y
--
-- -- Proof that min_element [x₁, ..., xₙ] is equal to or lower than x₁ to xₙ
-- min_element_leq_prf : Ord a => (xs : Vect (S n) a) -> All (ORD_LTE (min_element xs)) xs
