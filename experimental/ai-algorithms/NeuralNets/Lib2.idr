module Lib2
import Data.List as L

D : Type
D = Double

LD : Type
LD = List D

LLD : Type
LLD = List LD

b : D
b = 0.03


mk : (sing : Bool)-> Type
mk False = LD
mk True =LLD

nnLayer : LD -> LD -> LD
nnLayer xs ys = L.zipWith (\x,y => x * y + b) xs ys

softmax : LD -> LD
softmax xs = let softmax_denom = sum $ map exp $ xs
             in foldr (\x, acc => (exp x)/softmax_denom::acc) [] xs


fullNNLayer : LLD -> LLD -> LLD
fullNNLayer [] _ = []
fullNNLayer _ [] = []
fullNNLayer (x::inps) (y::ws) = (softmax $ nnLayer x y ) :: fullNNLayer inps ws


ceLoss : LD -> LD -> LD
ceLoss  [] _ = []
ceLoss  _ [] = []
ceLoss  (x::xs) (y::ys) = -(y/x) + (1-y)/(1-x)::ceLoss xs ys

avg : LD -> Double
avg xs = (sum xs) / (cast $ length xs)

compute_adam : LD -> LD -> D -> D -> D -> D -> D -> D -> LD
compute_adam [] _ _ _ _ _ _ _ = []
compute_adam _ [] _ _ _ _ _ _ = []
compute_adam (t::ts) (gt::gts) alpha mprev vprev b1 b2 eps = do
  let m_current = (b1 * mprev + (1-b1) * gt) /(1-b1)
      v_current = (b2 * vprev + (1-b2) * (pow gt 2))/ (1-pow b2 2)
      mhat_current = m_current / (1-b1)
      vhat_current = v_current / (1-b2)
  t - alpha * mhat_current / ((sqrt vhat_current) + eps)::compute_adam ts gts alpha m_current v_current b1 b2 eps

compute_sgd : Double -> Double -> LD
compute_sgd = ?rhs_sgd

optimFx : String -> Maybe LD
optimFx "adam" = Just (compute_adam [0.0] [9.0] 0.01 0.09 0.08 0.2 0.3 0.4)
optimFx "sgd" = Just (compute_sgd 0.9 0.0)
optimFx _ = Nothing

lossFx : String -> Maybe Type
lossFx "ceLoss" = Just (ceLoss  )
lossFx "sgd"  = Just (compute_sgd 0.9 0.0)
lossFx _  = Nothing

record Optimizer where
  constructor OptimFx
  fx : optimFx 
  thetas, gradients : LLD
  alpha, mprev, vprev, beta1, beta2, epsilon, momentum, rho : D

record LossFx where
  constructor CreateFx
  fx :  lossFx
  pred : LD
  exp : LD


record Model where
  constructor Create
  weights, inputs, targets : LLD
  alpha, beta1, beta2, epsilon : D
  iter : Int
  loss : LossFx
  optim : Optimizer



--totalcost : LossFx -> String -> LLD -> LLD -> D
--totalcost loss xs ys = let tmp = zipWith (\x,y => avg $ loss.fx x y ) xs ys
--                     in avg tmp


{- 

totalcost : LossFx -> LLD -> LLD -> D
totalcost loss xs ys = let tmp = zipWith (\x,y => avg $ loss.fx x y ) xs ys
                     in avg tmp
optimizer : Optimizer -> LLD -> LLD -> D -> D -> D -> D -> D -> D -> LLD
optimizer  _ [] _ _ _ _ _ _ _ = []
optimizer _ _ [] _ _ _ _ _ _ = []
optimizer f (ws::wss) (cs::costs) alpha m v beta1 beta2 epsilon = 
(f ws cs alpha m v beta1 beta2 epsilon) :: optimizer f wss costs alpha m v beta1 beta2 epsilon

-}
---------------------------------------------This part should be in Main---------------------
weights : LLD
weights = [[0.4 ,0.6]]
ws : LD
ws = [0.4 ,0.9]
pres : LD
pres = [9.0, 2.3]
inputs : LLD
inputs = [[0.4 ,0.6]]


tars : LLD
tars = [[0.4 ,0.6]]
alpha : D
alpha = 0.8
beta1 : D
beta1 = 0.9
beta2 : D
beta2 = 0.8
epsilon : D
epsilon = 0.7
iter: Int
iter = 2


loss : LossFx
loss = CreateFx (lossFx "ceLoss") ws pres


optim : Optimizer
optim = OptimFx  (optimFx "adam") [[0.0]] [[9.0]] 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 
{-
model_1: Model

model_1 = Create weights inputs tars 0.8 0.9 0.8 0.7 2 loss optim

model : Model -> LLD
model m = case m.iter == 0 of
               True => m.weights
               False => do
                 let pred = fullNNLayer m.inputs m.weights 
                 let costs = totalcost $ m.loss  pred m.targets
                 let n_wght = optimizer m.optim m.weights costs m.alpha 0.0 0.0 m.beta1 m.beta2 m.epsilon
                 let mdl = record { 
                                  weights = m_wght, 
                                  inputs = m.inputs, 
                                  targets = m.targets, 
                                  alpha = m.alpha, 
                                  beta1 = m.beta1, 
                                  beta2 = m.beta2, 
                                  epsilon = m.epsilon, 
                                  iter  = m.iter - 1, 
                                  loss = m.loss, 
                                  optim = m.optim }
                 model mdl

                 -}
