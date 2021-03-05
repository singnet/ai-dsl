-- Prototype of RealizedFunction as described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e
--
-- This is similar to SimpleDataRealizedFunction but the attributes
-- are wrapped in RealizedAttributes.

module RealizedFunction

import public RealizedAttributes

public export
data RealizedFunction : (t : Type) -> (attrs : RealizedAttributes) -> Type where
  MkRealizedFunction : (f : t) -> (attrs : RealizedAttributes)
                       -> RealizedFunction t attrs

-- Perform the composition between 2 realized functions.  The
-- resulting realized function is formed as follows:
--
-- 1. Composed lifted functions
-- 2. Use add_costs_min_quality for composing attributes
public export
compose : {a : Type} -> {b : Type} -> {c : Type} ->
          (RealizedFunction (b -> c) g_attrs) ->
          (RealizedFunction (a -> b) f_attrs) ->
          (RealizedFunction (a -> c) (add_costs_min_quality f_attrs g_attrs))
compose (MkRealizedFunction f f_attrs) (MkRealizedFunction g g_attrs) =
  MkRealizedFunction (f . g) (add_costs_min_quality f_attrs g_attrs)

-- Perform function application over realized functions.  Maybe we'd
-- want to used some funded data, as defined in FndType.
public export
apply : (RealizedFunction (a -> b) attrs) -> a -> b
apply (MkRealizedFunction f attrs) = f
