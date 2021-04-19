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
            incrementerService (cast $ fst n)

-- composition of Twicer, Halfer, and Incrementer
compo2 : Integer -> Service (Integer)
compo2 a = do
            n <- twicerService a
            m <- halferService n
            incrementerService m


-- invalid composition of Twicer, Incrementer, and Halfer
compo3 : Integer -> Service (Integer)
compo3 a = do
            n <- twicerService a
            m <- incrementerService (cast $ fst n)
            halferService ?hole
