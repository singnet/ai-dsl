module Matrix

import System.Random
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

------------------
-- Constructors --
------------------

||| Fill a matrix m*n with a constant value
|||
||| @m number of rows
||| @n number of columns
||| @x the value to repeat
public export
replicate : {m, n : Nat} -> (x : a) -> Matrix m n a
replicate {m, n} x = MkMatrix (replicate m (replicate n x))

-------------------------------
-- Interface implementations --
-------------------------------

||| Implement Cast interface
public export
implementation Cast (Matrix m n a) (Vect (m*n) a) where
  cast x = Data.Vect.concat x.vects

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
  show x = show x.vects         -- TODO: improve

||| Implement Foldable
public export
implementation Foldable (Matrix m n) where
  -- Right-fold a matrix, x, starting from its bottom right element.
  foldr f i x = foldr f i (Data.Vect.concat x.vects)

||| Implement Traversable
public export
implementation Traversable (Matrix m n) where
  traverse f x = map MkMatrix (traverse (\e => traverse f e) x.vects)

||| implement Random interface for Vect
public export
implementation Random a => Random (Vect k a) where
  randomIO = ?randomIOVect
  randomRIO (x, y) = traverse randomRIO (zipWith MkPair x y)

||| implement Random interface
public export
implementation Random a => Random (Matrix m n a) where
  randomIO = ?randomIOMatrix
  randomRIO (x, y) = traverse randomRIO (zipWith MkPair x y)

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

||| Like Data.Vect.transpose but assumes non null row
nnr_transpose : Vect (S m) (Vect n a) -> Vect n (Vect (S m) a)
nnr_transpose (rx :: []) = map (\x => x :: []) rx
nnr_transpose (rx :: ry :: rs) = zipWith (::) rx (nnr_transpose (ry :: rs))

||| Matrix multiplication.  The multiplicity of n must be set to
||| unrestricted because it is unrestricted in Matrix.transpose.
public export
(*) : {n : Nat} -> Num a => Matrix m k a -> Matrix k n a -> Matrix m n a
x * y = let yT : Matrix n k a
            yT = Matrix.transpose y
        in MkMatrix (map (\xv => map (dot xv) yT.vects) x.vects)

||| Scale a matrix by a given factor
public export
scale : Num a => a -> Matrix m n a -> Matrix m n a
scale x m = map (* x) m

-- Operators for joining matrices horizontally and vertically.  Named
-- after the corresponding Haskell operators.
infixr 9 <->
infixr 9 <|>

||| Horizontally join two matrices
public export
(<->) : Matrix m n a -> Matrix k n a -> Matrix (m + k) n a
x <-> y = MkMatrix (x.vects ++ y.vects)

||| Vertically join two matrices
public export
(<|>) : {m, n, k : Nat} -> Matrix m n a -> Matrix m k a -> Matrix m (n + k) a
x <|> y = transpose ((transpose x) <-> (transpose y))

----------
-- Test --
----------

-- Test replicate
K : ColVect 3 Double
K = MkMatrix [[-5.0],
              [-5.0],
              [-5.0]]
replicate_test : K === replicate (-5.0)
replicate_test = Refl

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

-- Test transpose involution
C : ColVect 3 Integer
C = MkMatrix [[1],
              [2],
              [3]]
transpose_involution_test : C === transpose (transpose C)
transpose_involution_test = Refl

-- Test vertical join
D : Matrix 2 2 Integer
D = MkMatrix [[1, 2],
              [1, 2]]
vertical_join_test : let c1 : ColVect 2 Integer
                         c1 = replicate 1
                         c2 : ColVect 2 Integer
                         c2 = replicate 2
                      in D === c1 <|> c2
vertical_join_test = Refl
