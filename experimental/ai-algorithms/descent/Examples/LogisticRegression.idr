module Examples.LogisticRegression

import System.Random
import Data.String
import Data.Vect
import Data.Matrix
import Search.Regression.Logistic
import Search.Util

---------------------------------
-- Logistic Regression Example --
---------------------------------

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
      sample_size = 1000
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      train_size : Nat          -- Train sample size
      train_size = cast ((cast sample_size) * train_test_ratio)
      test_size : Nat           -- Test sample size
      test_size = minus sample_size train_size
      eta : Double              -- Learning rate
      eta = 1.0e-6
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
