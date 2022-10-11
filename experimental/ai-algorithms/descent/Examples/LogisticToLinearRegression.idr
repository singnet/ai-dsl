module Examples.LogisticToLinearRegression

import System.Random
import Data.String
import Data.Vect
import Data.SortedMap
import Data.Matrix
import Data.Counter
import Search.GradientDescent
import Search.Regression.Linear
import Search.Regression.Logistic
import Search.Util

-------------------------------------------
-- Logistic to Linear Regression Example --
-------------------------------------------

-- Logistic regression example: try to predict if a AI service is
-- overpriced based on 3 Boolean input features
--
-- 1. price: whether the price of the service is higher than average
-- 2. recommendation: whether the recommendation is higher than average
-- 3. demande: whether the demand for that service is higher than average
--
-- The idea being that if a service has a high price, a low
-- recommendation and a low demande, then it is likely overpriced.

||| Generative model, β₀=5, β₁=-7, β₂=-1, where
|||
||| β₀ is the high price factor
||| β₁ is the high recommendation factor
||| β₂ is the high demand factor
|||
||| There are no bias term.
true_beta : Vect 3 Double
true_beta = [5, -7, -1]

||| Calculate the probability of being overpriced as the expit of the
||| dot product between
|||
||| xs = [price, recommendation, demand]
|||
||| and true_beta, thus
|||
||| overpriced xs = expit(β₀*price + β₁*recommendation + β₂*demand)
overpriced : Vect 3 Bool -> Double
overpriced xs = expit (dot (indicator xs) true_beta)

-- Generate a train/test data set

||| Make a random generator for the input data set.  That is a matrix
||| m*3 where the each cell is generated according to an unbiased
||| Bernoulli distribution.
rnd_input_data : (m : Nat) -> IO (Matrix m 3 Bool)
rnd_input_data m = let probs : Matrix m 3 Double
                       probs = replicate 0.5
                   in traverse bernoulliSample probs

||| Given a matrix representing the input data set, create a column
||| vector of the probability of being overpriced according to the
||| true logistic model.
overpriced_probs_data : Matrix m 3 Bool -> ColVect m Double
overpriced_probs_data x = toColVect (map overpriced x.vects)

||| Given a matrix representing the input data set, sample a column
||| vector of the output according to the probability of success of
||| the logistic model.
rnd_overpriced_data : Matrix m 3 Bool -> IO (ColVect m Bool)
rnd_overpriced_data x = traverse bernoulliSample (overpriced_probs_data x)

-- Test logistic regression

||| Attempt to recover the true model, true_beta, using logistic regression
test_logreg : IO ()
test_logreg =
  let -- Parameters
      rndseed : Bits64          -- Random seed
      rndseed = 42
      sample_size : Nat         -- Total sample size
      sample_size = 1000
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      train_size : Nat          -- Train sample size
      train_size = cast ((cast sample_size) * train_test_ratio)
      test_size : Nat           -- Test sample size
      test_size = minus sample_size train_size
      eta : Double              -- Learning rate
      eta = 1.0e-2
      beta : ColVect 3 Double   -- Initial model
      beta = replicate 0.0
      maxsteps : Nat            -- Maximum number of steps
      maxsteps = 1000
  in do -- Generate train and test data
        srand rndseed
        putStrLn ""
        putBoxedStrLn "Generating data"
        x <- rnd_input_data sample_size
        y <- rnd_overpriced_data x
        let -- Below if a convoluted way of saying
            -- (x_train, x_test) = splitAtRow train_size x
            -- (y_train, y_test) = splitAtRow train_size y
            x_split : (Matrix train_size 3 Bool, Matrix test_size 3 Bool)
            x_split = splitAtRow train_size x
            y_split : (ColVect train_size Bool, ColVect test_size Bool)
            y_split = splitAtRow train_size y
            x_train : Matrix train_size 3 Bool
            x_train = fst x_split
            y_train : ColVect train_size Bool
            y_train = fst y_split
            x_test : Matrix test_size 3 Bool
            x_test = snd x_split
            y_test : ColVect test_size Bool
            y_test = snd y_split
        putStrLn "\nTrain input data:"
        printLn x_train
        putStrLn "\nTrain probability of being overpriced data:"
        printLn (overpriced_probs_data x_train)
        putStrLn "\nTrain output data:"
        printLn y_train
        putStrLn "\nTest input data:"
        printLn x_test
        putStrLn "\nTest probability of being overpriced data:"
        printLn (overpriced_probs_data x_test)
        putStrLn "\nTest output data:"
        printLn y_test

        -- Learn model based on train data
        putStrLn ""
        putBoxedStrLn "Learning"
        let x_train_d : Matrix train_size 3 Double
            x_train_d = (map boolToDouble x_train)
            x_test_d : Matrix test_size 3 Double
            x_test_d = (map boolToDouble x_test)
            model_ls : (ColVect 3 Double, Nat)
            model_ls = logreg x_train_d y_train eta (beta, maxsteps)
            model : ColVect 3 Double
            model = fst model_ls
            steps : Nat         -- Actual number of steps used
            steps = minus maxsteps (snd model_ls)
            train_loss : Double
            train_loss = loss x_train_d y_train model
            train_gradient : ColVect 3 Double
            train_gradient = gradient x_train_d y_train model
            y_train_prediction : ColVect train_size Bool
            y_train_prediction = predict x_train_d model
        putStrLn ("\nActual number of steps used = " ++ show steps)
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nTrain output prediction:"
        printLn y_train_prediction
        putStrLn "\nTrain loss:"
        printLn train_loss
        putStrLn "\nTrain gradient:"
        printLn train_gradient

        -- Test model based on test data
        putStrLn ""
        putBoxedStrLn "Testing"
        let test_loss : Double
            test_loss = loss x_test_d y_test model
            test_gradient : ColVect 3 Double
            test_gradient = gradient x_test_d y_test model
            y_test_prediction : ColVect test_size Bool
            y_test_prediction = predict x_test_d model
        putStrLn "\nTest output prediction:"
        printLn y_test_prediction
        putStrLn "\nTest loss:"
        printLn test_loss
        putStrLn "\nTest gradient:"
        printLn test_gradient

