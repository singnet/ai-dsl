module Tests

import Utils


%language ElabReflection





matchVar1 : (a : Nat) -> Nat
matchVar1 a = %runElab fillAny


matchVar2 : (t : Type) -> t -> t
matchVar2 t a = %runElab fillAny

matchVar3 : a -> b -> c -> (t : Type) -> t
matchVar3 x y z = %runElab fillAny
