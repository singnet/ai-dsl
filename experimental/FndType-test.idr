module Main

import FndType

-- Lifted increment function. Input fund must be at least 1.
inc : (FndType (10 + fund) Int) -> (FndType fund Int)
-- inc = upliftFun (\x => (x + 1))
inc (FT i) = FT (i + 1)

-- Lifted decrement function. Input fund must be at least 1.
dec : (FndType (10 + fund) Int) -> (FndType fund Int)
-- dec = upliftFun (\x => (x - 1))
dec (FT i) = FT (i - 1)

-- Main
rich_42 : FndType 99 Int
rich_42 = FT 42
poor_42 : FndType 1 Int
poor_42 = FT 42
main : IO ()
main = do
  putStrLn (FndType.show rich_42)
  putStrLn (FndType.show (inc rich_42)) -- Decrement the fund while incrementing the content
  -- putStrLn (FndType.show (inc poor_42)) -- Just enough fund
  -- putStrLn (FndType.show ((compose inc dec) rich_42)) -- Decrement the fund by 2
  -- putStrLn (show ((compose inc dec) poor_42)) -- Not enough fund
