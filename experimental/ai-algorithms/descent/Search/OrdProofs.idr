module Search.OrdProofs

--------------------------------------------------------------------------
-- Assumptions/proofs about the Ord interface.  All assumptions/proofs  --
-- are derived from the following hypotheses.                           --
--                                                                      --
-- 1. <= is a total order (i.e. reflexive, transitive, antisymmetric    --
-- and strongly connected)                                              --
--                                                                      --
-- 2. < is the irreflexive kernel of <= (and thus a strict total order) --
--                                                                      --
-- 3. >= is the dual (or converse) of <=                                --
--                                                                      --
-- 4. > is the dual (or converse) of <                                  --
--                                                                      --
-- References:                                                          --
--   https://en.wikipedia.org/wiki/Partially_ordered_set                --
--   https://en.wikipedia.org/wiki/Total_order                          --
--------------------------------------------------------------------------

-- TODO: redefine LT x y as (y < x) === True and use interfaces in
-- Control.Relation and Decidable.Order.Strict

-- TODO: use Not ((y < x) === True) instead of (y < x) === False

-- TODO: use Total defined Stefan Hoek idris2-prim package.

-- TODO: To guaranty the axioms are met one may use an arbitrary
-- precision library such as
-- https://github.com/jumper149/idris2-scientific

||| Proof that < is irreflexive (not generally true, assumed)
public export
lt_irreflexive : Ord a => {0 x : a} -> (x < x) === False
lt_irreflexive = believe_me ()

||| Proof that < is asymmetric (not generally true, assumed)
public export
lt_asymmetric : Ord a => {0 x, y : a} -> (x < y) === True -> (y < x) === False
lt_asymmetric _ = believe_me ()

||| Proof that < is connected (not generally true, assumed)
public export
lt_connected : Ord a => {0 x, y : a}
                     -> (x < y) === False
                     -> (y < x) === False
                     -> x === y
lt_connected _ _ = believe_me ()

||| Proof that <= is reflexive (maybe not generally true, assumed)
public export
le_reflexive : Ord a => {0 x : a} -> (x <= x) === True
le_reflexive = believe_me ()

||| Proof that <= is transitive (not generally true, assumed)
public export
le_transitive : Ord a => {0 x, y, z : a}
                      -> (x <= y) === True
                      -> (y <= z) === True
                      -> (x <= z) === True
le_transitive _ _ = believe_me ()

||| Proof that <= is the reflexive closure of < (or conversely that <
||| is the irreflexive kernel of <=).  Not generally true, assumed.
public export
le_reflexive_closure_lt : Ord a => {0 x, y : a}
                                -> Either ((x < y) === True) (x === y)
                                -> (x <= y) === True
le_reflexive_closure_lt _ = believe_me ()

||| Proof that <= is the complement of the converse of < (not
||| generally true, assumed for now)
public export
le_converse_complement : Ord a => {0 x, y : a}
                               -> {0 b : Bool}
                               -> (x < y) === b
                               -> (y <= x) === not b
le_converse_complement _ = believe_me ()

||| Proof that <= is strongly connected (not generally true, assumed)
public export
le_strongly_connected : Ord a => {0 x, y : a}
                              -> Either ((x <= y) === True) ((y <= x) === True)
le_strongly_connected = believe_me ()

||| Implicative form that <= is strongly connected (not generally
||| true, assumed).  This can perhaps be inferred from
||| le_strongly_connected.
public export
le_strongly_connected_imp : Ord a => {0 x, y : a}
                                  -> (x <= y) === False
                                  -> (y <= x) === True
le_strongly_connected_imp _ = believe_me ()
