module TestRewrite

||| Assume that f x = x
fx_eq_x : Ord a => (f : a -> a) -> (x : a) -> f x = x
fx_eq_x f x = believe_me ()

||| Assume that x is less than or equal to y
x_le_y : Ord a => (x, y : a) -> x <= y = True
x_le_y x y = believe_me ()

||| Prove that (f x) is less than or equal to y
fx_le_y : Ord a => (f : a -> a) -> (x, y : a) -> f x <= y = True
fx_le_y f x y = rewrite (fx_eq_x f x) in (x_le_y x y)
