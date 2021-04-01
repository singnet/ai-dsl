import sys
import grpc

# import the generated classes
import service.proto_spec.compoint2float_service_pb2_grpc as grpc_compoint2float_grpc
import service.proto_spec.compoint2float_service_pb2 as grpc_compoint2float_pb2

from service import registry

if __name__ == "__main__":

    # Call Compoint2float Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["compoint2float_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = int(input("Argument [default=40]: ") or "40")

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_compoint2float_grpc.Compoint2floatStub(channel)
        arguments = grpc_compoint2float_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.compoint2float(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
