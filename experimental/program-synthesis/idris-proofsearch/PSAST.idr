module PSAST

import Data.Vect

-- Represent programs as abstract syntax trees and use Idris proof
-- search functionality to build them as to be consistent with their
-- types, i.e. to perform program synthesis.
--
-- That code is heavily inspired by
-- https://github.com/idris-lang/Idris2/blob/main/samples/Interp.idr

||| Dummy candidate type
data Candidate : Type where
  MkCandidate : Candidate

||| AST types
data Ty = TyDouble | TyCandidate | TyFun Ty Ty

||| Type interpreter
interpTy : Ty -> Type
interpTy TyDouble    = Double
interpTy TyCandidate = Candidate
interpTy (TyFun a t) = interpTy a -> interpTy t

||| Associate variables to types
data HasType : (i : Fin n) -> Vect n Ty -> Ty -> Type where
    Stop : HasType FZ (t :: ctxt) t
    Pop  : HasType k ctxt t -> HasType (FS k) (u :: ctxt) t

||| Abstract Syntax Tree definition.  Operators are very specialized,
||| such as Descent.  The point is just to demonstrate that it works.
data Expr : Vect n Ty -> Ty -> Type where
    DummyCandidate : Expr ctxt TyCandidate
    LinLoss : Expr ctxt (TyFun TyCandidate TyDouble)
    LinGradient : Expr ctxt (TyFun TyCandidate TyCandidate)
    LogLoss : Expr ctxt (TyFun TyCandidate TyDouble)
    LogGradient : Expr ctxt (TyFun TyCandidate TyCandidate)
    Descent : Expr ctxt (TyFun TyCandidate TyDouble) ->     -- Cost function
              Expr ctxt (TyFun TyCandidate TyCandidate) ->  -- Next function
              Expr ctxt TyCandidate ->                      -- Initial candidate
              Expr ctxt TyCandidate                         -- Final candidate

||| Environment, variables and their types
data Env : Vect n Ty -> Type where
    Nil  : Env Nil
    (::) : interpTy a -> Env ctxt -> Env (a :: ctxt)

||| Look up the type of a variable
lookup : HasType i ctxt t -> Env ctxt -> interpTy t
lookup Stop    (x :: xs) = x
lookup (Pop k) (x :: xs) = lookup k xs

||| Interpreter.  Not useful for that experiment.
interp : Env ctxt -> Expr ctxt t -> interpTy t
interp env DummyCandidate = MkCandidate
interp env LinLoss = ?linloss
interp env LinGradient = ?lingrad
interp env LogLoss = ?logloss
interp env LogGradient = ?loggrad
interp env (Descent cost next cnd) = ?descent

||| Idris proof search functionality is able to build the desired program
|||
||| Descent LinLoss LinGradient DummyCandidate
linearRegression : Expr ctxt TyCandidate
linearRegression = ?lr
