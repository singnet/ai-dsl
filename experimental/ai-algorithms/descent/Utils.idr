module Utils

import System.Random
import Data.String

-------------------------------------
-- Miscellaneous utility functions --
-------------------------------------

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
clamp : Ord a => (a, a) -> a -> a
clamp (l, u) x = max l (min u x)

||| Cast a Bool into a Double
|||
||| False -> 0.0
||| True -> 1.0
|||
||| Not using the cast interface as it is not necessarily unconventional.
public export
boolToDouble : Bool -> Double
boolToDouble False = 0.0
boolToDouble True = 1.0

||| Akin to an indicator function, i.e. point-wise cast a container of
||| boolean values to a container of double values using boolToDouble.
public export
indicator : Functor f => f Bool -> f Double
indicator = map boolToDouble

||| Cross entropy between 2 Bernoulli distributions: p*log(q) + (1-p)*log(1-q)
public export
bernoulliCrossEntropy : Double -> Double -> Double
bernoulliCrossEntropy p q = p*log(q) + (1 - p)*log(1 - q)

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
