module Incrementer

import public Numeric

%default total

||| Increment integer
public export
incrementer : Integer -> Integer
incrementer = (+1)
