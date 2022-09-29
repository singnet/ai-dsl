module LogisticRegression

import System.Random
import Data.String
import Data.Vect
import Data.Matrix
import GradientDescent
import Utils

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
true_beta = [-1, -2, 0.1, 8]

||| Calculate the probability of success as the expit of the dot
||| product between
|||
||| xs = [1, size, expenditure, familiarity]
|||
||| and true_beta, thus
|||
||| success xs = expit(β₀ + β₁*size + β₂*expenditure + β₃*familiarity)
success : Vect 4 Double -> Double
success xs = expit (dot xs true_beta)

-- Generate a train/test data set

||| Make a random generator for the input data set.  That is a matrix
||| m*4 where the first column is filled with 1s to deal with the bias
||| term, and the remaining three columns are randomly generated with
||| ranges [0, 10], [0, 100] and [0, 1] respectively.
rnd_input_data : (m : Nat) -> IO (Matrix m 4 Double)
rnd_input_data m = let rngs : RowVect 4 (Double, Double)
                       rngs = MkMatrix [[(1, 1), (0, 10), (0, 100), (0, 1)]]
                   in randomRIO (unzip (replicateRow rngs))

||| Given a matrix representing the input data set, create a column
||| vector of the probability of success of the logistic model.
success_probs_data : Matrix m 4 Double -> ColVect m Double
success_probs_data x = MkMatrix (map ((::Nil) . success) x.vects)

||| Given a matrix representing the input data set, sample a column
||| vector of the output according to the probability of success of
||| the logistic model.
rnd_success_data : Matrix m 4 Double -> IO (ColVect m Bool)
rnd_success_data x = traverse bernoulliSample (success_probs_data x)

-- Test logistic regression

test_logreg : IO ()
test_logreg =
  let -- Parameters
      sample_size : Nat         -- Total sample size
      sample_size = 100
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      train_size : Nat          -- Train sample size
      train_size = cast ((cast sample_size) * train_test_ratio)
      test_size : Nat           -- Test sample size
      test_size = minus sample_size train_size
      eta : Double              -- Learning rate
      eta = 3.0e-5
      beta : ColVect 4 Double   -- Initial model
      beta = replicate 0.0
  in do -- Generate train and test data
        putStrLn ""
        putBoxedStrLn "Generating data"
        x <- rnd_input_data sample_size
        y <- rnd_success_data x
        let -- Below if a convoluted way of saying
            -- (x_train, x_test) = splitAtRow train_size x
            -- (y_train, y_test) = splitAtRow train_size y
            x_split : (Matrix train_size 4 Double, Matrix test_size 4 Double)
            x_split = splitAtRow train_size x
            y_split : (ColVect train_size Bool, ColVect test_size Bool)
            y_split = splitAtRow train_size y
            x_train : Matrix train_size 4 Double
            x_train = fst x_split
            y_train : ColVect train_size Bool
            y_train = fst y_split
            x_test : Matrix test_size 4 Double
            x_test = snd x_split
            y_test : ColVect test_size Bool
            y_test = snd y_split
        putStrLn "\nTrain input data:"
        printLn x_train
        putStrLn "\nTrain probability of success data:"
        printLn (success_probs_data x_train)
        putStrLn "\nTrain output data:"
        printLn y_train
        putStrLn "\nTest input data:"
        printLn x_test
        putStrLn "\nTest probability of success data:"
        printLn (success_probs_data x_test)
        putStrLn "\nTest output data:"
        printLn y_test

        -- Learn model based on train data
        putStrLn ""
        putBoxedStrLn "Learning"
        let model : ColVect 4 Double
            model = logreg x_train y_train eta beta
            train_loss : Double
            train_loss = loss x_train y_train model
            train_gradient : ColVect 4 Double
            train_gradient = gradient x_train y_train model
            y_train_estimate : ColVect train_size Double
            y_train_estimate = x_train * model
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nTrain output prediction:"
        printLn y_train_estimate
        putStrLn "\nTrain loss:"
        printLn train_loss
        putStrLn "\nTrain gradient:"
        printLn train_gradient

        -- Test model based on test data
        putStrLn ""
        putBoxedStrLn "Testing"
        let test_loss : Double
            test_loss = loss x_test y_test model
            test_gradient : ColVect 4 Double
            test_gradient = gradient x_test y_test model
            y_test_estimate : ColVect test_size Double
            y_test_estimate = x_test * model
        putStrLn "\nTest output prediction:"
        printLn y_test_estimate
        putStrLn "\nTest loss:"
        printLn test_loss
        putStrLn "\nTest gradient:"
        printLn test_gradient
