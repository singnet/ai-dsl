module Twicer
import Service
import System
import Numeric

%default total

public export
EvenNumber : Type
EvenNumber = (n : WFInt ** Parity n 2)

-- Run external service
public export
runTwicer : Integer -> IO EvenNumber
runTwicer = do ?run

public export
twicerContract : (a : Integer) -> Contract (runTwicer a) EvenNumber
twicerContract a = MkContract (runTwicer a)

public export
twicerService : Integer -> Service EvenNumber
twicerService a = Promise (twicerContract a)
