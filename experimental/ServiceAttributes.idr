module ServiceAttributes
%default total
          

-- attrType should represent the type of any service metadata that needs to be
-- tracked, (e.g. costs, quality, dependencies, etc).  It should implement
-- the Num interface to make Service composition a simple matter of combining
-- attributes with (+) and (*) operations.
data Service : (Num attrType) => (attrs : attrType) -> (t : Type) -> Type where
     -- Construct a basic service
     MkService : (Num attrType) => (a : attrType) ->  (f : t) -> Service a t
     -- Prove that a sequence of services creates a valid service.
     Sequence : (Num attrType) =>
              {a1 : attrType} -> {a2 : attrType} ->
              (Service a1 (t1 -> ti)) ->
              (Service a2 (ti -> t2)) ->
              (Service (a1 + a2) (t1 ->  t2))
    -- There might be a reason to write a third constructor representing
    -- branches in service composition, but for now we'll put that aside.



-- These are just here to help me wrap my head
-- around composing long types.
data Test1 : Type
data Test2 : Type
data Test3 : Type
data Test4 : Type


smallFun : Test1 -> Test2

medFun : Test2 -> Test3 -> Test4

endFun : Test4 -> Test1



smallService : Service 1.0 (Test1 -> Test2)

medService : Service 2.0 (Test2 -> Test3 -> Test4)

endService : Service 2.0 (Test4 -> Test1)



composedService : Service 3.0 (Test1 -> Test3 -> Test4)
composedService = Sequence smallService medService


longService : Service 5.0 ()
