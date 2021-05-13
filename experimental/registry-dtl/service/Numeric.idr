module Numeric
import Data.Nat

%default total

||| Well-founded Integer.  All Integers are either a natural number or
||| the inversion of a positive number.
public export
data WFInt : Type where
     Nat : (n : Nat) -> WFInt
     Neg : (n : Nat) -> WFInt --Note: In the negative case, n=Z represents -1.

||| Casting from well founded to normal integer
public export
Cast WFInt Integer where
     cast (Nat n) = cast n
     cast (Neg n) = negate $ cast (S n)

||| Casting from normal to well founded integer
public export
Cast Integer WFInt where
     cast n = case (compare n 0) of
           EQ => Nat (fromInteger n)
           GT => Nat (fromInteger n)
           LT => Neg (fromInteger $ negate $ n + 1)

||| For arithmetic operations, cast to Integer and then cast back
public export
Num WFInt where
   (+) a b = cast $ (cast a) + (cast b)
   (*) a b = cast $ (cast a) * (cast b)
   fromInteger a = cast a

public export
Neg WFInt where
    negate a = cast $ negate $ (the Integer $ cast a)
    (-) a b = cast $ (the Integer $ cast a) - (the Integer $ cast b)

public export
partial
Integral WFInt where
         div a b = cast $ the Integer $ div (cast a) (cast b)
         mod a b = cast $ the Integer $ mod (cast a) (cast b)

||| n-parity, i.e. proof that an integer a is evenly divisible by n.
public export
data Parity : (a : WFInt) -> (n : WFInt) -> Type where
     -- a has even n-parity if there exists an integer multiple x s.t. x*n = a.
     Factor : (x : WFInt ** (x * n) = a) -> Parity a n

||| Alias type for even integer
public export
EvenInteger : Type
EvenInteger = (n : WFInt ** Parity n 2)

||| Casting from even to normal integer
public export
Cast EvenInteger Integer where
     cast x = cast (the WFInt (fst x))

||| Force an integer to be even
force_even : Integer -> Integer
force_even x = case (mod x 2) of
                    0 => x
                    _ => x - 1

||| Implement casting from normal to even integer
-- TODO: solve ?pr by using EvenNat
public export
Cast Integer EvenInteger where
     cast e = ((cast (force_even e)) ** (Factor ((div (cast e) 2) ** ?pr)))
