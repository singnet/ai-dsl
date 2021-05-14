module Compo

import Halfer
import Incrementer

||| Composition of incrementer . halfer . ?hole, where the registry
||| will be in charge of filling the hole.
|||
||| TODO: ultimately Idris could fill such hole, thus maybe we want
||| the registry to heavely rely on such a capability of Idris.
export
compo : Integer -> Integer
compo = incrementer . (halfer . ?hole)
