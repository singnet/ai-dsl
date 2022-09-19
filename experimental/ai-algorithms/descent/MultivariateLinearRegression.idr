module MultivariateLinearRegression

import System.Random
import Data.String
import Data.Vect
import Matrix
import Descent

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
sse e = let ev = Data.Vect.concat e.vects
        -- NEXT: let ev = Matrix.Cast.cast e
        in dot ev ev

||| Loss function: L(β) = ||Y-Xβ||².  Using implicit n argument.
loss : (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       Double
loss x y beta = sse (y - (x * beta))

||| Gradient descent: ∇L(β) = -2Xᵀ(Y-Xβ).  Using implicit n argument.
grdt : {n : Nat} ->
       (x : Matrix m n Double) ->
       (y : ColVect m Double) ->
       (beta : ColVect n Double) ->
       ColVect n Double
grdt x y beta = scale (-2) ((transpose x) * (y - (x * beta)))

||| Next candidate function using the gradient descent.  Given a
||| candidate, return a new candidate by taking a step towards the
||| gradient descent.
nxtgd : {n : Nat} ->
        (x : Matrix m n Double) ->
        (y : ColVect m Double) ->
        (eta : Double) ->
        (beta : ColVect n Double) ->
        ColVect n Double
nxtgd x y eta beta = beta - (scale (2 * eta) (grdt x y beta))

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
linreg x y eta = descent (loss x y) (nxtgd x y eta)

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
linreg_le : {n : Nat} ->
            (x : Matrix m n Double) ->
            (y : ColVect m Double) ->
            (eta : Double) ->
            (beta : ColVect n Double) ->
            ((loss x y (linreg x y eta beta)) <= (loss x y beta)) === True
linreg_le x y eta = descent_le (loss x y) (nxtgd x y eta)

----------
-- Test --
----------

-- Multivariate linear regression example: modeling the AGIX price of
-- a service given the size of the data set, the number of input
-- variables and the accuracy of the expected model.

||| Generative model, β₀=10, β₁=20, β₂=30, β₃=40, where
|||
||| β₀ is the bias term
||| β₁ is the data size factor
||| β₂ is the number of variables factor
||| β₃ is the target accuracy factor
true_beta : Vect 4 Double
true_beta = [10, 20, 30, 40]

||| Calculate the price as the dot product between
|||
||| xs = [1, data_size, nbr_variables, target_accuracy]
|||
||| and true_beta, thus
|||
||| price = β₀ + β₁*data_size + β₂*nbr_variables + β₃*target_accuracy
price : Vect 4 Double -> Double
price xs = dot xs true_beta

-- Generate a train/test data set

||| Make a random generator for the input data set.  That is a matrix
||| m*4 where the first column is filled with 1s to deal with the bias
||| term, and the remaining three columns are randomly generated with
||| ranges [0, 100], [0, 10] and [0, 1] respectively.
mk_rnd_input_data : (m : Nat) -> IO (Matrix m 4 Double)
mk_rnd_input_data m = let rngs : RowVect 4 (Double, Double)
                          rngs = MkMatrix [[(1, 1), (0, 100), (0, 10), (0, 1)]]
                      in randomRIO (unzip (replicateRow rngs))

||| Given a matrix representing the input data set, return a column
||| vector of the output according to the `price` formula defined
||| above.
mk_output_data : Matrix m 4 Double -> ColVect m Double
mk_output_data x = MkMatrix (map ((::Nil) . price) x.vects)

-- Test linear regression

||| Wrap a given one-liner message in a box and send to stdout.
putBoxedStrLn : String -> IO ()
putBoxedStrLn s =
  let left_decorator = "║ "
      right_decorator = " ║"
      upleft_decorator = "╔═"
      downleft_decorator = "╚═"
      upright_decorator = "═╗"
      downright_decorator = "═╝"
      updown_decorator = '═'
      updown_subline = replicate (length s) updown_decorator
      up_line = upleft_decorator ++ updown_subline ++ upright_decorator
      center_line = left_decorator ++ s ++ right_decorator
      down_line = downleft_decorator ++ updown_subline ++ downright_decorator
  in do putStrLn up_line
        putStrLn center_line
        putStrLn down_line

test_linreg : IO ()
test_linreg =
  let -- Parameters
      sample_size : Nat         -- Total sample size
      sample_size = 30
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      train_size : Nat          -- Train sample size
      train_size = cast ((cast sample_size) * train_test_ratio)
      test_size : Nat           -- Test sample size
      test_size = minus sample_size train_size
      eta : Double              -- Learning rate
      eta = 7.0e-6
      beta : ColVect 4 Double   -- Initial model
      beta = replicate 0.0
  in do -- Generate train and test data
        putStrLn ""
        putBoxedStrLn "Generating data"
        x <- mk_rnd_input_data sample_size
        let y : ColVect sample_size Double
            y = mk_output_data x
            x_split : (Matrix train_size 4 Double, Matrix test_size 4 Double)
            x_split = splitAtRow train_size x
            y_split : (ColVect train_size Double, ColVect test_size Double)
            y_split = splitAtRow train_size y
            x_train : Matrix train_size 4 Double
            x_train = fst x_split
            y_train : ColVect train_size Double
            y_train = fst y_split
            x_test : Matrix test_size 4 Double
            x_test = snd x_split
            y_test : ColVect test_size Double
            y_test = snd y_split
        putStrLn "\nTrain input data:"
        printLn x_train
        putStrLn "\nTrain output data:"
        printLn y_train
        putStrLn "\nTest input data:"
        printLn x_test
        putStrLn "\nTest output data:"
        printLn y_test

        -- Learn model based on train data
        putStrLn ""
        putBoxedStrLn "Learning"
        let model : ColVect 4 Double
            model = linreg x_train y_train eta beta
            train_loss : Double
            train_loss = loss x_train y_train model
            y_train_estimate : ColVect train_size Double
            y_train_estimate = x_train * model
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nTest output estimate:"
        printLn y_train_estimate
        putStrLn "\nTrain loss:"
        printLn train_loss

        -- Test model based on test data
        putStrLn ""
        putBoxedStrLn "Testing"
        let test_loss : Double
            test_loss = loss x_test y_test model
            y_test_estimate : ColVect test_size Double
            y_test_estimate = x_test * model
        putStrLn "\nTest output estimate:"
        printLn y_test_estimate
        putStrLn "\nTest loss:"
        printLn test_loss
