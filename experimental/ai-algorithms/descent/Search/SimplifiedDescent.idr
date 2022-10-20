module Search.SimplifiedDescent

import Search.Util
import Search.OrdProofs
import Debug.Trace

-- Simplified version of descent and its proof found the report of
-- October 2022.

descent : Ord cost_t =>
          (cnd_t -> cost_t) ->    -- Cost function
          (cnd_t -> cnd_t) ->     -- Step function
          (cnd_t, Nat) ->         -- Init candidate, steps
          (cnd_t, Nat)            -- Final candidate, steps
descent _ _ (cnd, Z) = (cnd, Z)
descent cost next (cnd, S k) = if cost (next cnd) < cost cnd
                               then descent cost next (next cnd, k)
                               else (cnd, (S k))

descent_le : Ord cost_t =>
             (cost : cnd_t -> cost_t) -> -- Cost function
             (next : cnd_t -> cnd_t) ->  -- Step function
             (cas : (cnd_t, Nat)) ->     -- Init candidate, steps
  (cost (fst (descent cost next cas)) <= cost (fst cas)) === True
descent_le _ _ (_, Z) = le_reflexive
descent_le cost next (cnd, S k)
           with ((cost (next cnd)) < (cost cnd)) proof eq
  _ | True = let des_le_nxtcst = descent_le cost next (next cnd, k)
                 nxtcst_le_cst = le_reflexive_closure_lt (Left eq)
              in le_transitive des_le_nxtcst nxtcst_le_cst
  _ | False = le_reflexive
