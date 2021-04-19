module Service
%default total


||| Placeholder description of a smart contract
public export
data Contract : IO t -> Type -> Type where
     MkContract : (a : IO b) -> Contract a b

public export
trustContract : Contract a b -> b

||| Abstract Syntax Tree for the Service DSL
public export
data Service : Type -> Type where
     ||| A Service that is definitely of type `a`
     Val     : a -> Service a
     ||| A contract has promised a reward if `a` is not a Service b
     Promise : Contract a b ->  Service b
     ||| Application of a Service to another Service
     App     : Service (a -> b) -> Service a -> Service b
     ||| Explicitly construct a Service using monadic binding
     Bind    : Service a -> (a -> Service b) -> Service b


public export
Functor Service where
        map f (Val a) = Val $ f a
        map f (Promise c) = Val $ f $ trustContract c  --TODO It might be better to never allow Vals to be made from Promises
        map f s = App (Val f) s



public export
Applicative Service where
            pure = Val
            (<*>) = App


public export
Monad Service where
      (>>=) = Bind
      join m = !m
