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


g_index : String -> Nat
g_index x = (\(Just i) => i ) $ elemIndex x stopwords 

createDictionary : List String ->  List (String, Nat)
createDictionary xss = func 0 tmp 
              where
                tmp = sort . nub $ xss
                func : Nat -> List String -> List (String, Nat)
                func _ [] = []
                func Z (x::xs) = (x, S Z) :: func (S (S Z)) xs
                func (S k) (x::xs) = (x, S k) :: func (S (S k) ) xs


main : IO ()
main = do
  let sample_data ="Hello tge is a not will be happy. the Hello the a and is . ME is will not try to be"
  let cleaned = removeStopWords sample_data
  let paired = makeWordPairs cleaned
  let dict = createDictionary cleaned
  print cleaned

  print $ dict
