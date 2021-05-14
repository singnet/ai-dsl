#!/bin/bash

# Build boilerplate code for gRPC from protobuffer specification
for service in twicer halfer incrementer registry compo; do
    python3 -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. \
            service/proto_spec/${service}_service.proto
done
