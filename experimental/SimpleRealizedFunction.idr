-- Prototype of RealizedFunction as described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e

-- List RealizedFunction but only has one attribute which is cost
module SimpleRealizedFunction

public export
record SimpleRealizedFunction f (cost : Integer) (quality : Double) where
  constructor MkSimpleRealizedFunction
  function : f

-- Perform the composition between 2 simple realized functions.  The
-- resulting realized function is formed as follows:
--
-- 1. Composed lifted functions
-- 2. Costs are added
public export
compose : (SimpleRealizedFunction (b -> c) g_cost g_q) ->
          (SimpleRealizedFunction (a -> b) f_cost f_q) ->
          (SimpleRealizedFunction (a -> c) (f_cost + g_cost) (min f_q g_q))
compose rlz_g rlz_f = MkSimpleRealizedFunction rlz_fg where
  rlz_fg : a -> c
  rlz_fg = rlz_g.function . rlz_f.function

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : (SimpleRealizedFunction (a -> b) cost quality) -> a -> b
apply rlz_f = rlz_f.function
