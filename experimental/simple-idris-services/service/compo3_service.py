import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# import the generated classes
import service.proto_spec.incrementer_service_pb2_grpc as grpc_incrementer_grpc
import service.proto_spec.incrementer_service_pb2 as grpc_incrementer_pb2
import service.proto_spec.twicer_service_pb2_grpc as grpc_twicer_grpc
import service.proto_spec.twicer_service_pb2 as grpc_twicer_pb2
import service.proto_spec.halfer_service_pb2_grpc as grpc_halfer_grpc
import service.proto_spec.halfer_service_pb2 as grpc_halfer_pb2

# Importing the generated codes from buildproto.sh
import service.proto_spec.compo3_service_pb2_grpc as grpc_compo3_grpc
from service.proto_spec.compo3_service_pb2 import Result

from service import registry

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("compo3_service")

"""
Simple service to test Idris-based specification checking for
services running over gRPC.

Implements a composition of (halfer . incrementer . twicer) by sequentially
invoking incrementer_service, twicer_service and halfer_service
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class Compo3Servicer(grpc_compo3_grpc.Compo3Servicer):
    def __init__(self):
        self.argument = 0
        self.result = 0

        # Type check
        cmd = ["idris2", "Compo3.idr", "--check"]
        spres = subprocess.run(cmd, capture_output=True, cwd="service")
        if (spres.returncode != 0):
            log.debug("Fails type checking with error: {}".format(spres.stdout))
            exit(spres.returncode)

        # Just for debugging purpose.
        log.debug("Compo3Servicer created")

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

    def call_halfer_svc(self, x):
        endpoint = "localhost:{}".format(registry["halfer_service"]["grpc"])
        channel = grpc.insecure_channel(endpoint)
        stub = grpc_halfer_grpc.HalferStub(channel)
        arguments = grpc_halfer_pb2.Arguments(argument=x)
        return stub.halfer(arguments).value

    def compo3(self, request, context):
        self.argument = request.argument
        self.result = Result()

        # Python compo3 implementation
        try:
            # halfer . incrementer . twicer
            self.result.value = \
                self.call_halfer_svc(
                    self.call_incrementer_svc(
                        self.call_twicer_svc(self.argument)))

            # Return compo3 result
            log.debug("compo3 {} = {}".format(self.argument, self.result.value))
            return self.result

        except Exception as e:
            print(e)
            exit(1)

        # Idris compo3 implementation
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
    grpc_compo3_grpc.add_Compo3Servicer_to_server(Compo3Servicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
