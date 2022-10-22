module TypeRelations

import Data.Vect

%default total





public export
data Inverse : (a -> b) -> (b -> a) -> Type where
     Inverts : {f : (a -> b)} -> {g : (b -> a)} -> ( p : (f (g x)) = x ) -> Inverse f g
     Reverse : Inverse f g -> Inverse g f


public export
data Subset : Type -> Type -> Type where
     Contains : (f : a -> b) -> (fi : b -> a) -> (p : Inverse f fi) -> Subset a b
