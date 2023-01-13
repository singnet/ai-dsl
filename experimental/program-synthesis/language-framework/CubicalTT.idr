module CubicalTT
import Language.Reflection
import Language.Reflection.Pretty
import Language.Reflection.Syntax
import public Language.Reflection.Types

import Interpreter

import Data.Vect

%default total




-- Interval type
data CubeInt : Type where
     IZero : CubeInt
     IOne  : CubeInt
     IVar  : a -> CubeInt
     ISubt : (r : CubeInt) -> CubeInt
     IAnd  : (r : CubeInt) -> (s : CubeInt) -> CubeInt
     IOr   : (r : CubeInt) -> (s : CubeInt) -> CubeInt



RefName : Type
RefName = Nat

data FaceForm : Type where
     FZero : FaceForm
     FOne  : FaceForm
     FMin  : (i : RefName) -> FaceForm
     FMax  : (i : RefName) -> FaceForm
     FAnd  : (f1 : FaceForm) -> (f2 : FaceForm) -> FaceForm
     FOr   : (f1 : FaceForm) -> (f2 : FaceForm) -> FaceForm



-- Syntax for Terms and Types in Cubical Type Theory
data CubeTT : Type where
     -- Pi Types
     TVar  : (x : RefName) -> CubeTT
     TLam  : (x : RefName) -> (a : CubeTT) -> (t : CubeTT) -> CubeTT
     TApp  : (t : CubeTT) -> (u : CubeTT) -> CubeTT
     TArr  : (x : RefName) -> (a : CubeTT) -> (b : CubeTT) -> CubeTT
     -- Sigma Types
     TPair : (t : CubeTT) -> (u : CubeTT) -> CubeTT
     TFst  : (t : CubeTT) -> CubeTT
     TSnd  : (t : CubeTT) -> CubeTT
     TCrs  : (x : RefName) -> (a : CubeTT) -> (b : CubeTT) -> CubeTT
     -- Natural Numbers
     TNat  : Nat -> CubeTT
     -- Path Types
     TPath : (a : CubeTT) -> (t : CubeTT) -> (u : CubeTT) -> CubeTT
     TPAbs : (i : RefName) -> (t : CubeTT) -> CubeTT
     TPApp : (t : CubeTT) -> (r : CubeInt) -> CubeTT
     -- Systems
     TSys  : (s : Vect n (FaceForm, CubeTT)) -> CubeTT
     -- Compositions



data Context : Type where
     Empty : Context
     Extend : Context -> (x : RefName) -> (ty : CubeTT) -> Context
