import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# import the generated classes
import service.proto_spec.int2str_service_pb2_grpc as grpc_int2str_grpc
import service.proto_spec.int2str_service_pb2 as grpc_int2str_pb2

# Importing the generated codes from buildproto.sh
import service.proto_spec.compoint2float_service_pb2_grpc as grpc_compoint2float_grpc
from service.proto_spec.compoint2float_service_pb2 import Result

from service import registry

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("compoint2float_service")

"""
TODO

Simple service to test Idris-based specification checking for
services running over gRPC.

Implements a composition of (incrementer . str2float . int2str) by sequentially
invoking incrementer_service, str2float_service and int2str_service
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class CompoInt2FloatServicer(grpc_compoint2float_grpc.CompoInt2FloatServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0

        # Type check
        cmd = ["idris2", "CompoInt2Float.idr", "--check"]
        spres = subprocess.run(cmd, capture_output=True, cwd="service")
        if (spres.returncode != 0):
            log.debug("Fails type checking with error: {}".format(spres.stdout))
            exit(spres.returncode)

        # Just for debugging purpose.
        log.debug("CompoInt2FloatServicer created")

    def call_int2str_svc(self, x):
        endpoint = "localhost:{}".format(registry["int2str_service"]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_int2str_grpc.Int2strStub(channel)
        arguments = grpc_int2str_pb2.Arguments(argument=x)
        return stub.int2str(arguments).value

    def compoint2float(self, request, context):
        self.argument = request.argument
        self.result = Result()

        # TODO
        return self.result

        # # Python compoint2float implementation
        # try:
        #     # incrementer . str2float . int2str
        #     self.result.value = \
        #         self.call_incrementer_svc(
        #             self.call_str2float_svc(
        #                 self.call_int2str_svc(self.argument)))

        #     # Return compoint2float result
        #     log.debug("compoint2float {} = {}".format(self.argument, self.result.value))
        #     return self.result

        # except Exception as e:
        #     print(e)
        #     exit(1)

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
