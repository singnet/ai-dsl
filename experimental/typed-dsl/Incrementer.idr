module Incrementer
import Service
import System
import Numeric

%default total


-- Run external service
public export
runIncrementer : Integer -> IO Integer
runIncrementer = do ?run


public export
incrementerContract : (a : Integer) -> Contract (runIncrementer a) Integer
incrementerContract a = MkContract (runIncrementer a)


public export
incrementerService : Integer -> Service Integer
incrementerService a = Promise (incrementerContract a)
