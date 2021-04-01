module CompoInt2Float

import Int2Str

-- This function is used to fill the hole that the registry is
-- supposed fill by returning the service and procedure implementing a
-- given type signature.
export
registry_hole_filler : a -> b

-- int2float is defined using the registry hole filler.  Basically
-- assuming (Registry.retrieve (String -> Double)) would return a
-- function with such type signature, then int2float can be
-- implemented as
--
-- (Registry.retrieve (String -> Double)) . int2str
export
int2float : Int -> Double
int2float = registry_hole_filler . Int2Str.int2str
