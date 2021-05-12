module Lib2

import Data.List as L

D : Type
D = Double

LD : Type
LD = List D

LLD : Type
LLD = List LD

-- default value of base 
b : D
b = 0.03

fullNNLayer : LLD -> LLD -> LLD
fullNNLayer [] _ = []
fullNNLayer _ [] = []
fullNNLayer (x::inps) (y::ws) = (softmax $ nnLayer x y ) :: fullNNLayer inps ws

nnLayer : LD -> LD -> LD
nnLayer xs ys = L.zipWith (\x,y => x * y + b) xs ys

softmax : LD -> LD
softmax xs = let softmax_denom = sum $ map exp $ xs
             in foldr (\x, acc => (exp x)/softmax_denom::acc) [] xs

ceLoss : LD -> LD -> LD
ceLoss  [] _ = []
ceLoss  _ [] = []
ceLoss  (x::xs) (y::ys) = -(y/x) + (1-y)/(1-x)::ceLoss xs ys

adam : LD -> LD -> D ->  D -> D -> D -> D -> D -> LD

adam [] _ _ _ _ _ _ _ = []
adam _ [] _ _ _ _ _ _ = []
adam (t::thetas) (gt::gts) alpha m_prev v_prev beta1 beta2 epsilon = do
  let m_current = (beta1 * m_prev + (1-beta1) * gt) /(1-beta1)
      v_current = (beta2 * v_prev + (1-beta2) * (pow gt 2))/ (1-pow beta2 2)
      mhat_current = m_current / (1-beta1)
      vhat_current = v_current / (1-beta2)
  (t - alpha * mhat_current / ((sqrt vhat_current) + epsilon)) :: adam thetas gts alpha m_current v_current beta1 beta2 epsilon
      
optimizer : (LD -> LD -> D -> D -> D -> D ->D -> D -> LD) -> 
            LLD -> LLD -> D -> D -> D -> D -> D -> D -> LLD

optimizer f [] _ _ _ _ _ _ _ = []
optimizer f _ [] _ _ _ _ _ _ = []
optimizer f (ws::wss) (cs::costs) alpha m v beta1 beta2 epsilon = 
  (f ws cs alpha m v beta1 beta2 epsilon) :: optimizer f wss costs alpha m v beta1 beta2 epsilon

record LossFx where
  constructor CreateFx
  fx : LD -> LD -> LD
--  preds, targets : LLD

record Optimizer {a : D} where
  constructor OptimFx
  fx : LD -> LD -> D -> D -> D -> D -> D -> D -> LD
  weights , costs : LLD
  alpha, m, v, beta1, beta2, epsilon : D

record Model where
  constructor Create
  weights, inputs, targets : LLD
  alpha, beta1, beta2, epsilon : D
  iter : Int