-- Test logistic to linear regression

||| Attempt to recover the true model, true_beta, using linear
||| regression, my mapping the logistic regression problem into a
||| linear regression problem.
test_loglinreg : IO ()
test_loglinreg =
  let -- Parameters
      rndseed : Bits64          -- Random seed
      rndseed = 42
      sample_size : Nat         -- Total sample size
      sample_size = 1000
      train_test_ratio : Double -- Train/Test ratio
      train_test_ratio = 2.0/3.0
      eta : Double              -- Learning rate
      eta = 1.0e-2
      beta : ColVect 3 Double   -- Initial model
      beta = replicate 0.0
      maxsteps : Nat            -- Maximum number of steps
      maxsteps = 1000
  in do -- Generate train and test data
        srand rndseed
        putStrLn ""
        putBoxedStrLn "Generating data"
        x <- rnd_input_data sample_size
        y <- rnd_overpriced_data x
        let nss_xyl : (nss : Nat ** (Matrix nss 3 Bool, ColVect nss Double))
            nss_xyl = logToLinData x y
            S : Nat             -- New sample size
            S = fst nss_xyl
            xyl : (Matrix S 3 Bool, ColVect S Double)
            xyl = snd nss_xyl
            TRS : Nat           -- Train sample size
            TRS = cast ((cast S) * train_test_ratio)
            TES : Nat           -- Test sample size
            TES = minus S TRS
            xl : Matrix S 3 Bool
            xl = fst xyl
            yl : ColVect S Double
            yl = snd xyl
            xl_split : (Matrix TRS 3 Bool, Matrix TES 3 Bool)
            xl_split = splitAtRow TRS (believe_me xl)
            yl_split : (ColVect TRS Double, ColVect TES Double)
            yl_split = splitAtRow TRS (believe_me yl)
            xl_train : Matrix TRS 3 Bool
            xl_train = fst xl_split
            yl_train : ColVect TRS Double
            yl_train = fst yl_split
            xl_test : Matrix TES 3 Bool
            xl_test = snd xl_split
            yl_test : ColVect TES Double
            yl_test = snd yl_split
        putStrLn "\nLinearized data set:"
        printLn xyl
        -- putStrLn "\nTrain input data:"
        -- printLn x_train
        -- putStrLn "\nTrain probability of being overpriced data:"
        -- printLn (overpriced_probs_data x_train)
        -- putStrLn "\nTrain output data:"
        -- printLn y_train
        -- putStrLn "\nTest input data:"
        -- printLn x_test
        -- putStrLn "\nTest probability of being overpriced data:"
        -- printLn (overpriced_probs_data x_test)
        -- putStrLn "\nTest output data:"
        -- printLn y_test

        -- -- Learn model based on train data
        -- putStrLn ""
        -- putBoxedStrLn "Learning"
        -- let x_train_d : Matrix TRS 3 Double
        --     x_train_d = (map boolToDouble x_train)
        --     x_test_d : Matrix TES 3 Double
        --     x_test_d = (map boolToDouble x_test)
        --     model_ls : (ColVect 3 Double, Nat)
        --     model_ls = logreg x_train_d y_train eta (beta, maxsteps)
        --     model : ColVect 3 Double
        --     model = fst model_ls
        --     steps : Nat         -- Actual number of steps used
        --     steps = minus maxsteps (snd model_ls)
        --     train_loss : Double
        --     train_loss = loss x_train_d y_train model
        --     train_gradient : ColVect 3 Double
        --     train_gradient = gradient x_train_d y_train model
        --     y_train_prediction : ColVect TRS Bool
        --     y_train_prediction = predict x_train_d model
        -- putStrLn ("\nActual number of steps used = " ++ show steps)
        -- putStrLn "\nModel:"
        -- printLn model
        -- putStrLn "\nTrain output prediction:"
        -- printLn y_train_prediction
        -- putStrLn "\nTrain loss:"
        -- printLn train_loss
        -- putStrLn "\nTrain gradient:"
        -- printLn train_gradient

        -- -- Test model based on test data
        -- putStrLn ""
        -- putBoxedStrLn "Testing"
        -- let test_loss : Double
        --     test_loss = loss x_test_d y_test model
        --     test_gradient : ColVect 3 Double
        --     test_gradient = gradient x_test_d y_test model
        --     y_test_prediction : ColVect TES Bool
        --     y_test_prediction = predict x_test_d model
        -- putStrLn "\nTest output prediction:"
        -- printLn y_test_prediction
        -- putStrLn "\nTest loss:"
        -- printLn test_loss
        -- putStrLn "\nTest gradient:"
        -- printLn test_gradient
