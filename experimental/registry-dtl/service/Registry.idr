module Registry

-- Import the specifications of existing services
import Twicer
import Halfer
import Incrementer
import Compo

-- Declare the retrieve procedure of the Registry module.  It takes a
-- string representing a type signature and return a pair of strings
-- representing respectively the name of a service and the name of a
-- procedure of that service matching that type signature.  The
-- implementation is only available in Python for now.
export
retrieve : String -> (String, String)
