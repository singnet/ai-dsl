module Search.GradientDescent

import Data.DPair
import Debug.Trace
import Data.Matrix
import Search.Descent
import Search.OrdProofs

-----------------------------
-- Define Gradient Descent --
-----------------------------

||| Convert a gradient into a step function corresponding to a
||| gradient descent with a fixed step size.  Note that the gradient
||| is the actual gradient ascent function, ∇L, the derivative of the
||| loss function L, not the gradient descent.
public export
fixedStepSizeGD : (Ord a, Neg a) =>
                  (grd : ColVect n a -> ColVect n a) -> -- Gradient
                  (eta : a) ->                          -- Step size
                  ColVect n a -> ColVect n a            -- Step function
fixedStepSizeGD grd eta cnd = cnd - (scale eta (grd cnd))

||| Specialization of the descent algorithm using the gradient of the
||| cost function to build a step function.  Currently the step
||| function is built using a fixed step size, or learning rate, by
||| moving the candidate towards the gradient descent by a factor of
||| that learning rate.
|||
||| @cost the cost function to evaluate the cost of any candidate
||| @grd the gradient ascent of the cost, that is its derivative
||| @eta the step size factor applied of the gradient descent
||| @cnd the initial candidate
||| @maxsteps maximum number of steps allocated
public export
gradientDescent : (Ord a, Neg a) =>
                  (cost : ColVect n a -> a) ->          -- Cost function
                  (grd : ColVect n a -> ColVect n a) -> -- Gradient
                  (eta : a) ->                          -- Learning rate
                  (cas : (ColVect n a, Nat)) ->         -- Initial candidate and allocated steps
                  (ColVect n a, Nat)                    -- Final candidate and steps left
gradientDescent cost grd eta = descent cost (fixedStepSizeGD grd eta)

-----------
-- Proof --
-----------

||| Proof that the candidate returned by gradient descent is better or
||| equal to the initial candidate.
|||
||| TODO: add more properties and their proofs, such as
|||
||| 1. check that grd is indeed the derivate of the cost,
||| 2. the gradient of the output candidate is approximatively null,
public export
gradientDescent_le : (Ord a, Neg a) =>
                     (cost : ColVect n a -> a) ->           -- Cost function
                     (grd : ColVect n a -> ColVect n a) ->  -- Gradient
                     (eta : a) ->                           -- Step size
                     (cas : (ColVect n a, Nat)) ->          -- Initial candidate and allocated steps
                     ((cost (fst (gradientDescent cost grd eta cas))) <= (cost (fst cas))) === True
gradientDescent_le cost grd eta = descent_le cost (fixedStepSizeGD grd eta)

---------------------------
-- Definition with Proof --
---------------------------

||| Helper to define the descending property for gradient descent
public export
descendingPropertyGD : (Ord a, Neg a) =>
                       (cost : ColVect n a -> a) ->          -- Cost function
                       (grd : ColVect n a -> ColVect n a) -> -- Gradient
                       (eta : a) ->                          -- Learning rate
                       (cas : (ColVect n a, Nat)) ->         -- Init candidate and steps
                       (res : (ColVect n a, Nat)) ->         -- Final candidate and steps
                       Type
descendingPropertyGD cost grd eta = descendingProperty cost (fixedStepSizeGD grd eta)

||| Move the descending proposition in the type signature, and its
||| proof in the program, using a dependent pair.
gradientDescentDPair : (Ord a, Neg a) =>
                       (cost : ColVect n a -> a) ->          -- Cost function
                       (grd : ColVect n a -> ColVect n a) -> -- Gradient
                       (eta : a) ->                          -- Learning rate
                       (cas : (ColVect n a, Nat)) ->         -- Init candidate and steps
                       (res : (ColVect n a, Nat) ** descendingPropertyGD cost grd eta cas res)
gradientDescentDPair cost grd eta cas =
  (gradientDescent cost grd eta cas ** gradientDescent_le cost grd eta cas)

||| Like gradientDescentDPair, but using Subset instead of a dependent
||| pair.
gradientDescentSubset : (Ord a, Neg a) =>
                        (cost : ColVect n a -> a) ->          -- Cost function
                        (grd : ColVect n a -> ColVect n a) -> -- Gradient
                        (eta : a) ->                          -- Learning rate
                        (cas : (ColVect n a, Nat)) ->         -- Init candidate and steps
                        Subset (ColVect n a, Nat) (descendingPropertyGD cost grd eta cas)
gradientDescentSubset cost grd eta cas =
  Element (gradientDescent cost grd eta cas) (gradientDescent_le cost grd eta cas)

-- TODO: simplify the code above by using a composer of type:
--
-- (c -> d -> e) -> (a -> c) -> (b -> d) -> a -> b -> e
--
-- Likely this can be implement with bimap, as in
--
-- :let uncurryBimap : (a' -> b' -> c) -> (a -> a') -> (b -> b') -> (a, b) -> c
-- :let uncurryBimap f g h = uncurry f . bimap g h

---------------
-- Synthesis --
---------------

-- NEXT: Try to synthesize
-- 1. gradientDescent cost grd eta cas
-- 2. Element (gradientDescent cost grd eta cas) (gradientDescent_le cost grd eta cas)
-- 3. same as 1. using descent
-- 4. same as 2. using descent_le

||| Attempt to synthesize
|||
||| dsnt cost (grd2stp grd eta) cas
|||
||| via Idris proof search.  Fails so far because it uses the gradient
||| as step function, instead of building the step function with
||| grd2stp.
synGD : (Ord a, Neg a) =>
        (dsnt : (ColVect n a -> a) -> (ColVect n a -> ColVect n a) -> (ColVect n a, Nat) -> (ColVect n a, Nat)) -> -- Descent
        (grd2stp : (ColVect n a -> ColVect n a) -> (eta : a) -> ColVect n a -> ColVect n a) -> -- Gradient to Step
        (grd : ColVect n a -> ColVect n a) -> -- Gradient
        (eta : a) ->                          -- Learning rate
        (cost : ColVect n a -> a) ->          -- Cost function
        (cas : (ColVect n a, Nat)) ->         -- Initial candidate and allocated steps
        (ColVect n a, Nat)                    -- Final candidate and steps left
synGD dsnt grd2stp grd eta cost cas = ?synGD_rhs
