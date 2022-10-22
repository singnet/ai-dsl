module Tests

import Utils

%default total

%language ElabReflection





matchVar1 : (a : Nat) -> Nat
matchVar1 a = %runElab fillAny



matchVar2 : (t : Type) -> t -> t
matchVar2 t a = %runElab fillAny


matchVar3 : (a : String) -> (Nat -> Nat)
matchVar3 a = %runElab fillAnyWith [`{matchVar1}]

findGlobals1 : List (Name, TTImp)
findGlobals1 = %runElab rGetType [(fromString "matchVar3")]


-- 'check' can be used to normalize TTImp values
runsTTImp : Integer
runsTTImp = %runElab (check $ (\x => (`( 2 * ~(x)))) `(8))
