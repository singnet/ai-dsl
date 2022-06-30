module Utils

import Language.Reflection.TT
import Language.Reflection.TTImp
import Language.Reflection.Pretty

import public Language.Reflection.Derive

import Data.String

%language ElabReflection


-- simple function
public export
add2 : (Integer) -> Integer
add2 x = x + 2



doAll : Monad m => List (m ()) -> m ()
doAll [] = pure ()
doAll (x :: xs) = do x
                     doAll xs


-- Convert information about a file context's origin into a parsable string
public export
showOrigin : OriginDesc -> String
showOrigin (PhysicalIdrSrc (MkMI mi)) = (foldl (\i => (i ++ " " ++)) "( Physical Idris Source: " mi) ++ " )"
showOrigin (PhysicalPkgSrc fname)     = "( Idris Package Source: " ++ fname ++ " )"
showOrigin (Virtual _)                = "( Virtual Interactive Source )"

-- Describe a file context as a parsable string
public export
showFC : FC -> String
showFC (MkFC o start end) = "( From physical source: " ++ (showOrigin o) ++ " ( Start: " ++ show start ++ " ) (End: " ++ show end ++ " ) )"
showFC (MkVirtualFC o start end) = "( From virtual source: " ++ (showOrigin o) ++ " ( Start: " ++ show start ++ " ) (End: " ++ show end ++ " ) )"
showFC EmptyFC = "( Empty file context )"


public export
showTerm : TTImp -> String
showTerm (IVar fc n) = "( Var: ( Name: " ++ (show n) ++ " ) ( FC: " ++ (showFC fc) ++ " ) )"
showTerm _ = "( unimplemented )"
-- showTerm (IPi fc c z w argTy retTy) = ?showTerm_rhs_1
-- showTerm (ILam x y z w argTy lamTy) = ?showTerm_rhs_2
-- showTerm (ILet x lhsFC y z nTy nVal scope) = ?showTerm_rhs_3
-- showTerm (ICase x y ty xs) = ?showTerm_rhs_4
-- showTerm (ILocal x xs y) = ?showTerm_rhs_5
-- showTerm (IUpdate x xs y) = ?showTerm_rhs_6
-- showTerm (IApp x y z) = ?showTerm_rhs_7
-- showTerm (INamedApp x y z w) = ?showTerm_rhs_8
-- showTerm (IAutoApp x y z) = ?showTerm_rhs_9
-- showTerm (IWithApp x y z) = ?showTerm_rhs_10
-- showTerm (ISearch x depth) = ?showTerm_rhs_11
-- showTerm (IAlternative x y xs) = ?showTerm_rhs_12
-- showTerm (IRewrite x y z) = ?showTerm_rhs_13
-- showTerm (IBindHere x y z) = ?showTerm_rhs_14
-- showTerm (IBindVar x y) = ?showTerm_rhs_15
-- showTerm (IAs x nameFC y z w) = ?showTerm_rhs_16
-- showTerm (IMustUnify x y z) = ?showTerm_rhs_17
-- showTerm (IDelayed x y z) = ?showTerm_rhs_18
-- showTerm (IDelay x y) = ?showTerm_rhs_19
-- showTerm (IForce x y) = ?showTerm_rhs_20
-- showTerm (IQuote x y) = ?showTerm_rhs_21
-- showTerm (IQuoteName x y) = ?showTerm_rhs_22
-- showTerm (IQuoteDecl x xs) = ?showTerm_rhs_23
-- showTerm (IUnquote x y) = ?showTerm_rhs_24
-- showTerm (IPrimVal x c) = ?showTerm_rhs_25
-- showTerm (IType x) = ?showTerm_rhs_26
-- showTerm (IHole x y) = ?showTerm_rhs_27
-- showTerm (Implicit x bindIfUnsolved) = ?showTerm_rhs_28
-- showTerm (IWithUnambigNames x xs y) = ?showTerm_rhs_29




public export
termNameEq : TTImp -> TTImp -> Bool
termNameEq (IVar _ n1) (IVar _ n2) = (show n1) == (show n2)
termNameEq _  _ = False


-- Use the built-in doc conversion
public export
showTermDoc : TTImp -> String
showTermDoc t = show $ (the $ Doc TTImp) $ pretty t



public export
rGetType : List Name -> Elab (List (Name, TTImp))
rGetType []        = do pure []
rGetType (n :: ns) = do matches <- getType n
                        -- doAll $ map (logSugaredTerm "rGetType" 0 "found: ") (map snd matches)
                        -- doAll $ map (\nst => (logMsg "rGetType found: " 0 ((show (fst nst)) ++ " with type \n " ++ (showTerm $ snd nst)))) matches
                        rest <- rGetType ns
                        pure $ matches ++ rest


public export
rGetLocalType : List Name -> Elab (List (Name, TTImp))
rGetLocalType []        = do pure []
rGetLocalType (n :: ns) = do t <- getLocalType n
                             -- logSugaredTerm "rGetLocalType" 0 " found: " t
                             rest <- rGetLocalType ns
                             pure $ (n, t) :: rest


public export
logLocals : Elab ()
logLocals = do names <- localVars
               vs <- rGetType names
               nst <- rGetLocalType names
               doAll $ map (\n => (logMsg "local " 0) ((show (fst n)) ++ " with type \n " ++ (showTerm $ snd n))) nst


public export
logGoal : Elab ()
logGoal = do (Just ty) <- goal | Nothing => logMsg "goal" 0 "No goal found."
             -- logSugaredTerm "goal" 0 "Hole goal:" ty
             logMsg "goal as Doc" 0 ("\n " ++ (showTerm ty))


public export
analyzeHole : Elab ()
analyzeHole = do logLocals
                 logGoal

public export
toType : TTImp -> Elab Type
toType t = do check t





public export
tryLocals : (ty : TTImp) -> Elab (Maybe TTImp)
tryLocals ty = do ns <- localVars
                  nst <- rGetLocalType ns
                  pure $ head' $ map (\nt => IVar EmptyFC (fst nt)) $ filter (\t => termNameEq (snd t) ty) nst



public export
fillNat : Elab Nat
fillNat = do analyzeHole
             check `(Z)

public export
fillAny : Elab ty
fillAny = do analyzeHole
             (Just g) <- goal | Nothing => fail "No goal for fillAny."
             (Just v) <- (tryLocals g) | Nothing => fail "No locals of correct type."
             check v
