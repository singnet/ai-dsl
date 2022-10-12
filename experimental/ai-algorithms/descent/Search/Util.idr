module Search.Util

import System.Random
import Data.String
import Data.Vect
import Data.SortedMap
import Data.Counter
import Data.Matrix

-------------------------------------
-- Miscellaneous utility functions --
-------------------------------------

-- TODO: it should probably be sorted out and split into different
-- modules, because not all functions here belong to the Search
-- category.

||| Access the second element of a triple
public export
tnd : (a, b, c) -> b
tnd = fst . snd

||| Access the third element of a triple
public export
trd : (a, b, c) -> c
trd = snd . snd

||| Cast a Bool into a Double
|||
||| False -> 0.0
||| True -> 1.0
|||
||| Not using the cast interface as it is not necessarily conventional.
public export
boolToDouble : Bool -> Double
boolToDouble False = 0.0
boolToDouble True = 1.0

||| Cast a Double into a Bool
|||
||| 0.0 -> False
||| _ -> True
|||
||| Not using the cast interface as it is not necessarily conventional.
public export
doubleToBool : Double -> Bool
doubleToBool 0.0 = False
doubleToBool _ = True

||| Akin to an indicator function, i.e. point-wise cast a container of
||| boolean values to a container of double values using boolToDouble.
public export
indicator : Functor f => f Bool -> f Double
indicator = map boolToDouble

||| Clamp to fit a closed interval
|||
||| For instance
|||
||| clamp (0.1, 0.9) 0.5 = 0.5
||| clamp (0.1, 0.9) 1.0 = 0.9
||| clamp (0.1, 0.9) 0.0 = 0.1
|||
||| Note that if l is greater than u in
|||
||| clamp (l, u)
|||
||| the behavior should be considered undefined.
public export
clamp : Ord a => (a, a) -> a -> a
clamp (l, u) x = max l (min u x)

||| Logistic function
|||
||| l / (1 + exp(-k*(x-x0)))
|||
||| @x0 the value of the sigmoid's midpoint
||| @l the curve's maximum value
||| @k k, the logistic growth rate or steepness of the curve
||| @x the input value
public export
logistic : Double -> Double -> Double -> Double -> Double
logistic x0 l k x = l / (1.0 + exp(-k*(x-x0)))

||| Standard logistic function
|||
||| 1 / (1 + exp(-x))
|||
||| @x the input value
public export
expit : Double -> Double
expit = logistic 0 1 1

||| Inverse of the expit function.  Take a probability and return the
||| corresponding odds.
|||
||| log(p / (1 - p))
|||
||| @epsilon small value to add/remove to/from p to guaranty p ∈ (0, 1)
||| @p probability
public export
logit : Double -> Double -> Double
logit epsilon p = let l = epsilon
                      u = 1.0 - epsilon
                      np = 1.0 - p
                      cp = clamp (l, u) p
                      cnp = clamp (l, u) np
                  in log(cp / cnp)

||| Given positive and negative counts, calculate the mean of the
||| corresponding posterior Beta distribution, assuming a Jeffrey's
||| prior.
|||
||| @poscnt positive count
||| @negcnt negative count
public export
betaMean : Integer -> Integer -> Double
betaMean poscnt negcnt = let a : Double
                             a = 0.5 + (cast poscnt)
                             b : Double
                             b = 0.5 + (cast negcnt)
                         in a / (a + b)

||| Given positive and negative counts, calculate the odds of the mean
||| of the corresponding posterior Beta distribution, assuming a
||| Jeffrey's prior.
|||
||| @epsilon to make sure the probability is within [epsilon, 1 - epsilon]
||| @poscnt positive count
||| @negcnt negative count
public export
betaOdds : Double -> Integer -> Integer -> Double
betaOdds epsilon poscnt negcnt = logit epsilon (betaMean poscnt negcnt)

||| Turn a Bernoulli histogram into an estimate of the odds, assuming
||| an underlying Beta distribution.
|||
||| @c counter representing a Bernoulli histogram
public export
bernoulliHistToOdds : Counter Bool Integer -> Double
bernoulliHistToOdds c = betaOdds 1.0e-128 (lookup True c) (lookup False c)

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
public export
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
public export
logToLinData : (x : Matrix m n Bool) ->
               (y : ColVect m Bool) ->
               (m' : Nat ** (Matrix m' n Bool, ColVect m' Double))
logToLinData x y =
  let -- Build a conditional histogram from X and Y
      cds : SortedMap (Vect n Bool) (Counter Bool Integer)
      cds = condHist x y
      -- Build Xᴸ and Yᴸ from that conditional histogram
      xyl : List (Vect n Bool, Double)
      xyl = map (mapSnd bernoulliHistToOdds) (toList cds)
  in (length xyl ** bimap MkMatrix toColVect (unzip (fromList xyl)))

||| Cross entropy between 2 Bernoulli distributions: -p*log(q) - (1-p)*log(1-q)
public export
bernoulliCrossEntropy : Double -> Double -> Double
bernoulliCrossEntropy p q =
  -- The following shenanigan is to avoid nan and inf
  let epsilon = 1.0e-320
      l = epsilon
      u = 1.0 - epsilon
      i = (l, u)
      np = 1.0 - p
      nq = 1.0 - q
      cq = clamp i q
      cnq = clamp i nq
      in if p < epsilon
         then -np*log(cnq)
         else if np < epsilon
              then -p*log(cq)
              else -p*log(cq) - np*log(cnq)

||| Generate a random sampler for Boolean value distributed according
||| to a Bernoulli distribution of parameter p.
public export
bernoulliSample : Double -> IO Bool
bernoulliSample p = map (< p) randomIO

||| Wrap a given one-liner message in a box and send to stdout.
public export
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

----------
-- Test --
----------

-- Test clamp
I : (Double, Double)
I = (0.1, 0.9)

clamp_m_test : clamp I 0.5 === 0.5
clamp_m_test = Refl

clamp_l_test : clamp I 0.0 === 0.1
clamp_l_test = Refl

clamp_u_test : clamp I 1.0 === 0.9
clamp_u_test = Refl

-- Test logToLinData
X : Matrix 8 2 Bool
X = MkMatrix [[False, False],
              [False, True],
              [True, False],
              [True, True],
              [False, False],
              [False, True],
              [True, False],
              [True, True]]
Y : ColVect 8 Bool
Y = toColVect [True, False, False, True, False, False, True, True]

nl_XYL : (nl : Nat ** (Matrix nl 2 Bool, ColVect nl Double))
nl_XYL = logToLinData X Y

N : Nat
N = fst nl_XYL

XYL : (Matrix N 2 Bool, ColVect N Double)
XYL = snd nl_XYL

XL : Matrix N 2 Bool
XL = fst XYL

YL : ColVect N Double
YL = snd XYL

-- Expected XL and YL
XL_expect : Matrix 4 2 Bool
XL_expect = MkMatrix [[False, False],
                      [False, True],
                      [True, False],
                      [True, True]]

YL_expect : ColVect 4 Double
YL_expect = toColVect [0.0, -1.6094379124341005, 0.0, 1.6094379124341007]

-- TODO: compiling error
-- XL_eq_test : XL === XL_expect
-- XL_eq_test = Refl

print_XYL : IO ()
print_XYL = do printLn X
               printLn Y
               printLn XL
               printLn YL
