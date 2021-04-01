import sys
import logging
import subprocess

import grpc
import concurrent.futures as futures

import service.common

# Importing the generated codes from buildproto.sh
import service.proto_spec.registry_service_pb2_grpc as grpc_registry_grpc
from service.proto_spec.registry_service_pb2 import Result

from service import registry

logging.basicConfig(level=10, format="[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s")
log = logging.getLogger("registry_service")

"""
Service to

1. retrieve a service matching a certain type signature.
2. compose a composite service from existing services given a certain
   type signature to match.
"""

# Create a class to be added to the gRPC server
# derived from the protobuf codes.
class RegistryServicer(grpc_registry_grpc.RegistryServicer):
    def __init__(self):
        self.argument = 0
        self.result = 0

        # Type check Registry.idr
        cmd = ["idris2", "Registry.idr", "--check"]
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        if (spr.returncode != 0):
            log.debug("Failed type checking!")
            log.debug("stdout: {}".format(spr.stdout.strip()))
            log.debug("stderr: {}".format(spr.stderr.strip()))
            exit(spr.returncode)

        # Fetch service names (imported modules in Registry.idr)
        cmd = ["sed", "-n", r"s/^import \(.\+\)/\1/p", "Registry.idr"]
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        if (spr.returncode != 0):
            log.debug("Failed fetching service names!")
            log.debug("stdout: {}".format(spr.stdout.strip()))
            log.debug("stderr: {}".format(spr.stderr.strip()))
            exit(spr.returncode)
        self.services = str(spr.stdout.strip()).split()
        self.services += ["Registry"] # Add the Registry itself
        log.debug("Registered services = {}".format(", ".join(self.services)))

        # Just for debugging purpose.
        log.debug("RegistryServicer created")

    def retrieve(self, request, context):
        self.tsgn = request.type_signature
        self.result = Result()

        # Call idris2 :search
        cmd = ["idris2", "Registry.idr", "--client", ":search " + self.tsgn]
        # log.debug("cmd: {}".format(cmd))
        spr = subprocess.run(cmd, capture_output=True, text=True, cwd="service")
        if (spr.returncode != 0):
            log.debug("Failed to call the registry!")
            log.debug("stdout: {}".format(spr.stdout.strip()))
            log.debug("stderr: {}".format(spr.stderr.strip()))
        tsgn_matches = spr.stdout.strip().split('\n')
        # Filter out matches not corresponding to services in the registry
        tsgn_svc_matches = [m for m in tsgn_matches
                            if any(m.startswith(s) for s in self.services)]

        if not tsgn_svc_matches:
            log.debug("No matching services with type signature: {}".format(self.tsgn))
            return self.result

        # Return the first match
        front_match = tsgn_svc_matches[0]
        svc_proc_names = front_match.split()[0]
        (svc_name, proc_name) = svc_proc_names.split('.')
        self.result.service_name = svc_name
        self.result.procedure_name = proc_name
        log.debug("retrieve {} = ({}, {})".format(self.tsgn,
                                                  self.result.service_name,
                                                  self.result.procedure_name))
        return self.result

    def compose(self, request, context):
        log.debug("Registry.compose is not implemented")
        return Result()


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
    grpc_registry_grpc.add_RegistryServicer_to_server(RegistryServicer(), server)
    server.add_insecure_port("[::]:{}".format(port))
    return server


if __name__ == "__main__":
    """
    Runs the gRPC server to communicate with the Snet Daemon.
    """
    parser = service.common.common_parser(__file__)
    args = parser.parse_args(sys.argv[1:])
    service.common.main_loop(serve, args)
