module FunEq

successor : Nat -> Nat
successor k = S k

successor_alt : Nat -> Nat
successor_alt k = S k

successor_homotopy : List Unit -> List Unit
successor_homotopy l = () :: l

fun_eq : (Main.successor k) = (Main.successor_alt k)
fun_eq = Refl

-- fun_eq_homotopy : (Main.successor_alt k) = (Main.successor_homotopy k)
-- fun_eq_homotopy = Refl
