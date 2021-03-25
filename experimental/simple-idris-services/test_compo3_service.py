import sys
import grpc

# import the generated classes
import service.proto_spec.compo3_service_pb2_grpc as grpc_compo3_grpc
import service.proto_spec.compo3_service_pb2 as grpc_compo3_pb2

from service import registry

if __name__ == "__main__":

    # Call Compo3 Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["compo3_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=40]: ") or "40")

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_compo3_grpc.Compo3Stub(channel)
        arguments = grpc_compo3_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.compo3(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
