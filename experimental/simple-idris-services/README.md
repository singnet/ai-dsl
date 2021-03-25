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

# Requirements

- grpc
- grpc-cli
- idris2

# Usage

1. First time you need to generate boilerplate code for gRPC

```bash
./buildproto.sh
```

2. Start a gRPC service

```bash
python3 run_example_service.py --no-daemon
```

3. Call the service

```bash
python3 test_example_service.py
```

you will be prompted to choose the method and the argument, the output
of the whole call may look like

```bash
$ python test_example_service.py
Endpoint [default=localhost:7003]:
Method (incrementer|twicer|halfer): incrementer
Argument: 41
42
```

Alternatively you may call the service directly from `grpc_cli` as follows

```bash
grpc_cli call localhost:7003 <METHOD> "argument: <VALUE>" --protofiles=service/service_spec/simple_service.proto
```

Such as for example

```
$ grpc_cli call localhost:7003 incrementer "argument: 41" --protofiles=service/service_spec/simple_service.proto
connecting to localhost:7003
value: 42
Rpc succeeded with OK status
Reflection request not implemented; is the ServerReflection service enabled?
```

# Credits

The code is based on https://github.com/singnet/example-service
