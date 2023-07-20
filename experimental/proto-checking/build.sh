# Compile gRPC skeletons to Python
python -m grpc_tools.protoc -I. --python_out=python --grpc_python_out=python --pyi_out=python services.proto
