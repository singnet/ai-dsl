module Halfer
import Service
import System
import Numeric

%default total

public export
EvenNumber : Type
EvenNumber = (n : WFInt ** Parity n 2)

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
