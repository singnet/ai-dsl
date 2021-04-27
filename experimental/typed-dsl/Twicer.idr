module Twicer
import Service
import System
import Numeric

%default total


-- Run external service
public export
runTwicer : Integer -> IO Integer
runTwicer = do ?run

public export
twicerContract : (a : Integer) -> Contract (runTwicer a) Integer
twicerContract a = MkContract (runTwicer a)

public export
twicerService : Integer -> Service Integer
twicerService a = Promise (twicerContract a)
