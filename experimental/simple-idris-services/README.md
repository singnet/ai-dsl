# Simple SNET services using Idris

Combination of 3 trivial SNET services using Idris to compute the
functions of each service and type check their interactions.

# Services

3 primary services are available

1. incrementer: increment an integer by 1
2. twicer: multiply an integer by 2
3. halfer: divide an integer by 2

as well as 3 composite services

1. compo1: twicer . incrementer
2. compo2: incrementer . twicer . halfer
3. compo3: halfer . incrementer . twicer

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

due to incrementer outputting an odd number.

# Communication

For now communication takes place with gRPC, bypassing SingularityNET.
Since there is no gRPC implementation for Idris, idris is compiled and
run as an external subprocess wrapped in Python.

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

3. Test the various primary services

```bash
python3 test_incrementer_service.py
python3 test_twicer_service.py
python3 test_halfer_service.py
```

or the various composite services

```bash
python3 test_compo1_service.py
python3 test_compo2_service.py
python3 test_compo3_service.py
```

you will be prompted to choose the endpoint and the argument, the
output of the whole call may look like

```bash
$ python test_incrementer_service.py
Endpoint [default=localhost:7003]:
Argument [default=41]:
42
```

Alternatively you may call the service directly from `grpc_cli` as follows

```bash
grpc_cli call localhost:7003 <METHOD> "argument: <VALUE>" --protofiles=service/service_spec/incrementer_service.proto
```

Such as for example

```
$ grpc_cli call localhost:7003 incrementer "argument: 41" --protofiles=service/service_spec/incrementer_service.proto
connecting to localhost:7003
value: 42
Rpc succeeded with OK status
Reflection request not implemented; is the ServerReflection service enabled?
```

# Type Checking

As the services are launched, idris2 will perform type checking to
make sure the composite services are correctly calling the primary
services.

One can modify the Idris specifications of the composite services and
check that the type checker raises an error when appropiate.  See

```
service/Compo1.idr
service/Compo2.idr
service/Compo3.idr
```

If some error introduced then such error should be detected at
launching time

```bash
python3 run_services.py --no-daemon
```

Here's an error message resulting from changing the type signature of
`rlz_compo1`

```
[2021-03-25 16:45:52,319] [DEBUG] [compo1_service] Fails type checking with error: b'5/5: Building Compo1 (Compo1.idr)\n\x1b[38;5;9;1mError:\x1b[0m \x1b[1mWhile processing right hand side of \x1b[38;5;5;1mrlz_compo1\x1b[0;1m\x1b[0m. \x1b[1mWhen\nunifying \x1b[38;5;5;1mRealizedFunction (Int -> Int) (add_costs_min_quality (MkRealizedAttributes (MkCosts (fromInteger 100) 10.0 1.0) 1.0) (MkRealizedAttributes (MkCosts (fromInteger 200) 20.0 2.0) 0.9))\x1b[0;1m and \x1b[38;5;5;1mRealizedFunction (Int -> String) rlz_compo1_attrs\x1b[0;1m\x1b[0m.\n\x1b[1mMismatch between: \x1b[38;5;5;1mInt\x1b[0;1m and \x1b[38;5;5;1mString\x1b[0;1m.\x1b[0m\n\n\x1b[38;5;12mCompo1.idr:14:14--14:48\x1b[0m\n\x1b[38;5;12m    |\x1b[0m\n\x1b[38;5;12m 14\x1b[0m \x1b[38;5;12m|\x1b[0m rlz_compo1 = compose rlz_twicer rlz_incrementer\n    \x1b[38;5;12m|\x1b[0m              \x1b[38;5;9;1m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\x1b[0m\n\n'
```

# Credits

The SNET part of the code is based on
https://github.com/singnet/example-service
