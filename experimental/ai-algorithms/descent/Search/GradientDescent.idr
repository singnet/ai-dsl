module Search.GradientDescent

import Data.Matrix
import Search.Descent

-----------------------------
-- Define Gradient Descent --
-----------------------------

||| Convert a gradient into a next function corresponding to a
||| gradient descent with a fixed step size.  Note that the gradient
||| is the actual gradient ascent function, ∇L, the derivative of the
||| loss function L, not the gradient descent.
public export
fixedStepSizeGradientDescent : (Ord a, Neg a) =>
                               (grd : ColVect m a -> ColVect m a) -> -- Gradient
                               (eta : a) ->                          -- Step size
                               ColVect m a -> ColVect m a            -- Next function
fixedStepSizeGradientDescent grd eta cnd = cnd - (scale eta (grd cnd))

||| Specialization of the descent algorithm using the gradient of the
||| cost function to build a next function.  Currently the next
||| function is built using a fixed step size, or learning rate, by
||| moving the candidate towards the gradient descent by a factor of
||| that learning rate.
|||
||| @cost the cost function to evaluate the cost of any candidate
||| @grd the gradient ascent of the cost, that is its derivative
||| @eta the step size factor applied of the gradient descent
||| @cnd the initial candidate
public export
gradientDescent : (Ord a, Neg a) =>
                  (cost : ColVect m a -> a) ->           -- Cost function
                  (grd : ColVect m a -> ColVect m a) ->  -- Gradient
                  (eta : a) ->                           -- Learning rate
                  (cnd : ColVect m a) ->                 -- Initial candidate
                  ColVect m a                            -- Final candidate
gradientDescent cost grd eta = descent cost (fixedStepSizeGradientDescent grd eta)

------------
-- Proofs --
------------

||| Proof that the candidate returned by gradient descent is better or
||| equal to the initial candidate.
|||
||| TODO: add more properties and their proofs, such as
|||
||| 1. check that grd is indeed the derivate of the cost,
||| 2. the gradient of the output candidate is approximatively null,
public export
gradientDescent_le : (Ord a, Neg a) =>
                     (cost : ColVect m a -> a) ->           -- Cost function
                     (grd : ColVect m a -> ColVect m a) ->  -- Gradient
                     (eta : a) ->                           -- Step size
                     (cnd : ColVect m a) ->                 -- Initial candidate
                     ((cost (gradientDescent cost grd eta cnd)) <= (cost cnd)) === True
gradientDescent_le cost grd eta = descent_le cost (fixedStepSizeGradientDescent grd eta)
