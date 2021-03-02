-- Like SimpleRealizedFunction but uses data instead of record

module SimpleDataRealizedFunction

public export
data SimpleDataRealizedFunction : (a -> b) -> (cost : Integer) -> (quality : Double)
                                  -> Type where
  MkSimpleDataRealizedFunction : (f : a -> b) -> (cost : Integer) -> (quality : Double)
                                 -> SimpleDataRealizedFunction f cost quality

-- Perform the composition between 2 simple realized functions.  The
-- resulting realized function is formed as follows:
--
-- 1. Composed lifted functions
-- 2. Costs are added
-- public export
-- compose : (SimpleDataRealizedFunction (b -> c) g_cost g_q) ->
--           (SimpleDataRealizedFunction (a -> b) f_cost f_q) ->
--           (SimpleDataRealizedFunction (a -> c) (f_cost + g_cost) (min f_q g_q))
public export
compose : (SimpleDataRealizedFunction (b -> c) g_cost g_q) ->
          (SimpleDataRealizedFunction (a -> b) f_cost f_q) ->
          (SimpleDataRealizedFunction (a -> c) (f_cost + g_cost) (min f_q g_q))
compose (MkSimpleDataRealizedFunction f) (MkSimpleDataRealizedFunction g) =
  MkSimpleDataRealizedFunction (f . g)

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : (SimpleDataRealizedFunction (a -> b) cost quality) -> a -> b
apply (MkSimpleDataRealizedFunction f) = f
