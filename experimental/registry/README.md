# Registry Prototype

Simple registry prototype.

# Services

We have 2 basic services

1. int2str: cast an integer into a string
2. str2float: cast an integer into a float

The registry has 2 procedures

1. retrieve: retrieve a service and procedure matching a given type
   signature.
2. compose: construct a composite service from services of the
   registry given a type signature.  This is useful when the retriever
   fails to retrieve a service for that type signature.

With that we have a composite service to test the registry

1. compoint2float: that calls the registry to retrieve (or compose) a
   service to generate a function of a certain type signature, here
   Int -> Float.

# Requirements

- grpc
- grpc-cli
- python-grpcio
- python-grpcio-tools
- idris2

# Usage

1. First time you need to generate boilerplate code for gRPC

```bash
./buildproto.sh
```

2. Start gRPC services

```bash
python3 run_services.py --no-daemon
```

TODO
