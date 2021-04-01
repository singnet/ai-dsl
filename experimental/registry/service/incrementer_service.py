import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.proto_spec.incrementer_service_pb2_grpc as grpc_bt_grpc
from service.proto_spec.incrementer_service_pb2 import Result

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("incrementer_service")

"""
Simple service to test Idris-based specification checking for
services running over gRPC.

Implements an incrementer method, that increments an integer by 1.
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class IncrementerServicer(grpc_bt_grpc.IncrementerServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0
        # Just for debugging purpose.
        log.debug("IncrementerServicer created")

    # Increment an integer by 1
    def incrementer(self, request, context):
        # In our case, request is a Numbers() object (from .proto file)
        self.argument = request.argument

        # To respond we need to create a Result() object (from .proto file)
        self.result = Result()

        # Python incrementer
        # self.result.value = self.argument + 1

        # Idris incrementer
        argstr = str(self.argument)
        cmd = ["idris2", "Incrementer.idr", "--client", "incrementer " + argstr]
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        self.result.value = int(spr.stdout.strip())

        log.debug("incrementer {} = {}".format(self.argument, self.result.value))
        return self.result


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
    grpc_bt_grpc.add_IncrementerServicer_to_server(IncrementerServicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
