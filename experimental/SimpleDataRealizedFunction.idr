-- Like SimpleRealizedFunction but uses data instead of record

module SimpleDataRealizedFunction
%default total

public export
data SimpleDataRealizedFunction : (t : Type) -> (cost : Integer) -> (quality : Double)
                                  -> Type where
  MkSimpleDataRealizedFunction : (f : t) -> (cost : Integer) -> (quality : Double)
                                 -> SimpleDataRealizedFunction t cost quality

-- Perform the composition between 2 simple realized functions.  The
-- resulting realized function is formed as follows:
--
-- 1. Composed lifted functions
-- 2. Costs are added
-- 3. Composed quality is the min of the component qualities
public export
compose : {a : Type} -> {b : Type} -> {c : Type} ->
          (SimpleDataRealizedFunction (b -> c) g_cost g_q) ->
          (SimpleDataRealizedFunction (a -> b) f_cost f_q) ->
          (SimpleDataRealizedFunction (a -> c) (f_cost + g_cost) (min f_q g_q))
compose (MkSimpleDataRealizedFunction f f_cost f_q) (MkSimpleDataRealizedFunction g g_cost g_q) =
         MkSimpleDataRealizedFunction (f . g) (g_cost + f_cost) (min g_q f_q)

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : (SimpleDataRealizedFunction (a -> b) cost quality) -> a -> b
apply (MkSimpleDataRealizedFunction f cost quality) = f
