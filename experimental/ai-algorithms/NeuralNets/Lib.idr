module Lib
import Prelude.Doubles as db

|||TODO functions not using foldr probably reverses order of elements in a list

export
stopwords : List String
stopwords = ["the", "a", "and", "is", "be", "will", "is"] 

export
nums : String
nums = "0123456789!@#$%^&*()_+=-:;"

export
removeStopWords : String -> List String
removeStopWords line = filter (not . ((flip elem) stopwords)) (words line)

             
||| makeWordPairs creates a list of pairs consisting of words from 
||| some context n to the left of the focus word and n right to the 
||| focus word e.g let str = "The prince is the future king"
||| where n = 2 focus word is The we have (The, prince) (The, is)  
||| where n = 2 focus word is prince we have (prince, The), (prince, is), (prince, the)....so on 
export
makeWordPairs : List String -> List (String, String)
makeWordPairs [] = []
makeWordPairs (x::y::z::h::xs) = (x,y)::(x,z)::(y,z)::(y,h)::(z,x)::(z,y)::(z,h)::(h,x)::(h,y)::(h,z)::makeWordPairs xs
makeWordPairs (x::y::z::xs) = (x,y)::(x,z)::(y,z)::(z,x)::(z,y)::makeWordPairs xs
makeWordPairs (x::y::xs) = (x,y)::makeWordPairs xs


||| createDictionary takes a List of Strings i.e List of Sentences  and then produce a dictonary of word to num
||| e.g ("some_word", 12) keeping only the unique words in the List and  sorting them. 
export
createDictionary : List String ->  List (String, Nat)
createDictionary xss = func 0 tmp 
              where
                tmp = sort . nub $ xss
                func : Nat -> List String -> List (String, Nat)
                func _ [] = []
                func Z (x::xs) = (x, S Z) :: func (S (S Z)) xs
                func (S k) (x::xs) = (x, S k) :: func (S (S k) ) xs



||| This is a utility function. Allows inserting 1 at any given index
||| used by oneHotEncoder
insertAt : List Double -> Double -> Nat -> List Double
insertAt [] elem pos = []
insertAt (x::xs) elem  Z = elem::x::xs
insertAt (x::xs) elem (S Z) = x::elem::xs
insertAt (x::xs) elem (S k) = x::insertAt xs elem k 

export
oneHotEncoder : List Nat -> List Double -> List (List Double)
oneHotEncoder ws zs = foldr(\x, acc => (insertAt zs 1.0 x)::acc) [] ws

export
matrix_gen : Num j =>  List j -> List j -> List (List j )
matrix_gen ws zs = foldr (\x, acc => zs::acc) [] ws

b : Double
b = 0.3

export
wordpairs : List String -> List (String,String)
wordpairs wrds = makeWordPairs wrds

export
xss : List (String, String) -> List String
xss wordpairs = map (\(a,b) => a ) wordpairs

export
yss : List (String,String) -> List String
yss wordpairs = map (\(a,b) => b ) wordpairs


export
wordify : List String -> List String
wordify [] = []
wordify (fst::xss) = words fst ++ wordify xss


export
rawToDict : List String -> List (String,Nat)
rawToDict [] = []
rawToDict dataset = let some_var = wordify dataset
                    in createDictionary some_var

export
rawToCleaned : List String -> List String
rawToCleaned [] = []
rawToCleaned (x::xs) = let some_var = removeStopWords x
                       in some_var ++ rawToCleaned xs
export
nn_Layer : List Double -> List Double -> List Double
nn_Layer [] _ = []
nn_Layer _ [] = []
nn_Layer (x::xs) (y::ys) = (x * y + b)::nn_Layer xs ys

--idris code for Softmax activation
export
softmax_activation : List Double -> List Double
softmax_activation xs = let softmax_denom = sum $ map exp $ xs 
in foldr (\x,acc => (exp x)/softmax_denom::acc) [] xs

--idris code for Cross Entropy loss
export
grad_CrossEntropy : List Double -> List Double -> List Double
grad_CrossEntropy [] _ = []
grad_CrossEntropy _ [] = []
grad_CrossEntropy (x::xs) (y::ys) = -(y/x) + (1-y)/(1-x)::grad_CrossEntropy xs ys

-- idris code for Adam's optimizer
export
adam_Optimizer : List Double -> List Double -> Double -> Double -> Double -> Double -> Double -> Double -> List Double
adam_Optimizer [] _ _ _ _ _ _ _ =  []
adam_Optimizer _ [] _ _ _ _ _ _ =  []
adam_Optimizer (t::thetas) (gt::gts) alpha m_prev v_prev beta1 beta2 epsilon = do
              let m_current = (beta1 * m_prev + (1-beta1) * gt)/ (1-beta1)
              let v_current = (beta2 * v_prev + (1-beta2) *  (db.pow gt 2))/(1-(db.pow beta2 2))
              let mhat_current = m_current /(1-beta1)
              let vhat_current = v_current/(1-beta2)
              (t - alpha * mhat_current / ((sqrt  vhat_current) + epsilon)):: adam_Optimizer thetas gts alpha m_current v_current beta1 beta2 epsilon


export
fullNNLayer : List (List Double) -> List (List Double) -> List (List Double)
fullNNLayer [] [] = []
fullNNLayer (x::inputs) (y::weights) = (softmax_activation $ nn_Layer x y)::fullNNLayer inputs weights


||| loss_func is a generic function to compute the loss or the cost of all weights learned. Given we have 
||| any loss function implemented here we can pass it to this loss_func. The purpose of this function is to
||| provide multiple options for loss functions as opposed to just the Cross entropy loss implemented above
export
loss_func : (List Double -> List Double -> List Double ) -> List (List Double) -> List (List Double) -> List (List Double)
loss_func f [] _ = []
loss_func f _ [] = []
loss_func f (p::preds) (t::targets) = f p t :: loss_func f preds targets


||| optimizer is a generic function to compute weights. so far only Adam optimzer is implemented
||| But one can write the SGD RMSprob and other optimizers and then pass them via this function.
export
optimizer : ( List Double -> List Double -> Double -> Double -> Double -> Double -> Double -> Double -> List Double) -> List (List Double) -> List (List Double) -> Double -> Double -> Double -> Double -> Double -> Double -> List (List Double)
optimizer f [] _ _ _ _ _ _ _ = []
optimizer f _ [] _ _ _ _ _ _ = []
optimizer f (ws::wss) (cs::costs) alpha  m v beta1 beta2 epsilon =  (f ws cs alpha m v beta1 beta2 epsilon) :: optimizer f wss costs alpha m  v beta1 beta2 epsilon


||| model is called to start the training given all parameters i.e number of iterations learning rate
||| alpha beta1 beta2 epsilon the weights which at first will be initialized to some random values
||| the input is Xs in a dataset of (x,y) where as the targets are the Ys.
export
model : List (List Double) -> List (List Double) -> List (List Double) -> Double -> Double -> Double -> Double -> Int -> List (List Double )
model [] _ _ _ _ _ _ _ = []
model _ [] _ _ _ _ _ _ = []
model _ _ [] _ _ _ _ _ = []
model weights inputs targets alpha beta1 beta2 epsilon iterations = case iterations == 0 of                         
                                              True => weights
                                              False => do
                                                  let predicted = fullNNLayer inputs weights
                                                  let full_cost = loss_func grad_CrossEntropy predicted targets 
                                                  let new_weights = optimizer adam_Optimizer weights full_cost alpha 0.0 0.0 beta1 beta2 epsilon 
                                                  model new_weights inputs targets alpha beta1 beta2 epsilon (iterations - 1)



