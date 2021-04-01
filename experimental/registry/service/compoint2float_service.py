import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.proto_spec.compoint2float_service_pb2_grpc as grpc_compoint2float_grpc
from service.proto_spec.compoint2float_service_pb2 import Result

# Import the generated classes from other services
import service.proto_spec.int2str_service_pb2_grpc as grpc_int2str_grpc
import service.proto_spec.int2str_service_pb2 as grpc_int2str_pb2
import service.proto_spec.str2float_service_pb2_grpc as grpc_str2float_grpc
import service.proto_spec.str2float_service_pb2 as grpc_str2float_pb2
import service.proto_spec.registry_service_pb2_grpc as grpc_registry_grpc
import service.proto_spec.registry_service_pb2 as grpc_registry_pb2

from service import registry

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("compoint2float_service")

"""
Composite service that turns an int into a float.  It is composed of
Int2Str and another unknown service that will be retrieved by the Registry.

In other words it implements the following composition

(Registry.retrieve (String -> Float)) . int2str
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class CompoInt2FloatServicer(grpc_compoint2float_grpc.CompoInt2FloatServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0

        # Type check
        cmd = ["idris2", "CompoInt2Float.idr", "--check"]
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        if (spr.returncode != 0):
            log.debug("Fails type checking with error: {}".format(spr.stdout.strip()))
            exit(spr.returncode)

        # Just for debugging purpose.
        log.debug("CompoInt2FloatServicer created")

    def call_service(self, service_name, procedure_name, argument):
        svc_lower_name = service_name.lower()
        service_key = svc_lower_name + "_service"
        endpoint = "localhost:{}".format(registry[service_key]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        grpc_namespace_str = "grpc_" + svc_lower_name + "_grpc"
        stub = eval(grpc_namespace_str + "." + service_name + "Stub(channel)")
        pb2_namespace_str = "grpc_" + svc_lower_name + "_pb2"
        arguments = eval(pb2_namespace_str + ".Arguments(argument=argument)")
        return eval("stub." + procedure_name + "(arguments)")

    def call_int2str_svc(self, x):
        return self.call_service("Int2Str", "int2str", x).value

    def call_registry_svc(self, tsgn):
        endpoint = "localhost:{}".format(registry["registry_service"]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_registry_grpc.RegistryStub(channel)
        arguments = grpc_registry_pb2.Arguments(type_signature=tsgn)
        result = stub.retrieve(arguments)
        return result.service_name, result.procedure_name

    def compoint2float(self, request, context):
        self.argument = request.argument
        self.result = Result()

        # Python compoint2float implementation
        try:
            # Retrieve a service and procedure matching the given type
            # signature.
            #
            # TODO: ask idris to find the type signature of the hole.
            hole_service_name, hole_procedure_name = \
                self.call_registry_svc("String -> Double")

            # Compose hole . int2str
            self.result.value = \
                self.call_service(hole_service_name, hole_procedure_name,
                                  self.call_int2str_svc(self.argument)).value

            # Return compoint2float result
            log.debug("compoint2float {} = {}".format(self.argument, self.result.value))
            return self.result

        except Exception as e:
            print(e)
            exit(1)

        # Idris compoint2float implementation
        # TODO: difficult to implement without a gRPC Idris port/wrapper.


# The gRPC serve function.
#
# Params:
# max_workers: pool of threads to execute calls asynchronously
# port: gRPC server port
#
# Add all your classes to the server here.
# (from generated .py files by protobuf compiler)
def serve(max_workers=10, port=7777):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=max_workers))
    grpc_compoint2float_grpc.add_CompoInt2FloatServicer_to_server(CompoInt2FloatServicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
