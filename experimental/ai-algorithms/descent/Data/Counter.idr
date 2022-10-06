module Data.Counter

import Data.Maybe
import Data.SortedMap

----------------------------------
-- Counter data type definition --
----------------------------------

||| Counter data type, a la Python
||| https://docs.python.org/3/library/collections.html#collections.Counter
public export
record Counter k v where
  constructor C
  unC : SortedMap k v

||| Add 2 counters.  For each element of the resulting counter, the
||| counts of that element from the input counters are added up.  If
||| some element is missing from one of the counters, its count is
||| simply treated as null.
public export
(+) : Num v => Counter k v -> Counter k v -> Counter k v
(+) cl cr = C (mergeWith (+) cl.unC cr.unC)

public export
empty : (Ord k, Num v) => Counter k v
empty = C empty

||| Insert an element into a counter.  If the element is not already
||| in the counter, then it is inserted with a count of 1.  Otherwise,
||| the count of the element is incremented by 1.
public export
insert : (Ord k, Num v) => k -> Counter k v -> Counter k v
insert x c = c + C (singleton x (fromInteger 1))

||| Construct a counter from a single element, assigning its count to
||| 1.
public export
singleton : (Ord k, Num v) => k -> Counter k v
singleton x = insert x empty

||| Attempt to retrive the count of a key.  If the key is not in the
||| counter, then return zero.
public export
lookup : Num v => k -> Counter k v -> v
lookup key cnt = fromMaybe (fromInteger 0) (lookup key cnt.unC)
