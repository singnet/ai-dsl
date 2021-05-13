import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.proto_spec.twicer_service_pb2_grpc as grpc_bt_grpc
from service.proto_spec.twicer_service_pb2 import Result

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("twicer_service")


"""
Simple service to test Idris-based specification checking for
services running over gRPC.

Implements an twicer method, that divides an integer by 2.
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class TwicerServicer(grpc_bt_grpc.TwicerServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0
        # Just for debugging purpose.
        log.debug("TwicerServicer created")

    # Convert int into string
    def twicer(self, request, context):
        self.argument = request.argument
        self.result = Result()

        # Python twicer
        # self.result.value = self.argument * 2

        # Idris twicer
        argstr = str(self.argument)
        cmd = ["idris2",
               "Twicer.idr",
               "--client",
               "(the Integer (cast (twicer " + argstr + ")))"]
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        self.result.value = int(spr.stdout.strip())

        log.debug("twicer {} = {}".format(self.argument, self.result.value))
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
    grpc_bt_grpc.add_TwicerServicer_to_server(TwicerServicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
