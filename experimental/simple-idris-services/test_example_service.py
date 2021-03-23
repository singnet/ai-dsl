import sys
import grpc

# import the generated classes
import service.service_spec.simple_service_pb2_grpc as grpc_ex_grpc
import service.service_spec.simple_service_pb2 as grpc_ex_pb2

from service import registry

if __name__ == "__main__":

    try:
        test_flag = False
        if len(sys.argv) == 2:
            if sys.argv[1] == "auto":
                test_flag = True

        # Example Service - Arithmetic
        endpoint = input("Endpoint [default=localhost:{}]: ".format(registry["simple_service"]["grpc"])) if not test_flag else ""
        if endpoint == "":
            endpoint = "localhost:{}".format(registry["simple_service"]["grpc"])

        grpc_method = input("Method (incrementer|twicer|halfer): ") \
            if not test_flag else "incrementer"
        argument = int(input("Argument: ") if not test_flag else "41")

        # Open a gRPC channel
        channel = grpc.insecure_channel("{}".format(endpoint))
        stub = grpc_ex_grpc.SimpleStub(channel)
        arguments = grpc_ex_pb2.Arguments(argument=argument)

        if grpc_method == "incrementer":
            response = stub.incrementer(arguments)
            print(response.value)
        elif grpc_method == "twicer":
            response = stub.twicer(arguments)
            print(response.value)
        elif grpc_method == "halfer":
            response = stub.halfer(arguments)
            print(response.value)
        else:
            print("Invalid method!")
            exit(1)

    except Exception as e:
        print(e)
        exit(1)
