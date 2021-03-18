-- Small (and obsolete) prototype of a cost-based computational
-- eDLS. Each operation has a cost. Functions take a lifted type,
-- FndType, that includes a fund. The output type of each lifted
-- operation contains the remaining fund after the operation.  It is
-- planned to be replaced by function realization described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e
-- but is kept here for future references.

module FndType

-- Funded type
public export
data FndType : Nat -> Type -> Type where
  FT : {fund : Nat} -> (datum : a) -> (FndType fund a)

-- Overload show for FndType
export
show : (FndType fund Int) -> String
show (FT datum) = "FT " ++ (show fund) ++ " " ++ (show datum)

-- Fund accessor
export
getFund : (FndType fund a) -> Nat
getFund (FT datum) = fund

-- Datum accessor
export
getDatum : (FndType fund a) -> a
getDatum (FT datum) = datum

-- Uplift function as to use FndType, with cost of 1.
export
upliftFun : {fund : Nat} -> {cost : Nat} -> (a -> b) -> (FndType (cost + fund) a) -> (FndType fund b)
upliftFun f = (\x => (FT (f (getDatum x))))

-- Downlift function as to run over datum rather than FndType.
export
downliftFun : {infund : Nat} -> ((FndType infund a) -> (FndType outfund b)) -> a -> b
downliftFun f = (\x => (getDatum (f (FT x))))

-- Lifted composition. Takes 2 filted functions and compose them
export
compose : ((FndType fund_b b) -> (FndType fund_c c))
        -> ((FndType fund_a a) -> (FndType fund_b b))
        -> (FndType fund_a a) -> (FndType fund_c c)
compose f g = (\x => (f (g x)))
