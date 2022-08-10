module MultivariateLinearRegression

import System.Random
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

||| Loss function: L(β) = ||Y-Xβ||².  Using implicit n argument.
loss : (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = sse (y - (mtimes x beta))

||| Loss function: L(β) = ||Y-Xβ||².  Assuming non null dimensions.
loss' : (x : Matrix m (S n) Double) ->
        (y : ColVect m Double) ->
        (beta : ColVect (S n) Double) ->
        Double
loss' x y beta = sse (y - (mtimes' x beta))

||| Gradient descent: ∇L(β) = -2Xᵀ(Y-Xβ).  Using implicit n argument.
grdt : {n : Nat} ->
       (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       ColVect n Double
grdt x y beta = scale (-2) (mtimes (transpose x) (y - (mtimes x beta)))

||| Gradient descent: ∇L(β) = -2Xᵀ(Y-Xβ).  Assuming non null dimensions.
grdt' : (x : Matrix (S m) (S n) Double) ->
        (y : ColVect (S m) Double) ->
        (beta : ColVect (S n) Double) ->
        ColVect (S n) Double
grdt' x y beta = scale (-2) (mtimes' (transpose' x) (y - (mtimes' x beta)))

||| Multivariate Linear Regression.  Given an input data set x and its
||| corresponding output y, a learning rate eta and initial model
||| beta, return a model β^ so that x*β^ approximates y.  The returned
||| model is discovered using gradient descent.
|||
||| @x Matrix of size m*n, samples size m, n input variables
||| @y Column vector of size m
||| @eta learning rate, small positive value
||| @beta initial model, column vector of n parameters
linreg : {n : Nat} ->
         (x : Matrix m n Double) ->
         (y : ColVect m Double) ->
         (eta : Double) ->
         (beta : ColVect n Double) ->
         ColVect n Double
linreg x y eta = descent (loss x y)
                         (\bt => bt - (scale (2 * eta) (grdt x y bt)))

||| Like linreg but assume non null dimensions.
linreg' : (x : Matrix (S m) (S n) Double) ->
          (y : ColVect (S m) Double) ->
          (eta : Double) ->
          (beta : ColVect (S n) Double) ->
          ColVect (S n) Double
linreg' x y eta = descent (loss' x y)
                          (\bt => bt - (scale (2 * eta) (grdt' x y bt)))

----------
-- Test --
----------

-- Multivariate linear regression example: modeling the AGIX price of
-- a service given the size of the data set, the number of input
-- variables and the accuracy of the expected model.

-- Generative model, β₀=10, β₁=20, β₂=30, β₃=40
true_beta : Vect 4 Double
true_beta = [10, 20, 30, 40]

-- Calculate the price as the dot product between
--
-- xs = [1, data_size, nbr_variables, target_accuracy]
--
-- and true_beta, thus
--
-- price = β₀ + β₁*data_size + β₂*nbr_variables + β₃*target_accuracy
price : Vect 4 Double -> Double
price xs = dot xs true_beta

-- Generate a data set

-- TODO: possibly use https://github.com/idris-bayes/distribution

||| Generate a data set, a pair (x, y), such that
|||
||| x is a matrix m*4 where rows represent data points and columns
||| represent values for each variable.  The first column is filled
||| with 1s to deal with the bias term.
|||
||| y is a column vector m representing the output, here the price, of
||| each data point.
gen : (m : Nat) -> IO (Matrix m 4 Double, ColVect m Double)
-- NEXT: use random generator randomRIO

getRand10to20 : IO Double
getRand10to20 = randomRIO (10.0, 20.0)

getF : IO String
getF = pure "Fashion"

main : IO ()
main = putStrLn "Hello World!"

greet : IO ()
greet = do putStr "What is your name? "
           name <- getLine
           f <- getF
           r <- getRand10to20
           putStrLn ("Hello " ++ name ++ " " ++ (show r) ++ " " ++ f)
