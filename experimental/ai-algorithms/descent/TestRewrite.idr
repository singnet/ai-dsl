module TestRewrite

||| Assume that x = f x
x_eq_fx : (f : a -> a) -> (x : a) -> x = f x
x_eq_fx f x = believe_me ()

||| Assume that f x = x
fx_eq_x : (f : a -> a) -> (x : a) -> f x = x
fx_eq_x f x = believe_me ()

||| Assume that x has property p
has : (p : a -> Type) -> (x : a) -> p x
has p x = believe_me ()

||| Prove that (f x) has property p
has_f : (f : a -> a) -> (p : a -> Type) -> (x : a) -> p (f x)
has_f f p x = rewrite (fx_eq_x f x) in (has p x)
