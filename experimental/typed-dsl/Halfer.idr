module Halfer
import Service
import System
import Numeric

%default total

-- Helpful type alias for even integers
public export
EvenNumber : Type
EvenNumber = (n : WFInt ** Parity n 2)

public export
maybeEven : Integer -> Maybe EvenNumber

-- maybeEven a with (mod a 2) proof p
--   maybeEven a | 0 = Just ((cast a) ** ModIsZero p)
--   maybeEven a | _ = Nothing


-- Run external service
public export
runHalfer : EvenNumber -> IO Integer
runHalfer = do ?run


public export
halferContract : (a : EvenNumber) -> Contract (runHalfer a) Integer
halferContract a = MkContract (runHalfer a)


public export
halferService : EvenNumber -> Service Integer
halferService a = Promise (halferContract a)
