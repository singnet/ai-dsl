module Test

||| Define foo, which is   foo x = x   in disguise
foo : Ord a => (x : a) -> a
foo x = if x < x then x else x
-- foo x = x

||| Assume that foo f x = x
eq : Ord a => (f : a -> a) -> (x : a) -> Test.foo x = x
eq f x = believe_me ()

||| Prove that if x <= y then (foo f x) <= y
prf : Ord a => (f : a -> a) -> (x, y : a) ->
      x <= y = True -> Test.foo x <= y = True
prf f x y le = rewrite (eq f x) in le
