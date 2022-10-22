module Search

import Control.Monad.State.Interface
import Control.Monad.Maybe
import Control.Monad.RWS.CPS

import Utils

%default total











||| SearchT is a monad transformer that allows a monad to 'propose' new values,
||| starting from a continuation if a proposed value is rejected.
public export
data SearchT : Type -> (Type -> Type) -> Type -> Type where
     -- MkSearchResult : Monad m => (RWST r (List (m a)) st) m a -> SearchT st m a
     MkSearchResult : Monad m => List (m a) -> st -> SearchT st m a



public export
implementation MonadTrans (SearchT st) where
               lift = ?mtst


public export
implementation Monad m => MonadState ((SearchT st) m) where
               get = lift get
               put = lift . put
               state = lift . state
