module Descent

import OrdProofs

import Data.Vect

||| Descent algorithm, attempts to find the best candidate minimizing
||| a cost function.
|||
||| Takes in arguments:
|||
||| 1. `cnd`, an initial candidate to start the search from.
|||
||| 2. `cstfn`, a cost function that evaluates the cost of any given
||| candidate.
|||
||| 3. `nxtfn`, a search step function that given a candidate returns
||| another (supposedly better) candidate.  To do well such function
||| should take and return a search state, but for now it is
||| stateless.
|||
||| Returns a candidate that is as good as or better than `cnd`.
|||
||| For now the descent algorithm merely iteratively calls the search
||| function as long as the cost function over its output is lower.
descent_rec : Ord cost_t =>
              (cnd_t, cost_t) ->   -- Input pair of candidate and its cost
              (cnd_t -> cost_t) -> -- Cost function
              (cnd_t -> cnd_t) ->  -- Next function to jump to the next candidate
              (cnd_t, cost_t)      -- Output pair of candidate and its cost
-- NEXT.1: replace nxtcst < cst by not (nxtcst >= cst) and see if Idris can still handle descent_rec_le_prf
descent_rec (cnd, cst) cstfn nxtfn =
  if nxtcst < cst then descent_rec (nxtcnd, nxtcst) cstfn nxtfn
                  else (cnd, cst)
  where
    -- Next candidate
    nxtcnd : cnd_t
    nxtcnd = nxtfn cnd
    -- Cost over next candidate
    nxtcst : cost_t
    nxtcst = cstfn nxtcnd

descent : Ord cost_t =>
          cnd_t ->              -- Input candidate
          (cnd_t -> cost_t) ->  -- Cost function
          (cnd_t -> cnd_t) ->   -- Next function
          cnd_t                 -- Output candidate
descent cnd cstfn nxtfn = fst (descent_rec (cnd, cstfn cnd) cstfn nxtfn)

-- TODO: explore returning the whole trace.

-- TODO: support backtracking (trace is a tree instead of a vector)
-- (look at sorted tree).

--------------------------
-- Proofs about descent --
--------------------------

-- NEXT.2: prove that
-- 1. descent_rec (cnd, cst) cstfn nxtfn === descent_rec (nxtfn cnd, (cstfn (nxtfn cnd))) cstfn nxtfn
-- 2. or descent_rec (cnd, cst) cstfn nxtfn === (cnd, cst)

||| Proof that the output candidate of descent_rec has a cost less
||| than or equal to the cost of the input candidate.
descent_rec_le_prf : Ord cost_t =>
                     (cndcst : (cnd_t, cost_t)) -> -- Input pair of candidate and its cost
                     (cstfn : cnd_t -> cost_t) ->  -- Cost function
                     (nxtfn : cnd_t -> cnd_t) ->   -- Next function
                     -- Property expressing that the output candidate
                     -- is equal to or better than the input candidate
                     (snd (descent_rec cndcst cstfn nxtfn)) <= (snd cndcst) = True
descent_rec_le_prf (cnd, cst) cstfn nxtfn with ((cstfn (nxtfn cnd)) < cst) proof eq
  _ | True = ?h1 (le_transitive_prf des_le_nxtcst nxtcst_le_cst)
             where des_le_nxtcst : (snd (descent_rec (cnd, cst) cstfn nxtfn)) <= (cstfn (nxtfn cnd)) = True
                   des_le_nxtcst = ?h2 (descent_rec_le_prf (nxtfn cnd, (cstfn (nxtfn cnd))) cstfn nxtfn)
                   nxtcst_le_cst : (cstfn (nxtfn cnd)) <= cst = True
                   nxtcst_le_cst = le_reflexive_closure_lt_prf (Left eq)
  _ | False = le_reflexive_prf  -- x <= x

||| Proof that the output candidate of descent has a cost less than or
||| equal to the cost of the input candidate.
descent_le_prf : Ord cost_t =>
                 (cnd : cnd_t) ->              -- Input candidate
                 (cstfn : cnd_t -> cost_t) ->  -- Cost function
                 (nxtfn : cnd_t -> cnd_t) ->   -- Next function
                 -- Property expressing that the output candidate is
                 -- equal to or better than the input candidate
                 (cstfn (descent cnd cstfn nxtfn)) <= (cstfn cnd) = True
descent_le_prf cnd cstfn nxtfn = ?h3 -- NEXT.1: fill ?h3
