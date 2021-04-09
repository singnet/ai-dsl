module Main
import Lib
import Prelude.List as lst

dataset : List String
dataset = [ "The future king is the prince", 
           "Daughter is the princess.",
           "Son is the prince.",
           "Only a man can be a king",
           "Only a woman can be a queen",
           "The princess will be a queen",
           "Queen and king rule the realm",
           "The prince is a strong man",
           "The princess is a beautiful woman",
           "The royal family is the king and queen and their children",
           "Prince is only a boy now",
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

ran : List Double
ran = replicate (length $ get_indices input dict) 0.06

xss_index : List Nat
xss_index = get_indices input dict

yss_index : List Nat
yss_index = get_indices target dict

main : IO ()
main = do
   --let cleaned = rawToCleaned dataset
   --let paired = makeWordPairs cleaned
   --let dict = createDictionary cleaned
   --let input = xss paired
   --let target = yss paired
   --let zs = zeros cleaned dict
    let gen_ws = matrix_gen ran zs
    let y_encode = oneHotEncoder yss_index zs
    let x_encode = oneHotEncoder xss_index zs

--  let index : String -> Nat
--  in index x = (\(Just i) => i ) $ lookup x dict
                                                   
--  let get_indices : List String -> List Nat
--  in get_indices vocabs = foldr (\x, acc => (index x) :: acc ) [] vocabs
--  print $ paired
--   print $ length zs
    print $ length $ gen_ws



