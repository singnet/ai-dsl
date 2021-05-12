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
    -- Because twicerService does not provide its own proof that its
    -- output is always even, we use a Promise to provide a soft proof
    -- of this property.
            p <- Promise ?con
            j <- halferService (cast i ** p)
            incrementerService j


-- invalid composition of Twicer, Incrementer, and Halfer
compo3 : Integer -> Service (Integer)
compo3 a = do
            i <- twicerService a
            j <- incrementerService i
    -- The `resolve` hole shows that the programmer must create apply some logic
    -- of type Integer -> EvenNumber to resolve the mismatch here.
            halferService $ ?resolve j


-- A potential method to resolve the above mismatch
compo3sol : Integer -> Service (Integer)
compo3sol a = do
            i <- twicerService a
            j <- incrementerService i
    -- Because this function contains the actual composition of the various
    -- Services, this is the point where the programmer is best able to decide
    -- which measures are acceptable to resolve type mismatches.
    -- In this case, forceEven is used.
            halferService $ forceEven j


-- In this composition, we have no way to statically prove that
-- halferService is being passed an even number.
compo4 : Integer -> Service (Integer)
compo4 a = do
    -- i could be even or odd, depending on the value of a
            i <- incrementerService a
    -- We can pattern match on the result of a runtime test
    -- to create a branch in the logic of this Service.
            Just j <- pure $ maybeEven i
                 | Nothing => twicerService i
    -- If there is a Just EvenNumber, run the halferService on it.
    -- If there is no EvenNumber value to be found, run the twicerService on i.
            halferService j



-- Because all of the above examples are Integer -> Service (Integer),
-- it is relatively trivial to compose them.
compo5 : Integer -> Service (Integer)
compo5 a = (compo1 a) >>= compo2 >>= compo3 >>= compo4
