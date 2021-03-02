# Experimental

This folder contains experiments to build understanding, define and
refine the AI-DSL.

## Description

More specifically it contains the following approaches

1. `FndType`: datum-based cost modeling.  Cost is associated to data
   rather than functions.  See `FndType.idr` and `FndType-test.idr`.

2. `NonDTRealizedFunction`: function-based realized attributes with
   non-dependently typed attributes.  This is the approached described
   in the proposal
   https://blog.singularitynet.io/ai-dsl-toward-a-general-purpose-description-language-for-ai-agents-21459f691b9e
   but the realized attributes are described by a non-dependently
   typed data structure, thus makes it less suited (impossible?) to
   take advantage of Idris dependent type checking.  See
   `NonDTRealizedAttributes.idr`, `NonDTRealizedFunction.idr` and
   `NonDTRealizedFunction-test.idr`.

3. `SimpleRealizedFunction`: Non-modular function-based realized
   dependently typed attributes.  This is almost what we want but
   there is no data structure for attibutes, rather these are directly
   passed to the RealizedFunction data structure.  It works, idris2 is
   able to type check that function composition respects compositional
   laws of realized functions, but it's not modular/elegant.  See
   `SimpleRealizedFunction.idr` and `SimpleRealizedFunction-test.idr`.

4. `SimpleDataRealizedFunction`: like `SimpleRealizedFunction` but
   uses `data` instead of `record`.

5. TODO: modular function-based realized dependently typed attributes.
   This should be what we want and is a work in progress.
