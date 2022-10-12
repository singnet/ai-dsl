module Search.Regression.Linear

import System.Random
import Data.String
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
loss : (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = sse (y - (x * beta))

||| Gradient: ∇L(β) = -2Xᵀ(Y-Xβ)
public export
gradient : {n : Nat} ->
           (x : Matrix m n Double) ->
           (y : ColVect m Double) ->
           (beta : ColVect n Double) ->
           ColVect n Double
gradient x y beta = scale (-2) ((transpose x) * (y - (x * beta)))

||| Multivariate Linear Regression.  Given an input data set x and its
||| corresponding output y, a learning rate eta and initial model
||| beta, return a model β' so that x*β' approximates y.  The returned
||| model is discovered using gradient descent.
|||
||| @x Matrix of size m*n, samples size m, n input variables
||| @y Column vector of size m
||| @eta learning rate, small positive value
||| @beta initial model, column vector of n parameters
||| @steps maximum number of steps allocated
public export
linreg : {n : Nat} ->
         (x : Matrix m n Double) ->
         (y : ColVect m Double) ->
         (eta : Double) ->
         (beta_steps : (ColVect n Double, Nat)) ->
         (ColVect n Double, Nat)
linreg x y = gradientDescent (loss x y) (gradient x y)

------------
-- Proofs --
------------

||| Proof that the candidate returned by linear regression is better
||| or equal to the initial candidate.
|||
||| TODO: add more properties and proofs pertaining to
|||
||| 1. global optimality, if any,
||| 2. linearity of the model,
||| 3. sse-ness of the cost function,
||| 4. gradient-ness of the next function, and more.
public export
linreg_le : {n : Nat} ->
            (x : Matrix m n Double) ->
            (y : ColVect m Double) ->
            (eta : Double) ->
            (beta_steps : (ColVect n Double, Nat)) ->
            ((loss x y (fst (linreg x y eta beta_steps))) <= (loss x y (fst beta_steps))) === True
linreg_le x y = gradientDescent_le (loss x y) (gradient x y)
