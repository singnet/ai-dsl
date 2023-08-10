import grpc
import services_pb2
import services_pb2_grpc

def run_client():
    channel = grpc.insecure_channel('localhost:50051')  # Set the server address and port
    stub = services_pb2_grpc.SimpleServicesStub(channel)

    print("=== Test services individually ===")

    # Test foo
    foo_request = services_pb2.FooIn(foo_bool=True)
    foo_response = stub.foo_rpc(foo_request)
    print("Foo response: {}".format(foo_response.foo_int))

    # Test bar
    bar_request = services_pb2.BarIn(bar_int=42)
    bar_response = stub.bar_rpc(bar_request)
    print("Bar response: \"{}\"".format(bar_response.bar_str))

    # Test baz
    baz_request = services_pb2.BazIn(baz_str="42")
    baz_response = stub.baz_rpc(baz_request)
    print("Baz response:", baz_response.baz_bool)


if __name__ == '__main__':
    run_client()
