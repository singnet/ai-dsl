module Search.Regression.Linear

import System.Random
import Data.String
import Data.DPair
import Data.Vect
import Data.Matrix
import Search.GradientDescent
import Search.Util

------------------------------
-- Define Linear Regression --
------------------------------

-- Multivariate Linear Regression
--
-- 1. The data set is stored in a pair of
--
--    a. Matrix Xₘₙ = (xᵢⱼ) where 1≤i≤m, the row index, represents the
--       input of the iᵗʰ sample, and 1≤j≤n, the column index,
--       represents the value associated to the jᵗʰ variable.  Thus
--       the matrix represents a data set of sample size m, with n
--       input variables.  Often the matrix is augmented with a first
--       or last column filled with ones to simulate a bias term, also
--       called y-intercept, in the linear model.
--
--    b. Column vector Y = (yᵢ) where 1≤i≤m, the row index, represents
--       the output of iᵗʰ sample.
--
-- 2. The model is stored in a column vector β = (βⱼ) where 1≤j≤n, the
--    row index, represents the weight associated to the jᵗʰ variable.
--
-- According to [1], given the loss function to minimize
--
-- L(β) = ||Y-Xβ||²
--
-- the gradient is obtained as follows
--
-- ∇L(β) = -2Xᵀ(Y-Xβ)
--
-- Thus, given a learning rate 0<η, the model is updated as follows
-- (subtracting the gradient ascent to become a gradient descent):
--
-- β ← β - η∇L(β)
--
-- or
--
-- β ← β + 2ηXᵀ(Y-Xβ)
--
-- [1] Alexander Dekhtyar, Advance Data Mining, Gradient Descent, 2017,
--     http://users.csc.calpoly.edu/~dekhtyar/566-Spring2017/lectures/lec07.566.pdf

||| Sum of squared errors
public export
sse : (e : ColVect m Double) -> Double
sse e = let ev = Data.Vect.concat e.vects
        -- NEXT: let ev = Matrix.Cast.cast e
        in dot ev ev

||| Loss function: L(β) = ||Y-Xβ||²
public export
linLoss : (x : Matrix m n Double) ->
          (y : ColVect m Double) ->
          (beta : ColVect n Double) ->
          Double
linLoss x y beta = sse (y - (x * beta))

||| Gradient: ∇L(β) = -2Xᵀ(Y-Xβ)
public export
linGradient : {n : Nat} ->
              (x : Matrix m n Double) ->
              (y : ColVect m Double) ->
              (beta : ColVect n Double) ->
              ColVect n Double
linGradient x y beta = scale (-2) ((transpose x) * (y - (x * beta)))

||| Multivariate Linear Regression.  Given an input data set x and its
||| corresponding output y, a learning rate eta and initial model
||| beta, return a model β' so that x*β' approximates y.  The returned
||| model is discovered using gradient descent.
|||
||| @x Matrix of size m*n, samples size m, n input variables
||| @y Column vector of size m
||| @eta learning rate, small positive value
||| @bst initial model, column vector of n parameters, and steps allocated
public export
linearRegression : {n : Nat} ->
                   (x : Matrix m n Double) ->
                   (y : ColVect m Double) ->
                   (eta : Double) ->
                   (bst : (ColVect n Double, Nat)) ->
                   (ColVect n Double, Nat)
linearRegression x y = gradientDescent (linLoss x y) (linGradient x y)

-----------
-- Proof --
-----------

||| Proof that the candidate returned by linear regression is better
||| or equal to the initial candidate.
|||
||| TODO: add more properties and proofs pertaining to
|||
||| 1. global optimality, if any,
||| 2. linearity of the model,
||| 3. sse-ness of the cost function,
||| 4. gradient-ness of the step function, and more.
public export
linearRegression_le : {n : Nat} ->
            (x : Matrix m n Double) ->
            (y : ColVect m Double) ->
            (eta : Double) ->
            (bst : (ColVect n Double, Nat)) ->
            ((linLoss x y (fst (linearRegression x y eta bst))) <=
             (linLoss x y (fst bst))) === True
linearRegression_le x y = gradientDescent_le (linLoss x y) (linGradient x y)

---------------------------
-- Definition with Proof --
---------------------------

||| Helper to define the descending property for linear regression
public export
descendingPropertyLR : (n : Nat) ->
                       (x : Matrix m n Double) ->
                       (y : ColVect m Double) ->
                       (eta : Double) ->
                       (bst : (ColVect n Double, Nat)) ->
                       (res : (ColVect n Double, Nat)) ->
                       Type
descendingPropertyLR n x y eta bst res =
  ((linLoss x y (fst res)) <= (linLoss x y (fst bst))) === True

||| Move the descending proposition in the type signature, and its
||| proof in the program, using a dependent pair.
linearRegressionDPair : (n : Nat) ->
                        (x : Matrix m n Double) ->
                        (y : ColVect m Double) ->
                        (eta : Double) ->
                        (bst : (ColVect n Double, Nat)) ->
                        (res : (ColVect n Double, Nat) ** descendingPropertyLR n x y eta bst res)
linearRegressionDPair n x y eta bst =
  (linearRegression x y eta bst ** linearRegression_le x y eta bst)

