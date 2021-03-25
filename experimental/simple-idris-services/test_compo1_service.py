import sys
import grpc

# import the generated classes
import service.proto_spec.compo1_service_pb2_grpc as grpc_compo1_grpc
import service.proto_spec.compo1_service_pb2 as grpc_compo1_pb2

from service import registry

if __name__ == "__main__":

    # Call Compo1 Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["compo1_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=20]: ") or "20")

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_compo1_grpc.Compo1Stub(channel)
        arguments = grpc_compo1_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.compo1(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
