module Descent

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
|||
||| TODO: explore returning the whole trace.
|||
||| TODO: support backtracking (trace is a tree instead of a vector)
||| (look at sorted tree).
descent_rec : Ord cost_t => cnd_t -> cost_t -> (cnd_t -> cost_t) -> (cnd_t -> cnd_t) -> cnd_t
descent_rec cnd cst cstfn nxtfn =
  if nxtcst < cst then descent_rec nxtcnd nxtcst cstfn nxtfn
                  else cnd
  where
    -- Next candidate
    nxtcnd : cnd_t
    nxtcnd = nxtfn cnd
    -- Cost over next candidate
    nxtcst : cost_t
    nxtcst = cstfn nxtcnd

descent : Ord cost_t => cnd_t -> (cnd_t -> cost_t) -> (cnd_t -> cnd_t) -> cnd_t
descent cnd cstfn nxtfn = descent_rec cnd (cstfn cnd) cstfn nxtfn
