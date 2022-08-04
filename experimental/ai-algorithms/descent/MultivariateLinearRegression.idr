module MultivariateLinearRegression

import Data.Vect
import Matrix
import Descent

-- Multivariate Linear Regression
--
-- 1. The data set is stored in a pair of
--
--    a. Matrix Xₘₙ = (xᵢⱼ) where 1≤i≤m, the row index, represents the
--       input of the iᵗʰ sample, and 1≤j≤n, the column index,
--       represents the value associated to the jᵗʰ variable.  Thus
--       the matrix represents a data set of sample size m, with n
--       input variables.  Often the matrix is augmented with a last
--       column filled with ones to simulate a bias term, also called
--       y-intercept, in the linear model.
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
-- the gradient descent is obtained as follows
--
-- ∇L(β) = -2Xᵀ(Y-Xβ)
--
-- Thus, given a learning rate 0<η, the model is updated as follows
--
-- β ← β + η∇L(β)
--
-- or
--
-- β ← β + 2ηXᵀ(Y-Xβ)
--
-- [1] Alexander Dekhtyar, Advance Data Mining, Gradient Descent, 2017,
--     http://users.csc.calpoly.edu/~dekhtyar/566-Spring2017/lectures/lec07.566.pdf

||| Sum of squared errors
sse : (e : ColVect m Double) -> Double
sse e = let ev = Data.Vect.concat e.vects  -- NEXT: ev = cast e
        in dot ev ev

||| Loss function: L(β) = ||Y-Xβ||²
loss : (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = sse (y - x * beta)

-- ||| Gradient descent: ∇L(β) = -2Xᵀ(Y-Xβ)
-- -- grdt : {m, n : Nat} ->          -- NEXT: why do we need this?
-- grdt : (x : Matrix m n Double) ->
--        (y : ColVect m Double) ->
--        (beta : ColVect n Double) ->
--        ColVect n Double
-- -- grdt x y beta = scale (-2) $ (transpose x) * (y - x * beta)
-- -- grdt x y beta = scale (-2) (transpose (transpose beta))
-- grdt x y beta = let betaT : RowVect n Double
--                     betaT = (transpose beta)
--                 in (transpose betaT)

grdt : (beta : ColVect n Double) -> ColVect n Double
grdt beta = (transpose (transpose beta))

-- ||| Multivariate Linear Regression.  Given an input data set x and its
-- ||| corresponding output y, a learning rate eta and initial model
-- ||| beta, return a model β^ so that x*β^ approximates y.  The returned
-- ||| model is discovered using gradient descent.
-- |||
-- ||| @x Matrix of size m*n, samples size m, n input variables
-- ||| @y Column vector of size m
-- ||| @eta learning rate, small positive value
-- ||| @beta initial model, column vector of n parameters
-- linreg : (x : Matrix m n Double) ->
--          (y : ColVect m Double) ->
--          (eta : Double) ->
--          (beta : ColVect n Double) ->
--          ColVect n Double
-- linreg x y eta beta = descent (loss x y) (\cnd => (scale eta (grdt x y cnd))) beta
