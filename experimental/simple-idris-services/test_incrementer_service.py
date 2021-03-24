import sys
import grpc

# import the generated classes
import service.proto_spec.incrementer_service_pb2_grpc as grpc_ex_grpc
import service.proto_spec.incrementer_service_pb2 as grpc_ex_pb2

from service import registry

if __name__ == "__main__":

    try:
        test_flag = False
        if len(sys.argv) == 2:
            if sys.argv[1] == "auto":
                test_flag = True

        # Example Service - Arithmetic
        endpoint = input("Endpoint [default=localhost:{}]: ".format(registry["incrementer_service"]["grpc"])) if not test_flag else ""
        if endpoint == "":
            endpoint = "localhost:{}".format(registry["incrementer_service"]["grpc"])
        grpc_method = "incrementer"
        argument = int(input("Argument: ") if not test_flag else "41")

        # Open a gRPC channel
        channel = grpc.insecure_channel("{}".format(endpoint))
        stub = grpc_ex_grpc.IncrementerStub(channel)
        arguments = grpc_ex_pb2.Arguments(argument=argument)

        # Carry out service
        response = stub.incrementer(arguments)
        print(response.value)

    except Exception as e:
        print(e)
        exit(1)
