module Numeric
import Data.Nat

%default total

-- Well-founded Integer
-- All Integers are either a natural number
-- or the inversion of a positive number.
public export
data WFInt : Type where
     Nat : (n : Nat) -> WFInt
     Neg : (n : Nat) -> WFInt --Note: In the negative case, n=Z represents -1.

-- Magnitude of an integer
public export
mag : WFInt -> Nat
mag (Nat n) = n
mag (Neg n) = (S n)


-- Implement casting back and forth from normal Integer type
public export
Cast WFInt Integer where
     cast (Nat n) = cast n
     cast (Neg n) = negate $ cast (S n)


public export
Cast Integer WFInt where
     cast n = case (compare n 0) of
           EQ => Nat (fromInteger n)
           GT => Nat (fromInteger n)
           LT => Neg (fromInteger $ negate $ n + 1)


-- For arithmetic operations, cast to Integer and then cast back
public export
Num WFInt where
   (+) a b = cast $ (cast a) + (cast b)
   (*) a b = cast $ (cast a) * (cast b)
   fromInteger a = cast a


public export
Neg WFInt where
    negate a = cast $ negate $ (the Integer $ cast a)
    (-) a b = cast $ (the Integer $ cast a) - (the Integer $ cast b)



-- n-parity, i.e. proof that an integer a is evenly divisible by n (or not).
public export
data Parity : (a : WFInt) -> (n : WFInt) -> Type where
     -- a has even n-parity if there exists an integer multiple x s.t. x*n = a.
     Even : (x : WFInt ** (x * n) = a) -> Parity a n

public export
data OddParity : (a : WFInt) -> (n : WFInt) -> Type where
     -- a has odd n-parity if there exists
     Odd : (b : WFInt ** LT = compare (mag b) (mag n)) -> (Parity (a + b) n) ->  OddParity a n
