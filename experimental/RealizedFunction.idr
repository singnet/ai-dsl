-- Prototype of RealizedFunction as described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e

module RealizedFunction

import public RealizedAttributes

public export
record RealizedFunction a where
  constructor MkRealizedFunction
  function : a
  attributes : RealizedAttributes

-- Perform the composition between 2 realized functions.  The
-- resulting realized function is formed as follows:
--
-- 1. Composed lifted functions
-- 2. Costs are added
-- 3. Minimum quality is retained
--
-- For now only the IO types of the functions are dependent types, not
-- the attribtes.
public export
compose : (RealizedFunction (b -> c)) ->
          (RealizedFunction (a -> b)) ->
          (RealizedFunction (a -> c))
compose rlz_f rlz_g = MkRealizedFunction rlz_fg fg_attrs where
  rlz_fg : a -> c
  rlz_fg = rlz_f.function . rlz_g.function
  fg_attrs : RealizedAttributes
  fg_attrs = add_costs_min_quality rlz_f.attributes rlz_g.attributes

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : RealizedFunction (a -> b) -> a -> b
apply rlz_f = rlz_f.function
