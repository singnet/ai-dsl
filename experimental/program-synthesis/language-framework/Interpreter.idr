module Interpreter
import Data.Either
import Data.Vect


%default total


-- Interface for language term types
interface Term (m : Type) where
          normal : m -> Bool


-- Interface for language contexts.
interface Context c where
          -- The category for any possible errors in execution
          Error : Type



data Language : Type where
     MkLang : (context : Type) -> (term : Type) ->
             (context -> term -> Maybe (context)) -> Language



intTy : Language -> Type
intTy (MkLang c t f) = (c -> t -> Maybe c)

interpreter : (l : Language) -> intTy l
interpreter (MkLang _ _ i) = i



-- Example languages for testing



-- Basic addition
data AddTerm : Type  where
     ATVal  : Integer -> AddTerm
     ATPlus : AddTerm -> AddTerm -> AddTerm

Term AddTerm where
     normal (ATVal x) = True
     normal (ATPlus x y) = False

data AddContext : Type where
     Empty : AddContext
     Total : Integer -> AddContext

result : AddContext -> Integer
result Empty = 0
result (Total x) = x

Context AddContext where
        Error = String



traverse : AddContext -> AddTerm -> Maybe (AddContext)
traverse c (ATVal x) = Just (Total x)
traverse c (ATPlus x y) = do
                            lc <- traverse Empty x
                            rc <- traverse Empty y
                            Just (Total $ (result c + result lc + result rc))


Adder : Language
Adder = MkLang AddContext AddTerm traverse


-- Some proof that it works!
adderFive : AddTerm
adderFive = ATVal 5


adderThree : AddTerm
adderThree = ATVal 3

adderThreePlusFive : AddTerm
adderThreePlusFive = ATPlus adderThree adderFive


adderComplex : AddTerm
adderComplex = ATPlus (ATVal 9) adderThreePlusFive




-- MiniIdris
-- Using code from:
-- https://github.com/edwinb/SPLV20

data PiInf : Type where
     Implicit : PiInf
     Explicit : PiInf


data MIBinder : Type -> Type where
     MILam : PiInf -> ty -> MIBinder ty
     MIPi : PiInf -> ty -> MIBinder ty
     MIPVar : ty -> MIBinder ty
     MIPTy : ty -> MIBinder ty

data MIName : Type where
     UserName : String -> MIName
     MachName : String -> Int -> MIName

data MITerm : Type where
     MIVar : MIName -> MITerm
     MIBind : MIName -> MIBinder MITerm -> MITerm -> MITerm



-- Simply-typed Lambda Calculus


-- Simple Types
data STType : Type where
     STBase : STType
     STArrow : STType -> STType-> STType


-- Lambda Calculus terms
data STTerm : Type where
     STVar : Nat -> STTerm
     STAbs : STTerm -> STTerm
     STApp : STTerm -> STTerm -> STTerm




