module PSLet

-- Try (but fail) to use Idris let construct to bring to-be-composed
-- functions into the scope of Idris proof search.

-- Failed attempt.  f and g do not appear in the scope of ?letsyn_h
letsyn1 : Bool -> Double
letsyn1 x = let f : Bool -> Int
                f True = 1
                f False = 0
                g : Int -> Double
                g = cast
            in ?letsyn1_h

-- Successful attempt.  However it is not much better than syn0b or
-- syn1b in PSVar.idr as f and g could simply be replaced by holes.
letsyn2 : Bool -> Double
letsyn2 x = let f : Bool -> Int
                f True = 1
                f False = 0
                g : Int -> Double
                g = cast
            in (\fv : (Bool -> Int),
                 gv : (Int -> Double)
                 => (the Double ?letsyn2_h)) f g
