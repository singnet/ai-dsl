import grpc
import services_pb2
import services_pb2_grpc

def run_client():
    channel = grpc.insecure_channel('localhost:50051')  # Set the server address and port
    stub = services_pb2_grpc.SimpleServicesStub(channel)

    # Test baz . bar . foo (valid)
    print("=== Test baz . bar . foo (valid) ===")
    foo_request = services_pb2.FooIn(foo_bool=True)
    print("foo_request = {}".format(foo_request))
    foo_response = stub.foo_rpc(foo_request)
    print("foo_response = {}".format(foo_response))
    # Pass the output of foo directly into the input of bar.
    # Interestingly it seems that the field names do not matter, only
    # their types and places.
    bar_response = stub.bar_rpc(foo_response)
    print("bar_response = {}".format(bar_response))
    # Pass the output of bar directly into the input of baz.
    baz_response = stub.baz_rpc(bar_response)
    print("baz_response = {}".format(baz_response))

if __name__ == '__main__':
    run_client()
