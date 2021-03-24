import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.service_spec.simple_service_pb2_grpc as grpc_bt_grpc
from service.service_spec.simple_service_pb2 import Result

logging.basicConfig(level=10, format="%(asctime)s - [%(levelname)8s] - %(name)s - %(message)s")
log = logging.getLogger("simple_service")


"""
Simple service to test Idris-based specification checking for
services running over gRPC.

The following methods are implemented

1. incrementer: increment an integer by 1
2. twicer: multiply a integer by 2
3. halfer: divide a integer by 2

Each service have constraints of their own.  For instance halfer only
takes an even number as input.
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class SimpleServicer(grpc_bt_grpc.SimpleServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0
        # Just for debugging purpose.
        log.debug("SimpleServicer created")

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
        spres = subprocess.run(cmd, capture_output=True, cwd="service")
        self.result.value = int(spres.stdout)

        log.debug("incrementer {} = {}".format(self.argument, self.result.value))
        return self.result

    # Multiply an integer by 2
    def twicer(self, request, context):
        self.argument = request.argument

        self.result = Result()

        # # Python twicer
        # self.result.value = self.argument * 2

        # Idris twicer
        argstr = str(self.argument)
        cmd = ["idris2", "Twicer.idr", "--client", "twicer " + argstr]
        spres = subprocess.run(cmd, capture_output=True, cwd="service")
        self.result.value = int(spres.stdout)

        log.debug("twicer {} = {}".format(self.argument, self.result.value))
        return self.result

    # Divide an integer by 2
    def halfer(self, request, context):
        self.argument = request.argument

        self.result = Result()

        # Python halfer
        # self.result.value = self.argument // 2

        # Idris halfer
        argstr = str(self.argument)
        cmd = ["idris2", "Halfer.idr", "--client", "halfer " + argstr]
        spres = subprocess.run(cmd, capture_output=True, cwd="service")
        self.result.value = int(spres.stdout)

        log.debug("halfer {} = {}".format(self.argument, self.result.value))
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
    grpc_bt_grpc.add_SimpleServicer_to_server(SimpleServicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
