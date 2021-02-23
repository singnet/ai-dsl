-- Prototype of NonDTRealizedAttributes as described in
-- https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e

module NonDTRealizedAttributes

public export
CostT : Type
CostT = Double

public export
record Costs where
  constructor MkCosts
  financial, temporal, computational : CostT

public export
QualityT : Type
QualityT = Double

public export
record NonDTRealizedAttributes where
  constructor MkNonDTRealizedAttributes
  costs : Costs
  quality : QualityT

-- Add costs
public export
add_costs : Costs -> Costs -> Costs
add_costs x y = MkCosts (x.financial + y.financial)
                        (x.temporal + y.temporal)
                        (x.computational + y.computational)

-- Add costs, minimum quality
public export
add_costs_min_quality : NonDTRealizedAttributes ->
                        NonDTRealizedAttributes ->
                        NonDTRealizedAttributes
add_costs_min_quality f_attrs g_attrs = fg_attrs where
  fg_attrs : NonDTRealizedAttributes
  fg_attrs = MkNonDTRealizedAttributes (add_costs f_attrs.costs g_attrs.costs)
                                       (min f_attrs.quality g_attrs.quality)
