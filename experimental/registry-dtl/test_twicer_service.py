import sys
import grpc

# import the generated classes
import service.proto_spec.twicer_service_pb2_grpc as grpc_ha_grpc
import service.proto_spec.twicer_service_pb2 as grpc_ha_pb2

from service import registry

if __name__ == "__main__":

    # Call Twicer Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["twicer_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=21]: ") or 21)

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_ha_grpc.TwicerStub(channel)
        arguments = grpc_ha_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.twicer(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
