# # Compile simple_services.proto to various languages
# protoc --cpp_out=cpp \
#        --js_out=js \
#        --python_out=python \
#        services.proto

# Compile gRPC skeletons to Python
python -m grpc_tools.protoc -I. --python_out=python --grpc_python_out=python services.proto
