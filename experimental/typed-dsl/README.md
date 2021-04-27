# Experimental

This folder contains an experimental approach to the composition of a
dependently-typed eDSL.



## Description

Previous approaches to DSL design imposed a requirement for service descriptions
to all make use of common types, and for the properties of both service inputs
and outputs to be known at the point of description, rather than at the point of
composition.

For example,

``` idris
-- Realized twicer
public export
-- Guaranteed to produce a value divisible by 2
twicer : (b : WFInt) -> (a : WFInt ** Parity a 2)
twicer b = ((2 * b) ** (Even (b ** ?pr)))
```
is a description of a service and its properties using a previous approach.
This approach required the description to include details about a service's 
outputs (such as the above service always outputting even numbers), which is 
not always possible in the real world (since a service will not have knowledge
of how its outputs are used).

The aim of this new approach is to shift the task of resolving service type
discrepencies to the point where they are composed.  ``Service.idr`` defines a 
Service type which describes a syntax tree for a minimal eDSL, constructed from
any combination of native Idris values (of any Idris type) and values of types
linked to placeholder smart contracts.  

Because Service is a Monad, we can use do-notation for simple composition:

``` idris
-- composition of Twicer and Incrementer
compo1 : Integer -> Service (Integer)
compo1 a = do
            n <- twicerService a
            incrementerService n
```

For cases where a service's type signature does not provide enough information
to prove that it can compose with a subsequent service, a smart contract can 
referenced:

``` idris
-- composition of Twicer, Halfer, and Incrementer
compo2 : Integer -> Service (Integer)
compo2 a = do
            i <- twicerService a
            j <- Promise (MkContract ?check1)
            k <- halferService j
            incrementerService k
```
Here, the ?check1 hole represents a reference to an external smart contract that
vouches for the fact that twicerService outputs an even number.


## Running and Testing

Running either 

``` shell
idris Compo.idr
```
or
``` shell
idris2 Compo.idr
```
should demonstrate the type errors caught in the composition examples, where 
applicable.  Currently, the external python services are not used, as there is 
more work to be done looking into IO methods.

