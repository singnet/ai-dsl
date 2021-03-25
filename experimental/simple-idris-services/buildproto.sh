#!/bin/bash

# Build boilerplate code for gRPC from protobuffer specification
for service in incrementer twicer halfer compo1 compo2 compo3; do
    python3 -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. \
            service/proto_spec/${service}_service.proto
done
