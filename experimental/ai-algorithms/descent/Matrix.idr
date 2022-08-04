module Matrix

import Data.Vect

-----------------------------------
-- Matrix data type definition   --
-----------------------------------

||| Matrix, m rows by n columns with elements of type a
public export
record Matrix (m, n : Nat) (a : Type) where
  constructor MkMatrix
  vects : Vect m (Vect n a)

||| Row vector, unirow matrix with elements of type a
public export
RowVect : (n : Nat) -> (a : Type) -> Type
RowVect n a = Matrix 1 n a

||| Column vector, unicolumn matrix with elements of type a
public export
ColVect : (m : Nat) -> (a : Type) -> Type
ColVect m a = Matrix m 1 a

-------------------------------
-- Interface implementations --
-------------------------------

||| Implement Functor interface
public export
implementation Functor (Matrix m n) where
  map f x = MkMatrix (map (map f) x.vects)

||| Implement Zippable interface
public export
implementation Zippable (Matrix m n) where
  zipWith f x y = MkMatrix (zipWith (zipWith f) x.vects y.vects)
  zipWith3 f x y z = MkMatrix (zipWith3 (zipWith3 f) x.vects y.vects z.vects)
  unzipWith = ?unzipWith
  unzipWith3 = ?unzipWith3

||| Implement Show interface
public export
implementation Show a => Show (Matrix m n a) where
  show = ?s -- NEXT

----------------------------------------------------------------
-- Matrix operators.  The operator notations, with the        --
-- exception of `negation`, are borrowed from GNU Octave, see --
-- https://docs.octave.org/interpreter/Arithmetic-Ops.html    --
----------------------------------------------------------------

||| Element-wise matrix addition
public export
(+) : Num a => Matrix m n a -> Matrix m n a -> Matrix m n a
(+) = zipWith (+)

||| Element-wise matrix subtraction
public export
(-) : Neg a => Matrix m n a -> Matrix m n a -> Matrix m n a
(-) = zipWith (-)

||| Element-wise matrix negation
public export
negate : Neg a => Matrix m n a -> Matrix m n a
negate = map negate

-- Operator for element-wise matrix multiplication.
infixr 9 .*

||| Element-wise matrix multiplication.  Not to be confused with dot
||| product which are between vectors.  The dot character in `.*` was
||| probably chosen in Matlab to refer to point-wise operation.  An
||| alternative would be to use `*` for element-wise multiplication
||| and `.*` for dot product, (in such case Matrix could even
||| implement the Num interface), however `*` implements matrix
||| multiplication in Matlab and GNU Octave, two well established
||| pieces of software for matrix computing.
public export
(.*) : Num a => Matrix m n a -> Matrix m n a -> Matrix m n a
(.*) = zipWith (*)

||| Dot product between Vect.  To use dot product between RowVect and
||| ColVect you may use matrix multiplication combined with matrix
||| transpose when necessary.
public export
dot : Num a => Vect n a -> Vect n a -> a
dot x y = foldl (+) 0 (zipWith (*) x y)

||| Matrix transpose.  The multiplicity of n must be set to
||| unrestricted because it is unrestricted in Data.Vect.transpose,
||| probably in order to support transpose of Matrix 0 n
public export
transpose : {n : Nat} -> Matrix m n a -> Matrix n m a
transpose x = MkMatrix (transpose x.vects)

||| Matrix multiplication.  The multiplicity of n must be set to
||| unrestricted because it is unrestricted in Matrix.transpose.
public export
(*) : {n : Nat} -> Num a => Matrix m k a -> Matrix k n a -> Matrix m n a
(*) x y = let yt : Matrix n k a
              yt = Matrix.transpose y
          in MkMatrix (map (\xv => map (dot xv) yt.vects) x.vects)

----------
-- Test --
----------

-- Test transpose
A : Matrix 3 2 Integer
A = MkMatrix [[1, 2],
              [3, 4],
              [5, 6]]
AT : Matrix 2 3 Integer
AT = MkMatrix [[1, 3, 5],
               [2, 4, 6]]
transpose_test : AT === transpose A
transpose_test = Refl

-- Test matrix multiplication
B : Matrix 2 3 Integer
B = MkMatrix [[7,   8,  9],
              [10, 11, 12]]
AB : Matrix 3 3 Integer
AB = MkMatrix [[27,  30,  33],
               [61,  68,  75],
               [95, 106, 117]]
matrix_multiplication_test : AB === A * B
matrix_multiplication_test = Refl
