module Lib
import Types


public export
calculateDeltas : (Double,Double) -> (Double, Double) -> Double
calculateDeltas (t0, t1) (x, y) = t0 + t1 * x-y



avg : List Double -> Double
avg [] = 0.0
avg xs = do
  let x = length xs
  let y = natToInteger x
  let z = fromInteger y
  (sum xs) / z



getmult: List Double -> List Double -> List Double
getmult [] [] = []
getmult (x::xs) [] = (x::getmult xs [])
getmult [] (y::ys) = (y::getmult [] ys)
getmult (x::xs) (y::ys) = (x * y :: getmult xs ys)

public export
adjustDeltas : List Double -> List (Double,Double) -> List Double
adjustDeltas deltas examples =
  let xs = (map (\(x,y) => x) examples)
--      zipped = zip deltas xs
--  in getmult deltas  xs
  in  getmult deltas xs

public export
newthetas : (Double, Double) -> Double -> List (Double, Double) ->  (Double, Double)
newthetas thetas alpha examples =  
  let deltas = (map (calculateDeltas thetas) examples)   
      adjusted = adjustDeltas deltas examples
      t0 = fst thetas
      t1 = snd thetas
      newt0 = t0 - alpha * avg deltas 
      newt1 = t1 - alpha * avg adjusted 
  in (newt0, newt1)

public export
linearRegression : (Double, Double) -> Double ->List (Double, Double) -> Int -> (Double, Double)
linearRegression coefficients alpha dataset iterations =
 case iterations == 0 of
      True => coefficients
      False => let thetas = newthetas coefficients alpha dataset in linearRegression thetas alpha dataset (iterations -1)