||| Like linearRegressionDPair, but using Subset instead of a
||| dependent pair.
linearRegressionSubset : (n : Nat) ->
                         (x : Matrix m n Double) ->
                         (y : ColVect m Double) ->
                         (eta : Double) ->
                         (bst : (ColVect n Double, Nat)) ->
                         Subset (ColVect n Double, Nat) (descendingPropertyLR n x y eta bst)
linearRegressionSubset n x y eta bst =
  Element (linearRegression x y eta bst) (linearRegression_le x y eta bst)

---------------
-- Synthesis --
---------------

synLR : (loss_xy : cnd_t -> cst_t) ->
        (grd_xy : cnd_t -> cnd_t) ->
        (grdsnt : (cnd_t -> cst_t) -> (cnd_t -> cnd_t) -> cnd_t -> cnd_t) ->
        (cnd : cnd_t) ->
        cnd_t
synLR loss_xy grd_xy grdsnt cnd = ?synLR_rhs -- grdsnt loss_xy grd_xy cnd

synLRP : Ord cst_t =>
         (loss_xy : cnd_t -> cst_t) ->
         (grd_xy : cnd_t -> cnd_t) ->
         (grdsnt : (cnd_t -> cst_t) -> (cnd_t -> cnd_t) -> cnd_t -> cnd_t) ->
         (cnd : cnd_t) ->
         (prf : ((loss_xy (grdsnt loss_xy grd_xy cnd)) <= (loss_xy cnd)) === True) ->
         (res : cnd_t ** ((loss_xy res) <= (loss_xy cnd)) === True)
synLRP loss_xy grd_xy grdsnt cnd prf = ?synLRP_rhs -- (grdsnt loss_xy grd_xy cnd ** prf)

synLRS : Ord cst_t =>
         (loss_xy : cnd_t -> cst_t) ->
         (grd_xy : cnd_t -> cnd_t) ->
         (grdsnt : (cnd_t -> cst_t) -> (cnd_t -> cnd_t) -> cnd_t -> cnd_t) ->
         (cnd : cnd_t) ->
         (prf : ((loss_xy (grdsnt loss_xy grd_xy cnd)) <= (loss_xy cnd)) === True) ->
         Subset cnd_t (\res : cnd_t => ((loss_xy res) <= (loss_xy cnd)) === True)
synLRS loss_xy grd_xy grdsnt cnd prf = ?synLRS_rhs -- Element (grdsnt loss_xy grd_xy cnd) prf

-- ||| Attempt to synthesize
-- |||
-- ||| gradientdescent (linloss x y) (lingrd x y) eta bst
-- |||
-- ||| via Idris proof search.  Fails so far because it uses the gradient
-- ||| as step function, instead of building the step function with
-- ||| grd2stp.
-- |||
-- ||| Fails due to a variaty of reasons described below
-- synLR : (gradientdescent : (ColVect n Double -> Double) -> (ColVect n Double -> ColVect n Double) -> Double -> (ColVect n Double, Nat)) ->
--         (linloss : Matrix m n Double -> ColVect n Double -> ColVect n Double -> Double) ->
--         (lingrd : Matrix m n Double -> ColVect m Double -> ColVect n Double -> ColVect n Double) ->
--         (x : Matrix m n Double) ->
--         (y : ColVect m Double) ->
--         (eta : Double) ->
--         (cnd : ColVect n Double) ->
--         (ColVect n Double)
-- -- synLR gradientdescent linloss lingrd x y eta bst = ?synLR_rhs

-- Fails because Idris does not like ColVect n Double, apparently.
-- synLR : (grdsnt : (ColVect n Double -> Double) -> (ColVect n Double) -> (ColVect n Double)) ->
--         (loss : (ColVect n Double -> Double)) ->
--         (cnd : (ColVect n Double)) ->
--         (ColVect n Double)
-- synLR grdsnt loss cnd = ?synLR_rhs

-- -- Fails because Idris cannot create (loss x y) and (grd x y)
-- synLR : (loss : mat_t -> col_t -> cnd_t -> cst_t) ->
--         (grd : mat_t -> col_t -> cnd_t -> cnd_t) ->
--         (grdsnt : (cnd_t -> cst_t) -> (cnd_t -> cnd_t) -> cnd_t -> cnd_t) ->
--         (cnd : cnd_t) ->
--         (x : mat_t) ->
--         (y : col_t) ->
--         cnd_t
-- synLR loss grd grdsnt x y cnd = ?synLR_rhs

-- -- Fails because Idris cannot create (loss xy) and (grd xy)
-- synLR : (grdsnt : (cnd_t -> cst_t) -> cnd_t -> cnd_t) ->
--         (loss : (mat_t, col_t) -> cnd_t -> cst_t) ->
--         (xy : (mat_t, col_t)) ->
--         (cnd : cnd_t) ->
--         cnd_t
-- synLR grdsnt loss xy cnd = ?synLR_rhs

-- -- Fails because cnd is missing in the definition of synLR
-- synLR : (loss_xy : cnd_t -> cst_t) ->
--         (grd_xy : cnd_t -> cnd_t) ->
--         (grdsnt : (cnd_t -> cst_t) -> (cnd_t -> cnd_t) -> cnd_t -> cnd_t) ->
--         (cnd : cnd_t) ->
--         cnd_t
-- synLR loss_xy grd_xy grdsnt = ?synLR_rhs
