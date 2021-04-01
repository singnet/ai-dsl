import sys
import grpc

# import the generated classes
import service.proto_spec.int2str_service_pb2_grpc as grpc_ha_grpc
import service.proto_spec.int2str_service_pb2 as grpc_ha_pb2

from service import registry

if __name__ == "__main__":

    # Call Int2str Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["int2str_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=42]: ") or "42")

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_ha_grpc.Int2StrStub(channel)
        arguments = grpc_ha_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.int2str(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
