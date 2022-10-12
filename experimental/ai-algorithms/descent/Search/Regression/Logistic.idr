module Search.Regression.Logistic

import Debug.Trace
import System.Random
import Data.String
import Data.Vect
import Data.Matrix
import Search.GradientDescent
import Search.Util

--------------------------------
-- Define Logistic Regression --
--------------------------------

-- Logistic Regression
--
-- 1. The data set is stored in a pair of
--
--    a. Matrix Xₘₙ = (xᵢⱼ) where 1≤i≤m, the row index, represents the
--       input of the iᵗʰ sample, and 1≤j≤n, the column index,
--       represents the value associated to the jᵗʰ input variable.
--       Thus the matrix represents a data set of sample size m, with
--       n input variables.  Often the matrix is augmented with a
--       first or last column filled with ones to simulate a value of
--       sigmoid midpoint in the logistic model.
--
--    b. Column vector Y = (yᵢ) where 1≤i≤m, the row index, represents
--       the output of iᵗʰ sample, a boolean outcome.
--
-- 2. The model is stored in a column vector β = (βⱼ) where 1≤j≤n, the
--    row index, represents the weight associated to the jᵗʰ variable.
--
-- A popular loss function for logistic regression is the logistic
-- loss, or log loss, based on the cross entropy defined as follows:
--
-- L(β) = -m⁻¹∑ᵢ yᵢlog(pᵢ) + (1-yᵢ)log(1-pᵢ)
--
-- where P = (pᵢ) for i≤i≤m, is obtained as follows
--
-- P = expit(Xβ)
--
-- where expit is the point-wise standard logistic function applied to
-- a vector of odds, O = (oᵢ) for i≤i≤m, defined as
--
-- expit(oᵢ) = 1 / (1 + exp(-oᵢ))
--
-- where such vector of odds has been obtained by
--
-- O = Xβ
--
-- Since m is constant L can be simplified into
--
-- L(β) = -∑ᵢ yᵢlog(pᵢ) + (1-yᵢ)log(1-pᵢ)
--
-- Accoding to [1] the following gradient can be derived from L
--
-- ∇L(β) = Xᵀ(expit(Xβ)-Y)
--
-- Thus, given a learning rate 0<η, the model is updated as follows
-- (subtracting the gradient ascent to become a gradient descent):
--
-- β ← β - η∇L(β)
--
-- or
--
-- β ← β + ηXᵀ(Y-expit(Xβ))
--
-- [1] https://en.wikipedia.org/wiki/Cross_entropy#Cross-entropy_loss_function_and_logistic_regression

||| Loss function: L(β) = -∑ᵢ yᵢlog(pᵢ) + (1-yᵢ)log(1-pᵢ)
public export
loss : (x : Matrix m n Double) ->
       (y : ColVect m Bool) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = let p = map expit (x * beta)
                    l = sum (zipWith bernoulliCrossEntropy (indicator y) p)
                in l
                -- Uncomment the following for tracing the loss.  Note
                -- that Debug.NoTrace does not do its job of not
                -- slowing down computation so we have to instead
                -- manual comment/uncomment the code.
                --
                -- in trace ("loss = " ++ (show l)) l

||| Gradient: ∇L(β) = Xᵀ(expit(Xβ)-Y)
public export
gradient : {n : Nat} ->
           (x : Matrix m n Double) ->
           (y : ColVect m Bool) ->
           (beta : ColVect n Double) ->
           ColVect n Double
gradient x y beta = let p = map expit (x * beta)
                    in (transpose x) * (p - (indicator y))

||| Logistic Regression.  Given an input data set x and its
||| corresponding output y, a learning rate eta and initial model
||| beta, return a model β' so that expit(x*β') approximates the
||| probabilities of the outcomes of y.  The returned model is
||| discovered using gradient descent.
|||
||| @x Matrix of size m*n, samples size m, n input variables
||| @y Column vector of size m
||| @eta learning rate, small positive value
||| @beta initial model, column vector of n parameters
||| @steps maximum number of steps allocated
public export
logreg : {n : Nat} ->
         (x : Matrix m n Double) ->
         (y : ColVect m Bool) ->
         (eta : Double) ->
         (beta_steps : (ColVect n Double, Nat)) ->
         (ColVect n Double, Nat)
logreg x y = gradientDescent (loss x y) (gradient x y)

||| Takes a input matrix, a logistic model and output a column vector
||| of predictions.  A True value is predicted if the probability
||| output by the logistic model is greater than 0.5, False otherwise.
|||
||| @x input matrix
||| @beta logistic model
public export
predict : Matrix m n Double -> ColVect n Double -> ColVect m Bool
predict x beta = map ((0.5 <) . expit) (x * beta)

------------
-- Proofs --
------------

||| Proof that the candidate returned by logistic regression is better
||| or equal to the initial candidate.
|||
||| TODO: add more properties and proofs pertaining to
|||
||| 1. global optimality, if any,
||| 2. logistic model,
||| 3. cross-entropy-ness of the cost function,
||| 4. gradient-ness of the next function, and more.
public export
logreg_le : {n : Nat} ->
            (x : Matrix m n Double) ->
            (y : ColVect m Bool) ->
            (eta : Double) ->
            (beta_steps : (ColVect n Double, Nat)) ->
            ((loss x y (fst (logreg x y eta beta_steps))) <= (loss x y (fst beta_steps))) === True
logreg_le x y = gradientDescent_le (loss x y) (gradient x y)
