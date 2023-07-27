import grpc
import services_pb2
import services_pb2_grpc

def run_client():
    channel = grpc.insecure_channel('localhost:50051')  # Set the server address and port
    stub = services_pb2_grpc.SimpleServicesStub(channel)

    # Test baz . foo . bar (invalid)
    print("=== Test baz . foo . bar (invalid) ===")

    bar_request = services_pb2.BarIn(bar_int=42)
    print("type(bar_request) = {}".format(type(bar_request)))
    print("bar_request = {}".format(bar_request))

    bar_response = stub.bar_rpc(bar_request)
    print("type(bar_response) = {}".format(type(bar_response)))
    print("bar_response = {}".format(bar_response))

    # Pass the output of bar indirectly, via re-initialization into
    # the input of foo.  It fails.
    foo_request = services_pb2.FooIn(foo_bool=bar_response.bar_str)
    foo_response = stub.foo_rpc(foo_request)
    print("type(foo_response) = {}".format(type(foo_response)))
    print("foo_response = {}".format(foo_response))

    baz_request = services_pb2.BazIn(baz_str=foo_response.foo_int)
    baz_response = stub.baz_rpc(baz_request)
    print("type(baz_response) = {}".format(type(baz_response)))
    print("baz_response = {}".format(baz_response))

if __name__ == '__main__':
    run_client()
