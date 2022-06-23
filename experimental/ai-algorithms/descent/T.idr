module T

||| Descend as much as possible
d : Ord a => (f : a -> a) -> (x : a) -> a
d f x = if (f x) < x then d f (f x) else x
-- d f x = x

||| Assume that d f x = d f (f x)
dx_eq_dfx : Ord a => (f : a -> a) -> (x : a) -> T.d f x = T.d f (f x)
dx_eq_dfx f x = believe_me ()

||| Assume that (d f (f x)) is less than or equal to (f x)
dfx_le_fx : Ord a => (f : a -> a) -> (x : a) -> T.d f (f x) <= f x = True
dfx_le_fx f x = believe_me ()

||| Prove that (d f x) is less than or equal to (f x)
dx_le_fx : Ord a => (f : a -> a) -> (x : a) -> T.d f x <= f x = True
dx_le_fx f x = rewrite (dx_eq_dfx f x) in (dfx_le_fx f x)

-- ||| Assume that (f x) is less than or equal to x
-- fx_le_x : Ord a => (f : a -> a) -> (x : a) -> f x <= x = True
-- fx_le_x f x = believe_me ()

-- ||| Assume that <= is transitive
-- public export
-- le_transitive : Ord a => {0 x, y, z : a} -> x <= y = True -> y <= z = True -> x <= z = True
-- le_transitive _ _ = believe_me ()

-- ||| Prove that the output of d is less than or equal to its input
-- dx_le_x : Ord a => (f : a -> a) -> (x : a) -> T.d f x <= x = True
-- dx_le_x f x = le_transitive (dx_le_fx f x) (fx_le_x f x)
