-- Prototype of NonDTRealizedFunction as described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e

module NonDTRealizedFunction

import public NonDTRealizedAttributes

public export
record NonDTRealizedFunction a where
  constructor MkNonDTRealizedFunction
  function : a
  attributes : NonDTRealizedAttributes

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
compose : (NonDTRealizedFunction (b -> c)) ->
          (NonDTRealizedFunction (a -> b)) ->
          (NonDTRealizedFunction (a -> c))
compose rlz_f rlz_g = MkNonDTRealizedFunction rlz_fg fg_attrs where
  rlz_fg : a -> c
  rlz_fg = rlz_f.function . rlz_g.function
  fg_attrs : NonDTRealizedAttributes
  fg_attrs = add_costs_min_quality rlz_f.attributes rlz_g.attributes

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : NonDTRealizedFunction (a -> b) -> a -> b
apply rlz_f = rlz_f.function
