module Compo

import Service
import Numeric
import Halfer
import Twicer
import Incrementer

%default total



-- composition of Twicer and Incrementer
compo1 : Integer -> Service (Integer)
compo1 a = do
            n <- twicerService a
            incrementerService n

-- composition of Twicer, Halfer, and Incrementer
compo2 : Integer -> Service (Integer)
compo2 a = do
            i <- twicerService a
            j <- Promise (MkContract ?check1)
            k <- halferService j
            incrementerService k


-- invalid composition of Twicer, Incrementer, and Halfer
compo3 : Integer -> Service (Integer)
compo3 a = do
            n <- twicerService a
            m <- incrementerService (cast $ fst n)
            halferService ?hole
