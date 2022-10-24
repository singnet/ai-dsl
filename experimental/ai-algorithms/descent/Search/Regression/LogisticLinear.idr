module Search.Regression.LogisticLinear

import Data.Matrix
import Search.Regression.Linear
import Search.Util

---------------------------------------
-- Define Logistic-Linear Regression --
---------------------------------------

-- Logistic-Linear Regression aims at achieving logistic regression by
-- reframing the problem as a linear regression problem.
--
-- In order to do so, the data set must have both boolean inputs and
-- outputs (although in general it could use categorical variables as
-- well) as to be able to extract an estimate of the odds of the
-- outcome to be able to map the data set to be suited for linear
-- regression.

||| Loss function obtained by reframing the data set to be suited for
||| linear regression.  This is not required by
||| logisticLinearRegression, but is useful to have for debugging.
public export
llLoss : (x : Matrix m n Bool) ->
       (y : ColVect m Bool) ->
       (beta : ColVect n Double) ->
       Double
llLoss x y = let (m' ** (xl, yl)) = logToLinData x y
              in linLoss (map boolToDouble xl) yl

||| Gradient function obtained by reframing the data set to be suited
||| for linear regression.  This is not required by
||| logisticLinearRegression, but is useful to have for debugging.
public export
lingradient : {n : Nat} ->
              (x : Matrix m n Bool) ->
              (y : ColVect m Bool) ->
              (beta : ColVect n Double) ->
              (ColVect n Double)
lingradient x y = let (m' ** (xl, yl)) = logToLinData x y
                  in linGradient (map boolToDouble xl) yl

||| Logistic-Linear Regression.  Given
|||
||| 1. an input data set x, a Boolean matrix,
||| 2. its corresponding output y, a Boolean vector,
||| 3. a learning rate eta
||| 4. and initial model beta
|||
||| return a model β' so that expit(x*β') approximates the
||| probabilities of the outcomes of y.  The returned model is
||| discovered using linear regression by transforming the data set so
||| that redundant input vectors are collapsed into a single vector
||| and their corresponding outputs are collapsed into an estimate of
||| their odds.
|||
||| @x Matrix of size m*n, samples size m, n input variables
||| @y Column vector of size m
||| @eta learning rate, small positive value
||| @beta_steps initial model and number of steps allocated
public export
logisticLinearRegression : {n : Nat} ->
                           (x : Matrix m n Bool) ->
                           (y : ColVect m Bool) ->
                           (eta : Double) ->
                           (beta_steps : (ColVect n Double, Nat)) ->
                           (ColVect n Double, Nat)
logisticLinearRegression x y = let (m' ** (xl, yl)) = logToLinData x y
                               in linearRegression (map boolToDouble xl) yl

||| Proof that the candidate returned by linear regression is better
||| or equal to the initial candidate.
public export
logisticLinearRegression_le : {n : Nat} ->
            (x : Matrix m n Bool) ->
            (y : ColVect m Bool) ->
            (eta : Double) ->
            (beta_steps : (ColVect n Double, Nat)) ->
            ((llLoss x y (fst (logisticLinearRegression x y eta beta_steps))) <=
             (llLoss x y (fst beta_steps))) === True
-- NEXT: fix error
logisticLinearRegression_le x y = believe_me ()
-- logisticLinearRegression_le x y = let (m' ** (xl, yl)) = logToLinData x y
--                                   in linearRegression_le (map boolToDouble xl) yl
