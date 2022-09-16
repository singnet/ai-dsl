module Matrix

import System.Random
import Data.String
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

||| Implement Foldable
public export
implementation Foldable (Matrix m n) where
  -- Right-fold a matrix, x, starting from its bottom right element.
  foldr f i x = foldr f i (Data.Vect.concat x.vects)

||| Implement Traversable
public export
implementation Traversable (Matrix m n) where
  traverse f x = map MkMatrix (traverse (\e => traverse f e) x.vects)

||| Implement Random interface for Vect
public export
implementation Random a => Random (Vect k a) where
  randomIO = ?randomIOVect
  randomRIO (x, y) = traverse randomRIO (zipWith MkPair x y)

||| Implement Random interface
public export
implementation Random a => Random (Matrix m n a) where
  randomIO = ?randomIOMatrix
  randomRIO (x, y) = traverse randomRIO (zipWith MkPair x y)

||| Implement Show interface.  A matrix is represented in the usual
||| mathematical way, enclosed between two big square brackets.
|||
||| For instance the following matrix
|||
||| MkMatrix [[ 1,   2],
|||           [33,   4],
|||           [ 5, 666]]
|||
||| is rendered as
|||
||| ┌         ┐
||| │   1   2 │
||| │  33   4 │
||| │   5 666 │
||| └         ┘
|||
||| Note the use the unicode characteres ┌, ┐, └, ┘ and │.
public export
implementation Show a => Show (Matrix m n a) where
  show x = let -- Create a matrix of strings of rendered cells
               strs : Matrix m n String
               strs = map show x
               -- Create a matrix of string lengths of rendered cells
               lengths : Matrix m n Nat
               lengths = map length strs
               -- Get the max length of all rendered cells
               max_str_len : Nat
               max_str_len = foldr max 0 lengths
               -- Left pad all rendered cells to be aligned
               x_padded_strs : Matrix m n String
               x_padded_strs = map (padLeft max_str_len ' ') strs
               -- Function to render a line
               render_line : Vect n String -> String
               render_line v = "│ " ++ (joinBy " " (toList v)) ++ " │"
               -- Create a vector of rendered lines
               rendered_lines : Vect m String
               rendered_lines = map render_line x_padded_strs.vects
               -- Get the max length of all rendered lines
               max_lines_len : Nat
               max_lines_len = foldr max 0 (map length rendered_lines)
               -- Define the spaces of the decorating lines
               spaces : String
               spaces = replicate (minus max_lines_len 2) ' '
               -- Decorate with "┌ ... ┐" and "└ ... ┘"
               decorated_rendered_lines : List String
               decorated_rendered_lines = [("┌" ++ spaces ++ "┐")] ++
                                          (toList rendered_lines) ++
                                          [("└" ++ spaces ++ "┘")]
            in joinBy "\n" decorated_rendered_lines

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
x * y = let yT : Matrix n k a
            yT = Matrix.transpose y
        in MkMatrix (map (\xv => map (dot xv) yT.vects) x.vects)

||| Scale a matrix by a given factor, element-wise.
public export
scale : Num a => a -> Matrix m n a -> Matrix m n a
scale x m = map (* x) m

||| Horizontally split a matrix at a given row
public export
splitAtRow : (k : Nat) -> Matrix (k + m) n a -> (Matrix k n a, Matrix m n a)
splitAtRow k x = let (v1, v2) = splitAt k x.vects
                 in (MkMatrix v1, MkMatrix v2)

||| Vertically split a matrix at a given column
public export
splitAtCol : {m, n : Nat} ->
             (k : Nat) ->
             Matrix m (k + n) a ->
             (Matrix m k a, Matrix m n a)
splitAtCol k x = let (xT1, xT2) = splitAtRow k (transpose x)
                 in (transpose xT1, transpose xT2)

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

-- Test show
M : Matrix 3 2 Integer
M = MkMatrix [[ 1,   2],
              [33,   4],
              [ 5, 666]]
M_rendered : String
M_rendered = "┌         ┐\n" ++
             "│   1   2 │\n" ++
             "│  33   4 │\n" ++
             "│   5 666 │\n" ++
             "└         ┘"

-- Disabled because Idris complains with multiple errors
-- show_test : (show M) === M_rendered
-- show_test = Refl
