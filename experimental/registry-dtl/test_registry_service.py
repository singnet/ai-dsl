import sys
import grpc

# import the generated classes
import service.proto_spec.registry_service_pb2_grpc as grpc_registry_grpc
import service.proto_spec.registry_service_pb2 as grpc_registry_pb2

from service import registry

if __name__ == "__main__":

    # Call Registry Service

    try:
        # Ask endpoint and argument
        dflt_ep = "localhost:{}".format(registry["registry_service"]["grpc"])
        endpoint = input("Endpoint [default={}]: ".format(dflt_ep)) or dflt_ep
        dflt_tsgn = "Integer -> EvenInteger"
        tsgn = input("Type signature [default={}]: ".format(dflt_tsgn)) or dflt_tsgn

        # Open a gRPC channel
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_registry_grpc.RegistryStub(channel)
        arguments = grpc_registry_pb2.Arguments(type_signature=tsgn)

        # Carry out service
        response = stub.retrieve(arguments)
        print("service_name = {}\nprocedure_name = {}".format(
            response.service_name, response.procedure_name))

    except Exception as e:
        print(e)
        exit(1)
