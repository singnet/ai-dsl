# Simple SNET services using Idris

Combination of 3 trivial SNET services using Idris to compute the
functions of each service and type check their interactions.

# Services

The 3 services are available

1. incrementer: increment an integer by 1
2. twicer: multiply an integer by 2
3. halfer: divide an integer by 2

Each service have constraints of their own.  For instance halfer only
takes an even number as input.

Thus some combinations are permitted, such as

```
incrementer . halfer . twicer
```

while some others are not, such as

```
halfer . incrementer . twicer
```

due to incrementer outputing an odd number.

# Communication

For now communication takes place with gRPC, bypassing SingularityNET.
Since there is no gRPC implementation for Idris, idris is compiled and
run as an external subprocess wrapped in Python.

# Usage

TODO

# Credits

The code is based on https://github.com/singnet/example-service
