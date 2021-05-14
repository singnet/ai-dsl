import sys
import grpc

# import the generated classes
import service.proto_spec.compo_service_pb2_grpc as grpc_compo_grpc
import service.proto_spec.compo_service_pb2 as grpc_compo_pb2

from service import registry

if __name__ == "__main__":

    # Call Compo Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["compo_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=41]: ") or 41)

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_compo_grpc.CompoStub(channel)
        arguments = grpc_compo_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.compo(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
