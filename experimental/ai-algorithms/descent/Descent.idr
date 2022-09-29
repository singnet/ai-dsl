module Descent

import OrdProofs

||| Descent algorithm, attempts to find the best candidate minimizing
||| a cost function.
|||
||| Takes in arguments:
|||
||| 1. `cnd`, an initial candidate to start the search from.
|||
||| 2. `cost`, a cost function that evaluates the cost of any given
||| candidate.
|||
||| 3. `next`, a search step function that given a candidate returns
||| another (supposedly better) candidate.  To do well such function
||| should take and return a search state, but for now it is
||| stateless.
|||
||| Returns a candidate that is as good as or better than `cnd`.
|||
||| For now the descent algorithm merely iteratively calls the search
||| function as long as the cost function over its output is lower.
descent_rec : Ord cost_t =>
              (cnd_t -> cost_t) -> -- Cost function
              (cnd_t -> cnd_t) ->  -- Next function to jump to the next candidate
              (cnd_t, cost_t) ->   -- Input pair of candidate and its cost
              (cnd_t, cost_t)      -- Output pair of candidate and its cost
descent_rec cost next (cnd, cst) =
  if nxtcst < cst then descent_rec cost next (nxtcnd, nxtcst)
                  else (cnd, cst)
  where
    -- Next candidate
    nxtcnd : cnd_t
    nxtcnd = next cnd
    -- Cost over next candidate
    nxtcst : cost_t
    nxtcst = cost nxtcnd

public export
descent : Ord cost_t =>
          (cnd_t -> cost_t) ->  -- Cost function
          (cnd_t -> cnd_t) ->   -- Next function
          cnd_t ->              -- Input candidate
          cnd_t                 -- Output candidate
descent cost next cnd = fst (descent_rec cost next (cnd, cost cnd))

-- TODO: Explore returning the whole trace.

-- TODO: Support backtracking (trace is a tree instead of a vector)
-- (look at sorted tree).

-- TODO: Use that delta between costs of cnd and nxtcnd is within an
-- epsilon as stopping point.

-- TODO: Prove that next is pointing to the right (or the best)
-- direction.

-- TODO: Altough the proves are correct, it is somewhat incomplete
-- since it is not proven that descent is total (cause it is not, it
-- may descend forever).  One way, suggested by Sam, to prove that it
-- is total would be to prove that cost_t is well-founded, so that if
-- next goes down, it will eventually bottom down to base cases.  See
-- https://en.wikipedia.org/wiki/Well-founded_relation for more
-- information, as well as Stefan Hoek Well-founded Recursion example
-- in idris2-prim.

--------------------------
-- Proofs about descent --
--------------------------

||| Proof that the output candidate of descent_rec has a cost less
||| than or equal to the cost of the input candidate.
|||
||| The simplicity of the proof of descent_rec_le is due to the case
||| base approach which allows Idris to partially evaluate descent_rec.
||| This partial evaluation is then reflected inside the target
||| theorem.  For instance if
|||
||| ((cost (next cnd)) < cst) === False
|||
||| the target theorem
|||
||| ((snd (descent_rec cost next cndcst)) <= (snd cndcst)) === True
|||
||| gets reduced to
|||
||| (snd cndcst) <= (snd cndcst)
|||
||| which merely requires the axiom of reflexivity of <=.
|||
||| Likewise if
|||
||| ((cost (next cnd) < cst)) === True
|||
||| the target theorem
|||
||| ((snd (descent_rec cost next (cnd, cst))) <= (snd (cnd, cst))) === True
|||
||| gets reduced to
|||
||| ((snd (descent_rec cost next (next cnd, cost (next cnd)))) <= cst) === True
|||
||| which then merely requires to apply the transitivity axiom of <=
||| over the recursive theorem
|||
||| ((snd (descent_rec cost next (next cnd, cost (next cnd)))) <= cost (next cnd)) === True
|||
||| and
|||
||| (cost (next cnd) <= cst) === True
|||
||| which is obtained as the reflexive closure of <= over the
||| hypothesis.
descent_rec_le : Ord cost_t =>
                 (cost : cnd_t -> cost_t) ->  -- Cost function
                 (next : cnd_t -> cnd_t) ->   -- Next function
                 (cndcst : (cnd_t, cost_t)) -> -- Input pair of candidate and its cost
                 ((snd (descent_rec cost next cndcst)) <= (snd cndcst)) === True
descent_rec_le cost next (cnd, cst) with ((cost (next cnd)) < cst) proof eq
  _ | True = let des_le_nxtcst = descent_rec_le cost next (next cnd, (cost (next cnd)))
                 nxtcst_le_cst = le_reflexive_closure_lt (Left eq)
              in (le_transitive des_le_nxtcst nxtcst_le_cst)
  _ | False = le_reflexive

||| Proof that
|||
||| cost (descent cost next cnd) = snd (descent_rec cost next (cnd, cost cnd))
|||
||| This is used by descent_le to get passed
|||
|||        (snd (descent_rec cost next (cnd, cost cnd)) <= cost cnd) === True
||| ->
||| (cost (fst (descent_rec cost next (cnd, cost cnd))) <= cost cnd) === True
cd_eq_sdr : Ord cost_t =>
            (cost : cnd_t -> cost_t) ->  -- Cost function
            (next : cnd_t -> cnd_t) ->   -- Next function
            (cnd : cnd_t) ->              -- Input candidate
            (cost (descent cost next cnd)) === snd (descent_rec cost next (cnd, cost cnd))
cd_eq_sdr cost next cnd with ((cost (next cnd)) < (cost cnd)) proof eq
  _ | True = cd_eq_sdr cost next (next cnd)
  _ | False = Refl

||| Proof that the output candidate of descent has a cost less than or
||| equal to the cost of the input candidate.
|||
||| The target theorem
|||
||| ((cost (descent cost next cnd)) <= (cost cnd)) === True
|||
||| gets reduced to
|||
||| ((cost (fst (descent_rec cost next (cnd, cost cnd)))) <= (cost cnd)) === True
|||
||| by virtue of the definition of descent.
public export
descent_le : Ord cost_t =>
             (cost : cnd_t -> cost_t) ->  -- Cost function
             (next : cnd_t -> cnd_t) ->   -- Next function
             (cnd : cnd_t) ->              -- Input candidate
             ((cost (descent cost next cnd)) <= (cost cnd)) === True
descent_le cost next cnd = rewrite (cd_eq_sdr cost next cnd)
                           in (descent_rec_le cost next (cnd, cost cnd))
