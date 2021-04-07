import Prelude.Strings as str
stopwords : List String
stopwords = ["the", "a", "and", "is", "be", "will", "is"] 
nums : String
nums = "0123456789!@#$%^&*()_+=-:;"

removeStopWords : String -> List String
removeStopWords line = do
              let tmp = words line
              foldr (\x, acc => if elem x stopwords then acc else x::acc ) [] tmp


makeWordPairs : List String -> List (String, String)
makeWordPairs [] = []
makeWordPairs (x::y::z::h::xs) = (x,y)::(x,z)::(y,z)::(y,h)::(z,x)::(z,y)::(z,h)::(h,x)::(h,y)::(h,z)::makeWordPairs xs
makeWordPairs (x::y::z::xs) = (x,y)::(x,z)::(y,z)::(z,x)::(z,y)::makeWordPairs xs
makeWordPairs (x::y::xs) = (x,y)::makeWordPairs xs


createDictionary : List String ->  List (String, Nat)
createDictionary xss = func 0 tmp 
              where
                tmp = sort . nub $ xss
                func : Nat -> List String -> List (String, Nat)
                func _ [] = []
                func Z (x::xs) = (x, S Z) :: func (S (S Z)) xs
                func (S k) (x::xs) = (x, S k) :: func (S (S k) ) xs



--index : String -> Nat
--index x = (\(Just i) => i ) $ lookup x dict

--get_indices : List String -> List Nat
--get_indices vocabs = foldr (\x, acc => (index x) :: acc ) [] vocabs

insertAt : List String -> String -> Int -> List String
insertAt [] elem pos = elem::[]
insertAt (x::xs) elem  0 = elem::x::xs
insertAt (x::xs) elem 1 = x::elem::xs
insertAt (x::xs) elem pos = x::insertAt xs elem (pos - 1 ) 

matrix_gen :Num j =>  List j -> List j -> List (List j) 
matrix_gen ws zs = foldr (\x, acc => zs::acc) [] ws

b : Double
b = 0.3
nn_Layer : List Double -> List Double -> List Double
nn_Layer [] _ = []
nn_Layer _ [] = []
nn_Layer [] [] = []
nn_Layer (x::xs) (y::ys) = (x * y + b)::nn_Layer xs ys


softmax_activation : List Double -> List Double
softmax_activation xs = let softmax_denom = sum $ map exp $ xs 
in foldr (\x,acc => (exp x)/softmax_denom::acc) [] xs

grad_CrossEntropy : List Double -> List Double -> List Double
grad_CrossEntropy [] _ = []
grad_CrossEntropy _ [] = []
grad_CrossEntropy [] [] = []
grad_CrossEntropy (x::xs) (y::ys) = -(y/x) + (1-y)/(1-x)::grad_CrossEntropy xs ys

main : IO ()
main = do
  let sample_data ="Hello tge is a not will be happy. the Hello the a and is . ME is will not try to be"
  let cleaned = removeStopWords sample_data
  let paired = makeWordPairs cleaned
  let dict = createDictionary cleaned
  let test1 = insertAt cleaned "me" 7
  print test1
  print cleaned
  print $ dict
