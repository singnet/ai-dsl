import sys
import grpc

# import the generated classes
import service.proto_spec.incrementer_service_pb2_grpc as grpc_in_grpc
import service.proto_spec.incrementer_service_pb2 as grpc_in_pb2

from service import registry

if __name__ == "__main__":

    # Call Halfer Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["incrementer_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=41]: ") or "41")

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_in_grpc.IncrementerStub(channel)
        arguments = grpc_in_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.incrementer(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
