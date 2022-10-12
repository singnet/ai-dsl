module Examples.LinearRegression

import System.Random
import Data.String
import Data.Vect
import Data.Matrix
import Search.Regression.Linear
import Search.Util

-------------------------------
-- Linear Regression Example --
-------------------------------

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
rnd_input_data : (m : Nat) -> IO (Matrix m 4 Double)
rnd_input_data m = let rngs : RowVect 4 (Double, Double)
                       rngs = MkMatrix [[(1, 1), (0, 100), (0, 10), (0, 1)]]
                   in randomRIO (unzip (replicateRow rngs))

||| Given a matrix representing the input data set, return a column
||| vector of the output according to the `price` formula defined
||| above.
price_data : Matrix m 4 Double -> ColVect m Double
price_data x = toColVect (map price x.vects)

-- Test linear regression

test_linreg : IO ()
test_linreg =
  let -- Parameters
      rndseed : Bits64          -- Random seed
      rndseed = 42
      sample_size : Nat         -- Total sample size
      sample_size = 30
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      train_size : Nat          -- Train sample size
      train_size = cast ((cast sample_size) * train_test_ratio)
      test_size : Nat           -- Test sample size
      test_size = minus sample_size train_size
      eta : Double              -- Learning rate
      eta = 1.0e-5
      beta : ColVect 4 Double   -- Initial model
      beta = replicate 0.0
      maxsteps : Nat            -- Maximum number of steps
      maxsteps = 1000000
  in do -- Generate train and test data
        srand rndseed
        putStrLn ""
        putBoxedStrLn "Generating data"
        x <- rnd_input_data sample_size
        let y = price_data x
            (x_train, x_test) = splitAtRow train_size x
            (y_train, y_test) = splitAtRow train_size y
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
        let (model, leftsteps) = linreg x_train y_train eta (beta, maxsteps)
            steps : Nat         -- Actual number of steps used
            steps = minus maxsteps leftsteps
            train_loss : Double
            train_loss = loss x_train y_train model
            y_train_prediction : ColVect train_size Double
            y_train_prediction = x_train * model
        putStrLn ("\nActual number of steps used = " ++ show steps)
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nTrain output prediction:"
        printLn y_train_prediction
        putStrLn "\nTrain loss:"
        printLn train_loss

        -- Test model based on test data
        putStrLn ""
        putBoxedStrLn "Testing"
        let test_loss : Double
            test_loss = loss x_test y_test model
            y_test_prediction : ColVect test_size Double
            y_test_prediction = x_test * model
        putStrLn "\nTest output prediction:"
        printLn y_test_prediction
        putStrLn "\nTest loss:"
        printLn test_loss
