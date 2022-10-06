module Examples.LogisticToLinearRegression

import System.Random
import Data.String
import Data.Vect
import Data.SortedMap
import Data.Matrix
import Data.Counter
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

||| Given
|||
||| 1. a matrix, X, representing an input data,
|||
||| 2. a column vector, Y, representing its corresponding output,
|||
||| return a sorted map representing the empirical conditional
||| distribution P(Y|X).  More specifically, a mapping from each
||| unique input to a histogram built from its corresponding outputs.
|||
||| @x input matrix
||| @y output column vector
condHist : Ord a => Matrix m n a -> ColVect m a ->
            SortedMap (Vect n a) (Counter a Integer)
condHist x y = let -- Zip x and y
                   xy : Vect m (Vect n a, a)
                   xy = zip x.vects (map head y.vects)
                   -- Build mapping from unique Xᵢ to a histogram
                   -- of its distribution of Yᵢs.
                   acchist : (Vect n a, a) ->
                             SortedMap (Vect n a) (Counter a Integer) ->
                             SortedMap (Vect n a) (Counter a Integer)
                   acchist (xi, yi) acc =
                     case lookup xi acc of
                          Just c => insert xi (insert yi c) acc
                          Nothing => insert xi (singleton yi) acc
               in foldr acchist empty xy

||| Turn a Bernoulli histogram into an estimate of the odds, assuming
||| an underlying Beta distribution.
bernoulliHistToOdds : Counter Bool Integer -> Double
bernoulliHistToOdds c = betaOdds 1.0e-128 (lookup True c) (lookup False c)

||| Transform a pair (X, Y) of Boolean input matrix X and its Boolean
||| output vector Y into a pair (Xᴸ, Yᴸ) of Boolean input matrix Xᴸ
||| and its corresponding odds/logit vector Yᴸ.
|||
||| Xᴸ is a deduplicated version of X.
|||
||| Yᴸ represents an estimates of the odds of Y being true knowing its
||| corresponding input.  Such estimate is calculated by taking the
||| mean of the posterior Beta distribution given the positive and
||| negative counts of the Boolean outcomes from Y for a particular
||| input.
|||
||| An alternative to taking the mean could be to sample the posterior
||| Beta distribution as a way to tranfer the varying uncertainties
||| from the counts.  Here though since the input is sampled unformly
||| it shouldn't matter, but for a real data set it may.  The downside
||| of that approach is that it may substantially increase the size of
||| the dataset.  On the contrary, taking the mean tends to decrease
||| it.
logToLinData : (x : Matrix m n Bool) ->
               (y : ColVect m Bool) ->
               (m' ** (Matrix m' n Bool, ColVect m' Double))
logToLinData x y =
  let -- Build a conditional histogram from X and Y
      cds : SortedMap (Vect n Bool) (Counter Bool Integer)
      cds = condHist x y
      -- Build Xᴸ and Yᴸ from that conditional histogram
      xyl : List (Vect n Bool, Double)
      xyl = map (mapSnd bernoulliHistToOdds) (toList cds)
  in (length xyl ** bimap MkMatrix toColVect (unzip (fromList xyl)))

-- ||| Alternative signature for logToLinData, in case it turns out to be better
-- logToLinData : (x : Matrix m n Bool) ->
--                (y : ColVect m Bool) ->
--                (Matrix (countUniqRows x) n Bool, ColVect (countUniqRows x) Double)
-- logToLinData x y = ?logToLinData_rhs
