module Main
import Lib
import Prelude.List as lst
import Data.List

dataset : List String
dataset = [ "The future king is the prince", 
--           "Daughter is the princess.",
--           "Son is the prince.",
--           "Only a man can be a king",
--           "Only a woman can be a queen",
--           "The princess will be a queen",
--           "Queen and king rule the realm",
--           "The prince is a strong man",
--           "The princess is a beautiful woman",
--           "The royal family is the king and queen and their children",
--           "Prince is only a boy now",
           "A boy will be a man"]

index : String -> List (String, Nat) ->  Nat
index x dict = (\(Just i) => i ) $ lookup x dict

get_indices : List String -> List (String,Nat) -> List Nat
get_indices vocabs dict = foldr (\x, acc => (index x  dict)::acc) [] vocabs

zeros : List String -> List (String, Nat) -> List Double
zeros vocabs dict = replicate ( lst.length $ get_indices vocabs dict ) 0

cleaned : List String
cleaned = rawToCleaned dataset

paired : List (String, String)
paired = makeWordPairs cleaned

dict : List (String,Nat)
dict = createDictionary cleaned

input : List String
input = xss paired

target : List String
target = yss paired

zs : List Double
zs = zeros cleaned dict

ran_wht : List Double
ran_wht = replicate (length $ get_indices input dict) 0.06

xss_index : List Nat
xss_index = get_indices input dict

yss_index : List Nat
yss_index = get_indices target dict

weights : List (List Double)
weights = matrix_gen ran_wht zs

en_inputs : List (List Double)
en_inputs = oneHotEncoder xss_index zs

en_targets : List  (List Double)
en_targets = oneHotEncoder yss_index zs

bias : Double
bias = 0.3

-- TODO insertAt inserts extra zeros
main : IO ()
main = let classifier = model weights en_inputs en_targets 0.001 0.9 0.999 0.00000001 2
       in print $ classifier

