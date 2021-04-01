import sys
import grpc

# import the generated classes
import service.proto_spec.str2float_service_pb2_grpc as grpc_tw_grpc
import service.proto_spec.str2float_service_pb2 as grpc_tw_pb2

from service import registry

if __name__ == "__main__":

    # Call Str2Float Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["str2float_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        argument = input("Argument [default=\"42\"]: ") or "\"42\""

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_tw_grpc.Str2FloatStub(channel)
        arguments = grpc_tw_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.str2float(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
