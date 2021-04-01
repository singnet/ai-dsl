import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.proto_spec.compo1_service_pb2_grpc as grpc_compo1_grpc
from service.proto_spec.compo1_service_pb2 import Result

# Import the generated classes from other services
import service.proto_spec.incrementer_service_pb2_grpc as grpc_incrementer_grpc
import service.proto_spec.incrementer_service_pb2 as grpc_incrementer_pb2
import service.proto_spec.twicer_service_pb2_grpc as grpc_twicer_grpc
import service.proto_spec.twicer_service_pb2 as grpc_twicer_pb2

from service import registry

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("compo1_service")

"""
Simple service to test Idris-based specification checking for
services running over gRPC.

Implements a composition of (twicer . incrementer) by sequentially
invoking incrementer_service and twicer_service.
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class Compo1Servicer(grpc_compo1_grpc.Compo1Servicer):
    def __init__(self):
        self.argument = 0
        self.result = 0

        # Type check
        cmd = ["idris2", "Compo1.idr", "--check"]
        spr = subprocess.run(cmd, capture_output=True, cwd="service")
        if (spr.returncode != 0):
            log.debug("Fails type checking with error: {}".format(spr.stdout))
            exit(spr.returncode)

        # Just for debugging purpose.
        log.debug("Compo1Servicer created")

    def call_incrementer_svc(self, x):
        endpoint = "localhost:{}".format(registry["incrementer_service"]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_incrementer_grpc.IncrementerStub(channel)
        arguments = grpc_incrementer_pb2.Arguments(argument=x)
        return stub.incrementer(arguments).value

    def call_twicer_svc(self, x):
        endpoint = "localhost:{}".format(registry["twicer_service"]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_twicer_grpc.TwicerStub(channel)
        arguments = grpc_twicer_pb2.Arguments(argument=x)
        return stub.twicer(arguments).value

    def compo1(self, request, context):
        self.argument = request.argument
        self.result = Result()

        # Python compo1 implementation
        try:
            self.result.value = \
                self.call_twicer_svc(self.call_incrementer_svc(self.argument))

            # Return compo1 result
            log.debug("compo1 {} = {}".format(self.argument, self.result.value))
            return self.result

        except Exception as e:
            print(e)
            exit(1)

        # Idris compo1 implementation
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
    grpc_compo1_grpc.add_Compo1Servicer_to_server(Compo1Servicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
