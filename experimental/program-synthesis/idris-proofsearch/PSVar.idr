module PSVar

-- Represent to-be-composed functions as variables of a meta-function,
-- and use Idris proof search functionality to compose them as to be
-- consistent with the type of the meta-function.

----------------------
-- Trivial attempts --
----------------------

-- Succeeds to discover the correct program: g (f x)
syn0a : (Bool -> Int) -> (Int -> Double) -> Bool -> Double
syn0a f g x = ?syn0a_h

-- Like above but move the variables in a lambda.  Successful too.
syn0b : Bool -> Double
syn0b x = (\f : (Bool -> Int),
            g : (Int -> Double)
            => (the Double ?syn0b_h)) ?syn0b_hf ?syn0b_hg

-- Here 3 solutions are possible, f x, g x and h x.  Idris proof
-- search successfully discover them.
syn1a : (a -> b -> c) -> (a -> b -> c) -> (a -> b -> c) -> a -> b -> c
syn1a f g h x y = ?syn1a_rhs

-- Like above but move the variables in a lambda.  Successful too.
syn1b : a -> b -> c
syn1b x y = (\f : (a -> b -> c),
              g : (a -> b -> c),
              h : (a -> b -> c)
              => (the c ?syn1b_h)) ?syn1b_hf ?syn1b_hg ?syn1b_hh

-- Succeeds to discover the correct program: f x y z
syn2 : (a -> b -> c -> d) -> a -> b -> c -> d
syn2 f x y z = ?synb_rhs

-------------------------------------------------------------------------
-- Less trivial attempts.  Try synthesize composition of descent, loss --
-- and gradient.                                                       --
-------------------------------------------------------------------------

-- Fails as Idris proofsearch gets lost in the wrong branch
syn3 : ((cnd -> cost) -> (cnd -> cnd) -> cnd -> cnd) -> -- Descent algorithm
       (cnd -> cost) ->                                 -- Cost function
       (cnd -> cnd) ->                                  -- Next function
       cnd ->                                           -- Initial candidate
       cnd                                              -- Final candidate
syn3 d c n i = ?syn3_rhs

-- Fails too as Idris proofsearch gets lost in the wrong branch
syn4 : (cnd -> cost) ->                                 -- Cost function
       (cnd -> cnd) ->                                  -- Next function
       cnd ->                                           -- Initial candidate
       ((cnd -> cost) -> (cnd -> cnd) -> cnd -> cnd) -> -- Descent algorithm
       cnd                                              -- Final candidate
syn4 c n i d = ?syn4_h

-- Succeeds as Idris proofsearch starts with the right branch
syn5 : (cnd -> cnd) ->                                  -- Next function
       ((cnd -> cost) -> (cnd -> cnd) -> cnd -> cnd) -> -- Descent algorithm
       (cnd -> cost) ->                                 -- Cost function
       cnd ->                                           -- Initial candidate
       cnd                                              -- Final candidate
syn5 n d c i = ?syn5_h
