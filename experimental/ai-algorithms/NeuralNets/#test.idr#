module Main
import Data.List
main : IO ()
main = putStrLn "Hello world"

lst1 :  List String
lst1 = ["as", "the"]

lst2 : List String
lst2 = ["as", "them", "the", "here"]

ones :  Stream Nat
ones = 1 :: ones

D: Type
D = Double

LD : Type
LD = List D

LLD : Type
LLD = List LD


LLS : Type
LLS = LLD -> LD -> D

learning_rate : Type
learning_rate = D

momentum : Type
momentum = D

epsilon : Type
epsilon = D

rho : Type
rho = D

beta1 : Type
beta1 = D

beta2 : Type
beta2 = D
alpha : Type
alpha = D
m_prev : Type
m_prev = D

v_prev : Type
v_prev = D

thetas : Type
thetas = LD

gradients : Type
gradients = LD

adam : Type
adam = thetas -> gradients -> learning_rate -> epsilon -> beta1 -> beta2 -> alpha -> m_prev -> v_prev -> D

sgd : Type
sgd = learning_rate -> momentum -> D 

--compute_sgd : learning_rate -> momentum -> D
--compute_sgd lr mm = lr * mm

--fx : sgd
--fx = compute_sgd  0.0 0.9
--rmsprob : Type
--rmsprob = learning_rate -> momentum -> epsilon -> rho -> D

adadelta : Type
adadelta = learning_rate -> epsilon -> rho -> D

{-
optimFx : String -> Maybe Type
optimFx "adam" = Just adam
optimFx "sgd" =  Just sgd
optimFx "rmsprob" = Just rmsprob
optimFx "adadelta" = Just adadelta 
optimFx _ = Nothing

mk : String -> Type
mk "f" = LD
mk "t" = LLD
mk _ = LLD

compute_adam : LD  -> LD -> D -> D -> D -> D -> D -> D -> LD
compute_adam [] _ _ _ _ _ _ _ = []
compute_adam _ [] _ _ _ _ _ _ = []
compute_adam (t::ts) (gt::gts) alpha mprev vprev b1 b2 eps = do
  let m_current = (b1 * mprev + (1-b1) * gt) /(1-b1)
      v_current = (b2 * vprev + (1-b2) * (pow gt 2))/ (1-pow b2 2)
      mhat_current = m_current / (1-b1)
      vhat_current = v_current / (1-b2)
  (t - alpha * mhat_current / ((sqrt vhat_current) + eps)) :: compute_adam ts gts alpha m_current v_current b1 b2 eps

data OptimFx : String ->  Type where
  Adam : OptimFx "adam"
  Sgd : OptimFx "sgd"
  RMSprob : OptimFx "rmsprob"

tmpFx : OptimFx -> LD
tmpFx Adam = compute_adam

-}
