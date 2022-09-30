module Experiments.FunEq

successor : Nat -> Nat
successor k = S k

successor_alt : Nat -> Nat
successor_alt k = S k

successor_homotopy : List Unit -> List Unit
successor_homotopy l = () :: l

||| Proof that two functions are equivalent without using homotopy.
fun_eq : (Experiments.FunEq.successor k) = (Experiments.FunEq.successor_alt k)
fun_eq = Refl

-- Idris does not support homotopy out of the box
-- fun_eq_homotopy : (Experiments.FunEq.successor_alt k) = (Experiments.FunEq.successor_homotopy k)
-- fun_eq_homotopy = Refl
