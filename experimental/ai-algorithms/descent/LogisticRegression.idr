module LogisticRegression

import System.Random
import Data.String
import Data.Vect
import Matrix
import GradientDescent

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

||| Logistic function
|||
||| l / (1 + exp(-k*(x-x0)))
|||
||| @x0 the value of the sigmoid's midpoint
||| @l the curve's maximum value
||| @k k, the logistic growth rate or steepness of the curve
||| @x the input value
logistic : Double -> Double -> Double -> Double -> Double
logistic x0 l k x = l / (1.0 + exp(-k*(x-x0)))

||| Standard logistic function
|||
||| 1 / (1 + exp(-x))
|||
||| @x the input value
expit : Double -> Double
expit = logistic 0 1 1

||| Cross entropy between 2 Bernoulli distributions: p*log(q) + (1-p)*log(1-q)
bernoulliCrossEntropy : Double -> Double -> Double
bernoulliCrossEntropy p q = p*log(q) + (1 - p)*log(1 - q)

||| Cast a Bool into a Double
|||
||| False -> 0.0
||| True -> 1.0
|||
||| Not using the cast interface as it is not necessarily conventional.
boolToDouble : Bool -> Double
boolToDouble False = 0.0
boolToDouble True = 1.0

||| Akin to an indicator function, i.e. point-wise cast a container of
||| boolean values to a container of double values using boolToDouble.
indicator : Functor f => f Bool -> f Double
indicator = map boolToDouble

||| Loss function: L(β) = -∑ᵢ yᵢlog(pᵢ) + (1-yᵢ)log(1-pᵢ)
loss : (x : Matrix m n Double) ->
       (y : ColVect m Bool) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = let p = map expit (x * beta)
                in sum (zipWith bernoulliCrossEntropy (indicator y) p)

||| Gradient: ∇L(β) = Xᵀ(expit(Xβ)-Y)
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
logreg : {n : Nat} ->
         (x : Matrix m n Double) ->
         (y : ColVect m Bool) ->
         (eta : Double) ->
         (beta : ColVect n Double) ->
         ColVect n Double
logreg x y = gradientDescent (loss x y) (gradient x y)

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
logreg_le : {n : Nat} ->
            (x : Matrix m n Double) ->
            (y : ColVect m Bool) ->
            (eta : Double) ->
            (beta : ColVect n Double) ->
            ((loss x y (logreg x y eta beta)) <= (loss x y beta)) === True
logreg_le x y = gradientDescent_le (loss x y) (gradient x y)

----------
-- Test --
----------

-- Logistic regression example: try to predict the success of a query
-- to the AI-DSL registry given:
--
-- 1. the size of the query,
-- 2. the expenditure of the query,
-- 3. the familiarity of the query with respect to past queries.
--
-- The smaller the query, the larger the expenditure allocated to
-- fulfill that query and the larger the familiarity of the query,
-- then more likely the query is to be fulfilled.

||| Generative model, β₀=-1, β₁=-2, β₂=4, β₃=8, where
|||
||| β₀ is the bias term
||| β₁ is the query size factor
||| β₂ is the query expenditure factor
||| β₃ is the query familiarity factor
true_beta : Vect 4 Double
true_beta = [-1, -2, 4, 8]

||| Calculate the odds of success as the dot product between
|||
||| xs = [1, size, expenditure, familiarity]
|||
||| and true_beta, thus
|||
||| success_odds xs = β₀ + β₁*size + β₂*expenditure + β₃*familiarity
success_odds : Vect 4 Double -> Double
success_odds xs = dot xs true_beta

||| Calculate the probability of success by mapping the odds to a
||| probability using the standard logistic function.
success_prob : Double -> Double
success_prob = expit

-- Generate a train/test data set

-- NEXT
