module MinProof

---------------------------------------------------------------
-- Excercise to prove                                        --
--                                                           --
-- min(x, y) <= x and min(x, y) <= y                         --
---------------------------------------------------------------

my_min : Ord a => a -> a -> a
-- my_min x y = if x < y then x else y -- Maybe try with x <= y
my_min x y with (x < y)
  my_min x y | True = x
  my_min x y | False = y

-----------------
-- Test my_min --
-----------------
test_my_min_1 : my_min 3.1 4.1 = 3.1
test_my_min_1 = Refl

test_my_min_2 : my_min 12.0 (-3.0) = -3.0
test_my_min_2 = Refl

test_my_min_3 : Either (my_min 3.1 4.1 = 3.1) (my_min 3.1 4.1 = 4.1)
test_my_min_3 = Left Refl

------------------
-- Proof my_min --
------------------
my_min_eq_proof : Ord a => (x, y: a) -> Either (my_min x y = x) (my_min x y = y)
my_min_eq_proof x y with (x < y)
  my_min_eq_proof x y | True = Left Refl
  my_min_eq_proof x y | False = Right Refl

my_min_lte_proof : Ord a => (x, y: a) -> (((my_min x y <= x) = True), ((my_min x y <= y) = True))
my_min_lte_proof x y = believe_me Void

my_min_lte_proof_alt : Ord a => (x, y: a) -> (x < (min x y) = False, y < (min x y) = False)
my_min_lte_proof_alt x y = ?my_min_lte_proof_alt_rhs

-- From Stefan Höck, for more see
-- https://github.com/stefan-hoeck/idris2-prim

-- ||| This is unsafe! We could well implement `Ord` in such a
-- ||| way that this does not hold!
OrdLaw1 : Ord a => (0 x,y : a) -> (0 prf : (x < y) === False) -> (y <= x) === True
OrdLaw1 _ _ _ = believe_me Void

||| This is unsafe! We could well implement `Ord` in such a
||| way that this does not hold!
OrdLaw2 : Ord a => (0 x : a) -> (x <= x) === True
OrdLaw2 _ = believe_me Void

MyMinLaw2 : Ord a => (x,y : a) -> (my_min x y <= x) === True
MyMinLaw2 x y with (x < y) proof prf
  MyMinLaw2 x y | True  = OrdLaw2 x
  MyMinLaw2 x y | False = OrdLaw1 x y prf
