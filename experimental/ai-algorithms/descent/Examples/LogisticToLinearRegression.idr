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
        putStrLn "\nInput data:"
        printLn x
        putStrLn "\nProbability of being overpriced data:"
        printLn (overpriced_probs_data x)
        putStrLn "\nOutput data:"
        printLn y

        -- Learn model based on train data
        putStrLn ""
        putBoxedStrLn "Learning"
        let x_d : Matrix sample_size 3 Double
            x_d = map boolToDouble x
            model_ls : (ColVect 3 Double, Nat)
            model_ls = logreg x_d y eta (beta, maxsteps)
            model : ColVect 3 Double
            model = fst model_ls
            steps : Nat         -- Actual number of steps used
            steps = minus maxsteps (snd model_ls)
            x_loss : Double
            x_loss = loss x_d y model
            x_gradient : ColVect 3 Double
            x_gradient = gradient x_d y model
            y_prediction : ColVect sample_size Bool
            y_prediction = predict x_d model
        putStrLn ("\nActual number of steps used = " ++ show steps)
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nOutput prediction:"
        printLn y_prediction
        putStrLn "\nLoss:"
        printLn x_loss
        putStrLn "\nGradient:"
        printLn x_gradient

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
            xl : Matrix S 3 Bool
            xl = fst xyl
            yl : ColVect S Double
            yl = snd xyl
        putStrLn "\nLinearized input data set:"
        printLn xl
        putStrLn "\nLinearized output data:"
        printLn yl

        -- Learn model based on train data
        putStrLn ""
        putBoxedStrLn "Learning"
        let xl_d : Matrix S 3 Double
            xl_d = (map boolToDouble xl)
            model_ls : (ColVect 3 Double, Nat)
            model_ls = linreg xl_d yl eta (beta, maxsteps)
            model : ColVect 3 Double
            model = fst model_ls
            steps : Nat         -- Actual number of steps used
            steps = minus maxsteps (snd model_ls)
            xl_loss : Double
            xl_loss = loss xl_d yl model
            xl_gradient : ColVect 3 Double
            xl_gradient = gradient xl_d yl model
            yl_prediction : ColVect S Bool
            yl_prediction = predict xl_d model
        putStrLn ("\nActual number of steps used = " ++ show steps)
        putStrLn "\nModel:"
        printLn model
        putStrLn "\nLinearized output prediction:"
        printLn yl_prediction
        putStrLn "\nLinearized loss:"
        printLn xl_loss
        putStrLn "\nLinearized gradient:"
        printLn xl_gradient
